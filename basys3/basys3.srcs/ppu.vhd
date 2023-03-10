library ieee;
library work;

use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use work.ppu_consts.all;

entity ppu is port(
	CLK100 : in std_logic; -- system clock
	RESET : in std_logic; -- global (async) system reset
	EN : in std_logic; -- PPU VRAM enable (enable ADDR and DATA tri-state drivers)
	WEN : in std_logic; -- PPU VRAM write enable
	ADDR : in std_logic_vector(PPU_RAM_BUS_ADDR_WIDTH-1 downto 0); -- PPU VRAM ADDR
	DATA : in std_logic_vector(PPU_RAM_BUS_DATA_WIDTH-1 downto 0);
	R,G,B : out std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0);
	NVSYNC, NHSYNC : out std_logic; -- native VGA out
	TVSYNC, TVBLANK, THSYNC, THBLANK : out std_logic); -- tiny VGA out
end ppu;

architecture Behavioral of ppu is
	-- TODO: separate SPRITE_BG and SPRITE_FG lines (foreground_sprite only needs 2 clock cycles)
	component ppu_pceg port( -- pipeline clock edge generator
		CLK : in std_logic; -- system clock
		RESET : in std_logic; -- async reset
		SPRITE : out std_logic; -- sprite info fetch + sprite pixel fetch
		COMP_PAL : out std_logic; -- compositor + palette lookup
		DONE : out std_logic); -- last pipeline stage done
	end component;
	component ppu_addr_dec port( -- pipeline clock edge generator
		WEN : in std_logic; -- EXT write enable
		TMM_WEN,
		BAM_WEN,
		FAM_WEN,
		PAL_WEN,
		AUX_WEN : out std_logic; -- write enable MUX
		EN : in std_logic; -- EXT *ADDR enable (switch *AO to ADDR instead of *AI)
		ADDR : in std_logic_vector(PPU_RAM_BUS_ADDR_WIDTH-1 downto 0); -- address in
		TMM_AI : in std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
		BAM_AI : in std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
		FAM_AI : in std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0);
		PAL_AI : in std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0);
		AUX_AI : in std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0);
		TMM_AO : out std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
		BAM_AO : out std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
		FAM_AO : out std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0);
		PAL_AO : out std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0);
		AUX_AO : out std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0));
	end component;
	component ppu_bam port( -- BAM block memory
		clka : in std_logic;
		rsta : in std_logic;
		wea : in std_logic_vector(0 downto 0);
		addra : in std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
		dina : in std_logic_vector(PPU_BAM_DATA_WIDTH-1 downto 0);
		douta : out std_logic_vector(PPU_BAM_DATA_WIDTH-1 downto 0);
		rsta_busy : out std_logic);
	end component;
	component ppu_tmm port( -- TMM block memory
		clka : in std_logic;
		rsta : in std_logic;
		wea : in std_logic_vector(0 downto 0);
		addra : in std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
		dina : in std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0);
		douta : out std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0);
		rsta_busy : out std_logic);
	end component;
	component ppu_aux port(
		CLK : in std_logic; -- system clock
		RESET : in std_logic; -- reset memory

		-- internal memory block (AUX)
		AUX_WEN : in std_logic; -- VRAM AUX write enable
		AUX_ADDR : in std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0); -- VRAM AUX address
		AUX_DATA : in std_logic_vector(PPU_AUX_DATA_WIDTH-1 downto 0); -- VRAM AUX data
		
		-- aux outputs
		BG_SHIFT_X : out std_logic_vector(PPU_POS_H_WIDTH-1 downto 0);
		BG_SHIFT_Y : out std_logic_vector(PPU_POS_V_WIDTH-1 downto 0);
		FG_FETCH : out std_logic);
	end component;
	component ppu_sprite_bg port( -- background sprite
		-- inputs
		CLK : in std_logic; -- pipeline clock
		RESET : in std_logic; -- reset clock counter
		OE : in std_logic; -- output enable (of CIDX)
		X : in std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
		Y : in std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y
		
		-- aux inputs
		BG_SHIFT_X : in std_logic_vector(PPU_POS_H_WIDTH-1 downto 0);
		BG_SHIFT_Y : in std_logic_vector(PPU_POS_V_WIDTH-1 downto 0);

		-- used memory blocks
		BAM_ADDR : out std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
		BAM_DATA : in std_logic_vector(PPU_BAM_DATA_WIDTH-1 downto 0);
		TMM_ADDR : out std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
		TMM_DATA : in std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0);

		-- outputs
		CIDX : out std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0)); -- output color
	end component;
	component ppu_sprite_fg -- foreground sprite
		generic (
			IDX : natural := 0);
		port(
			-- inputs
			CLK : in std_logic; -- system clock
			RESET : in std_logic; -- reset internal memory and clock counters
			OE : in std_logic; -- output enable (of CIDX)
			X : in std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
			Y : in std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y
			FETCH : in std_logic; -- fetch sprite data from TMM
			VBLANK : in std_logic; -- fetch during vblank

			-- internal memory block (FAM)
			FAM_WEN : in std_logic; -- VRAM FAM write enable
			FAM_ADDR : in std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0); -- VRAM fam address
			FAM_DATA : in std_logic_vector(PPU_FAM_DATA_WIDTH-1 downto 0); -- VRAM fam data

			-- used memory blocks
			TMM_ADDR : out std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
			TMM_DATA : in std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0);

			-- outputs
			CIDX : out std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0); -- output color
			HIT : out std_logic); -- current pixel is not transparent
	end component;
	component ppu_comp port( -- compositor
		FG_HIT : in std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0);
		BG_EN : out std_logic;
		FG_EN : out std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0));
	end component;
	component ppu_plut port( -- palette lookup table
		CLK : in std_logic; -- system clock
		CIDX : in std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0); -- color in
		RESET : in std_logic;

		-- internal memory block (AUX)
		PAL_WEN : in std_logic; -- VRAM PAL write enable
		PAL_ADDR : in std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0); -- VRAM PAL address
		PAL_DATA : in std_logic_vector(PPU_PAL_DATA_WIDTH-1 downto 0); -- VRAM PAL data
		
		R,G,B : out std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0)); -- VGA color out
	end component;
	component ppu_vga_tiny port( -- tiny vga signal generator
		CLK : in std_logic; -- system clock
		RESET : in std_logic;

		X : out std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
		Y : out std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y
		
		VSYNC, VBLANK,
		HSYNC, HBLANK : out std_logic); -- VGA sync outputs
	end component;
	component ppu_vga_native port( -- native vga signal generator (upscaler)
		CLK : in std_logic; -- system clock
		RESET : in std_logic;

		X : in std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
		Y : in std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y
		PREADY : in std_logic; -- current pixel ready (pixel color is stable)
		RI,GI,BI : in std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0); -- VGA color in
		
		RO,GO,BO : out std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0); -- VGA color out
		VSYNC, HSYNC : out std_logic); -- VGA sync outputs
	end component;

	-- signals
	signal SYSCLK, SYSRST : std_logic; -- system clock and reset
	signal PL_SPRITE, PL_COMP_PAL, PL_DONE : std_logic; -- pipeline stages
	signal TMM_WEN, BAM_WEN, FAM_WEN, PAL_WEN, AUX_WEN : std_logic;
	signal TMM_AI, TMM_AO : std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
	signal BAM_AI, BAM_AO : std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
	signal FAM_AI, FAM_AO : std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0);
	signal PAL_AI, PAL_AO : std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0);
	signal AUX_AI, AUX_AO : std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0);
	signal TMM_DO : std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0);
	signal BAM_DO : std_logic_vector(PPU_BAM_DATA_WIDTH-1 downto 0);
	signal FAM_DO : std_logic_vector(PPU_FAM_DATA_WIDTH-1 downto 0);
	signal PAL_DO : std_logic_vector(PPU_PAL_DATA_WIDTH-1 downto 0);
	signal AUX_DO : std_logic_vector(PPU_AUX_DATA_WIDTH-1 downto 0);
	signal CIDX : std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0);
	signal BG_EN : std_logic;
	signal FG_EN, FG_HIT : std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0);
	signal X : std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
	signal Y : std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y
	signal UR,UG,UB : std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0); -- unstable RGB (to be buffered)
	signal SR,SG,SB : std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0); -- stable RGB (buffered until PL_COMP_PAL)
	signal BG_SHIFT_X : std_logic_vector(PPU_POS_H_WIDTH-1 downto 0);
	signal BG_SHIFT_Y : std_logic_vector(PPU_POS_V_WIDTH-1 downto 0);
	signal FG_FETCH : std_logic;
	signal TINY_VBLANK, TINY_VSYNC, TINY_HBLANK, TINY_HSYNC,
	       NATIVE_VSYNC, NATIVE_HSYNC : std_logic;
