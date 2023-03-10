library ieee;
library work;
library unisim;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;
use work.ppu_consts.all;

entity ppu_sprite_fg_tb is
end ppu_sprite_fg_tb;

architecture Behavioral of ppu_sprite_fg_tb is
	component ppu_sprite_fg -- foreground sprite
		generic (
			IDX : natural := 0); -- sprite index number
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
	signal CLK : std_logic := '0';
	signal RESET : std_logic := '0';
	signal OE : std_logic := '0';
	signal X : std_logic_vector(PPU_POS_H_WIDTH-1 downto 0) := (others => '0');
	signal Y : std_logic_vector(PPU_POS_V_WIDTH-1 downto 0) := (others => '0');
	signal FETCH : std_logic := '0';
	signal VBLANK : std_logic := '0';
	signal FAM_WEN : std_logic := '0';
	signal FAM_ADDR : std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal FAM_DATA : std_logic_vector(PPU_FAM_DATA_WIDTH-1 downto 0) := (others => '0');
	signal TMM_ADDR : std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
	signal TMM_DATA : std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0) := (others => '0');
	signal CIDX : std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0) := (others => '0');
	signal HIT : std_logic;

	signal CLK_I : unsigned(31 downto 0) := (others => '0');
begin
	uut: component ppu_sprite_fg
		generic map( IDX => 2 )
		port map(
			CLK => CLK,
			RESET => RESET,
			OE => OE,
			X => X,
			Y => Y,
			FETCH => FETCH,
			VBLANK => VBLANK,
			FAM_WEN => FAM_WEN,
			FAM_ADDR => FAM_ADDR,
			FAM_DATA => FAM_DATA,
			TMM_ADDR => TMM_ADDR,
			TMM_DATA => TMM_DATA,
			CIDX => CIDX,
			HIT => HIT);

	tb : process
	begin
		-- initialize TMM cache
		RESET <= '1'; wait for 1 ns; RESET <= '0'; wait for 1 ns;

		OE <= '1';
		VBLANK <= '0';
		FETCH <= '0';

		-- FAM contents:
		-- flip horizontally
		-- xy -> (42-16, 8-16) = (26, -8)
		-- palette index 2
		-- tilemap index 460 (0x1cc)
		-- = hex((1 << 31) | (0 << 30) | (42 << 21) | (8 << 13) | (2 << 10) | (460 << 0))
		FAM_WEN <= '1';
		FAM_ADDR <= std_logic_vector(to_unsigned(16#0005#, FAM_ADDR'length));
		FAM_DATA <= std_logic_vector(to_unsigned(16#8541#, FAM_DATA'length));
		CLK <= '1'; wait for 1 ns; CLK <= '0'; wait for 1 ns;
		FAM_ADDR <= std_logic_vector(to_unsigned(16#0004#, FAM_ADDR'length));
		FAM_DATA <= std_logic_vector(to_unsigned(16#09cc#, FAM_DATA'length));
		CLK <= '1'; wait for 1 ns; CLK <= '0'; wait for 1 ns;
		FAM_WEN <= '0';

		for i in 0 to 32 loop
			if i = 0 then
				X <= std_logic_vector(to_unsigned(25, X'length));
				Y <= std_logic_vector(to_unsigned(60, Y'length));
			end if;

			if i = 3 then
				X <= std_logic_vector(to_unsigned(29, X'length));
				Y <= std_logic_vector(to_unsigned(4, Y'length));
			end if;
	
			wait for 5 ns; CLK <= '1'; wait for 5 ns; CLK <= '0';
		end loop;

		wait for 1 ns;
		RESET <= '1';
		wait for 10 ns;
		RESET <= '0';
		VBLANK <= '1';
		FETCH <= '1';
		wait for 1 ns;

		-- FETCH check
		for i in 0 to 500 loop
			CLK_I <= to_unsigned(i, 32);
			-- if i > 10 then
			-- 	OE <= '1';
			-- end if;
			-- if i > 20 then
			-- 	RESET <= '1';
			-- end if;

			TMM_DATA <= std_logic_vector(to_unsigned(i - 106, TMM_DATA'length));
	
			CLK <= '1';
			wait for 1 ns;
			CLK <= '0';
			wait for 1 ns;
		end loop;
		wait; -- stop for simulator
	end process;
end Behavioral;
