library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.ppu_consts.all;

-- TODO: add input stable / output stable pipeline stages if this doesn't work with propagation delays
entity ppu_sprite_bg is port(
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
end ppu_sprite_bg;

architecture Behavioral of ppu_sprite_bg is
	component ppu_sprite_transform port(
		XI : in unsigned(PPU_SPRITE_POS_H_WIDTH-1 downto 0); -- pixel position relative to tile
		YI : in unsigned(PPU_SPRITE_POS_V_WIDTH-1 downto 0); -- pixel position relative to tile
		FLIP_H, FLIP_V : in std_logic; -- flip sprite
		XO : out unsigned(PPU_SPRITE_POS_H_WIDTH-1 downto 0); -- new pixel position relative to tile
		YO : out unsigned(PPU_SPRITE_POS_V_WIDTH-1 downto 0)); -- new pixel position relative to tile
	end component;

	-- BAM and TMM in/out temp + registers
	signal T_BAM_ADDR, R_BAM_ADDR : std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal T_BAM_DATA, R_BAM_DATA : std_logic_vector(PPU_BAM_DATA_WIDTH-1 downto 0) := (others => '0');
	signal T_TMM_ADDR, R_TMM_ADDR : std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal T_TMM_DATA, R_TMM_DATA : std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0) := (others => '0');

	-- state machine for synchronizing pipeline stages
	type states is (PL_BAM_ADDR, PL_BAM_DATA, PL_TMM_ADDR, PL_TMM_DATA);
	signal state : states := PL_BAM_ADDR;

	-- docs/architecture.md#background-attribute-memory
	alias BAM_DATA_FLIP_H is R_BAM_DATA(14); -- flip horizontally
	alias BAM_DATA_FLIP_V is R_BAM_DATA(13); -- flip vertically
	alias BAM_DATA_TILE_IDX is R_BAM_DATA(9 downto 0); -- tilemap tile index
	alias BAM_DATA_COL_IDX is R_BAM_DATA(12 downto 10); -- palette for sprite

	-- auxiliary signals (temp variables)
	signal PIXEL_ABS_X, PIXEL_ABS_Y : integer := 0; -- absolute pixel position (relative to BG canvas instead of viewport)
	signal TILE_IDX_X, TILE_IDX_Y : integer := 0; -- background canvas tile grid xy
	signal TILE_PIDX_X, TRANS_TILE_PIDX_X : unsigned(PPU_SPRITE_POS_H_WIDTH-1 downto 0) := (others => '0'); -- x position of pixel within tile (local tile coords)
	signal TILE_PIDX_Y, TRANS_TILE_PIDX_Y : unsigned(PPU_SPRITE_POS_V_WIDTH-1 downto 0) := (others => '0'); -- y position of pixel within tile (local tile coords)
	signal TRANS_TILE_PIDX : integer := 0; -- index of pixel within tile (reading order)
	signal TILEMAP_WORD_OFFSET : integer := 0; -- word offset from tile start address in TMM
	signal PIXEL_BIT_OFFSET : integer := 0; -- pixel index within word of TMM
	signal TMM_DATA_PAL_IDX : std_logic_vector(PPU_PALETTE_COLOR_WIDTH-1 downto 0); -- color of palette
	signal T_CIDX : std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0) := (others => '0'); -- output color buffer/register