begin
	SYSCLK <= CLK100;
	SYSRST <= RESET;

	-- internal unused lines
	--
	-- these lines would be used if components use memory blocks as RAM blocks
	-- (like how TMM and BAM work), the registers of these memory regions are
	-- directly exposed internally, and are as such not used as RAM blocks
	AUX_AI <= (others => '0');
	FAM_AI <= (others => '0');
	PAL_AI <= (others => '0');

	TVBLANK <= TINY_VBLANK;
	TVSYNC <= TINY_VSYNC;
	THBLANK <= TINY_HBLANK;
	THSYNC <= TINY_HSYNC;
	NVSYNC <= NATIVE_VSYNC;
	NHSYNC <= NATIVE_HSYNC;

	pipeline_clock_edge_generator : component ppu_pceg port map(
		CLK => SYSCLK,
		RESET => SYSRST,
		SPRITE => PL_SPRITE,
		COMP_PAL => PL_COMP_PAL,
		DONE => PL_DONE);

	address_decoder : component ppu_addr_dec port map(
		EN => EN,
		WEN => WEN,
		ADDR => ADDR,
		TMM_AI => TMM_AI,
		BAM_AI => BAM_AI,
		FAM_AI => FAM_AI,
		PAL_AI => PAL_AI,
		AUX_AI => AUX_AI,
		TMM_AO => TMM_AO,
		BAM_AO => BAM_AO,
		FAM_AO => FAM_AO,
		PAL_AO => PAL_AO,
		AUX_AO => AUX_AO,
		TMM_WEN => TMM_WEN,
		BAM_WEN => BAM_WEN,
		FAM_WEN => FAM_WEN,
		PAL_WEN => PAL_WEN,
		AUX_WEN => AUX_WEN);

	background_attribute_memory : component ppu_bam port map(
		clka => SYSCLK,
		rsta => SYSRST,
		wea => (others => BAM_WEN),
		addra => BAM_AO,
		dina => DATA(PPU_BAM_DATA_WIDTH-1 downto 0),
		douta => BAM_DO,
		rsta_busy => open);
	tilemap_memory : component ppu_tmm port map(
		clka => SYSCLK,
		rsta => SYSRST,
		wea => (others => TMM_WEN),
		addra => TMM_AO,
		dina => DATA(PPU_TMM_DATA_WIDTH-1 downto 0),
		douta => TMM_DO,
		rsta_busy => open);

	aux : component ppu_aux port map(
		CLK => SYSCLK,
		RESET => SYSRST,
		AUX_WEN => AUX_WEN,
		AUX_ADDR => AUX_AO,
		AUX_DATA => DATA(PPU_AUX_DATA_WIDTH-1 downto 0),
		BG_SHIFT_X => BG_SHIFT_X,
		BG_SHIFT_Y => BG_SHIFT_Y,
		FG_FETCH => FG_FETCH);

	background_sprite : component ppu_sprite_bg port map(
		CLK => PL_SPRITE,
		RESET => SYSRST,
		OE => BG_EN,
		X => X,
		Y => Y,
		BG_SHIFT_X => BG_SHIFT_X,
		BG_SHIFT_Y => BG_SHIFT_Y,
		BAM_ADDR => BAM_AI,
		BAM_DATA => BAM_DO,
		TMM_ADDR => TMM_AI,
		TMM_DATA => TMM_DO,
		CIDX => CIDX);

	foreground_sprites : for FG_IDX in 0 to PPU_FG_SPRITE_COUNT-1 generate
		foreground_sprite : component ppu_sprite_fg
			generic map( IDX => FG_IDX )
			port map(
				CLK => SYSCLK,
				RESET => SYSRST,
				OE => FG_EN(FG_IDX),
				X => X,
				Y => Y,
				FETCH => FG_FETCH,
				VBLANK => TINY_VBLANK,
				FAM_WEN => FAM_WEN,
				FAM_ADDR => FAM_AO,
				FAM_DATA => DATA(PPU_FAM_DATA_WIDTH-1 downto 0),
				TMM_ADDR => TMM_AI,
				TMM_DATA => TMM_DO,
				CIDX => CIDX,
				HIT => FG_HIT(FG_IDX));
	end generate;

	compositor : component ppu_comp port map( -- compositor
		FG_HIT => FG_HIT,
		BG_EN => BG_EN,
		FG_EN => FG_EN);

	palette_lookup : component ppu_plut port map( -- palette lookup table
		CLK => SYSCLK,
		CIDX => CIDX,
		RESET => SYSRST,
		PAL_WEN => PAL_WEN,
		PAL_ADDR => PAL_AO,
		PAL_DATA => DATA(PPU_PAL_DATA_WIDTH-1 downto 0),
		R => UR,
		G => UG,
		B => UB);

	-- palette lookup output buffer (pipeline stage 5)
	process(PL_COMP_PAL, SYSRST)
	begin
		if SYSRST = '1' then
			SR <= x"0";
			SG <= x"0";
			SB <= x"0";
		elsif rising_edge(PL_COMP_PAL) then
			SR <= UR;
			SG <= UG;
			SB <= UB;
		end if;
	end process;

	tiny_vga_signal_generator : component ppu_vga_tiny port map( -- tiny vga signal generator
		CLK => SYSCLK,
		RESET => SYSRST,
		X => X,
		Y => Y,
		VSYNC => TINY_VSYNC,
		VBLANK => TINY_VBLANK,
		HSYNC => TINY_HSYNC,
		HBLANK => TINY_HBLANK);

	native_vga_signal_generator : component ppu_vga_native port map( -- native vga signal generator (upscaler)
		CLK => SYSCLK,
		RESET => SYSRST,
		X => X,
		Y => Y,
		PREADY => PL_DONE,
		RI => SR,
		GI => SG,
		BI => SB,
		RO => R,
		GO => G,
		BO => B,
		VSYNC => NATIVE_VSYNC,
		HSYNC => NATIVE_HSYNC);
end Behavioral;