begin
	-- output drivers
	CIDX <= T_CIDX when OE = '1' else (others => 'Z');
	BAM_ADDR <= R_BAM_ADDR;
	TMM_ADDR <= R_TMM_ADDR;
	T_BAM_DATA <= BAM_DATA;
	T_TMM_DATA <= TMM_DATA;
	-- CIDX combination
	T_CIDX <= BAM_DATA_COL_IDX & TMM_DATA_PAL_IDX;

	-- BAM address calculations
	PIXEL_ABS_X <= to_integer(unsigned(X)) + to_integer(unsigned(BG_SHIFT_X)); -- pixel position relative to background canvas
	PIXEL_ABS_Y <= to_integer(unsigned(Y)) + to_integer(unsigned(BG_SHIFT_Y)); -- pixel position relative to background canvas
	TILE_IDX_X <= PIXEL_ABS_X / 16; -- tile grid index
	TILE_IDX_Y <= PIXEL_ABS_Y / 16; -- tile grid index
	TILE_PIDX_X <= to_unsigned(PIXEL_ABS_X - TILE_IDX_X * 16, TILE_PIDX_X'length); -- (sprite local) pixel coords
	TILE_PIDX_Y <= to_unsigned(PIXEL_ABS_Y - TILE_IDX_Y * 16, TILE_PIDX_Y'length); -- (sprite local) pixel coords
	T_BAM_ADDR <= std_logic_vector(to_unsigned((TILE_IDX_Y * integer(PPU_BG_CANVAS_TILES_H)) + TILE_IDX_X, PPU_BAM_ADDR_WIDTH));

	-- BAM data dependant calculations
	transform: component ppu_sprite_transform port map(
		XI => TILE_PIDX_X,
		YI => TILE_PIDX_Y,
		FLIP_H => BAM_DATA_FLIP_H,
		FLIP_V => BAM_DATA_FLIP_V,
		XO => TRANS_TILE_PIDX_X,
		YO => TRANS_TILE_PIDX_Y);

	-- TMM address calculations
	TRANS_TILE_PIDX <= integer(PPU_SPRITE_WIDTH) * to_integer(TRANS_TILE_PIDX_Y) + to_integer(TRANS_TILE_PIDX_X); -- pixel index of sprite
	TILEMAP_WORD_OFFSET <= TRANS_TILE_PIDX / PPU_PIXELS_PER_TILE_WORD; -- word offset from starting word of sprite
	PIXEL_BIT_OFFSET <= TRANS_TILE_PIDX mod PPU_PIXELS_PER_TILE_WORD; -- pixel bit offset
	T_TMM_ADDR <= std_logic_vector(to_unsigned(PPU_SPRITE_WORD_COUNT * to_integer(unsigned(BAM_DATA_TILE_IDX)) + TILEMAP_WORD_OFFSET, PPU_TMM_ADDR_WIDTH)); -- TMM address

	-- TMM DATA
	with PIXEL_BIT_OFFSET select
		TMM_DATA_PAL_IDX <= R_TMM_DATA(2 downto 0) when 0,
		                    R_TMM_DATA(5 downto 3) when 1,
		                    R_TMM_DATA(8 downto 6) when 2,
		                    R_TMM_DATA(11 downto 9) when 3,
		                    R_TMM_DATA(14 downto 12) when 4,
		                    (others => '0') when others;

	-- state machine (pipeline stage counter) + sync r/w
	process(CLK, RESET)
	begin
		if RESET = '1' then
			-- reset state
			state <= PL_BAM_ADDR;
			-- reset internal pipeline registers
			R_BAM_ADDR <= (others => '0');
			R_BAM_DATA <= (others => '0');
			R_TMM_ADDR <= (others => '0');
			R_TMM_DATA <= (others => '0');
		elsif rising_edge(CLK) then
			case state is
				when PL_BAM_ADDR =>
					state <= PL_BAM_DATA;
					R_BAM_ADDR <= T_BAM_ADDR;
				when PL_BAM_DATA =>
					state <= PL_TMM_ADDR;
					R_BAM_DATA <= T_BAM_DATA;
				when PL_TMM_ADDR =>
					state <= PL_TMM_DATA;
					R_TMM_ADDR <= T_TMM_ADDR;
				when PL_TMM_DATA =>
					state <= PL_BAM_ADDR;
					R_TMM_DATA <= T_TMM_DATA;
			end case;
		end if;
	end process;
end Behavioral;
