library ieee;
library unisim;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;

entity er_ram_tb is
end er_ram_tb;

architecture behavioral of er_ram_tb is
	component er_ram
		generic(
			ADDR_W : natural := 2; -- ADDR line width
			DATA_W : natural := 2; -- DATA line width
			ADDR_LOW : natural := 16#0000#; -- starting address
			ADDR_RANGE : natural := 16#0002#); -- amount of valid addresses after ADDR_LOW
		port(
			CLK : in std_logic; -- clock
			RST : in std_logic; -- async memory clear
			WEN : in std_logic; -- write enable
			ADDR : in std_logic_vector(ADDR_W-1 downto 0);
			DATA : in std_logic_vector(DATA_W-1 downto 0);
			REG : out std_logic_vector((ADDR_W*DATA_W)-1 downto 0));
	end component;

	signal CLK, RST, WEN : std_logic := '0';
	signal ADDR : std_logic_vector(3 downto 0);
	signal DATA : std_logic_vector(7 downto 0);
	signal REG : std_logic_vector(31 downto 0);
begin
	uut : component er_ram
		generic map(
			ADDR_W => 4,
			DATA_W => 8,
			ADDR_LOW => 0,
			ADDR_RANGE => 4)
		port map(
			CLK => CLK,
			RST => RST,
			WEN => WEN,
			ADDR => ADDR,
			DATA => DATA,
			REG => REG);

	tb : process
	begin
		wait for 5 ns;

		-- async reset (safety)
		RST <= '1';
		wait for 5 ns;
		RST <= '0';
		wait for 5 ns;

		-- set 0xef at address 0x1 (exists)
		DATA <= x"ef";
		ADDR <= x"1";
		WEN <= '1';

		CLK <= '1';
		wait for 5 ns;
		CLK <= '0';
		wait for 5 ns;

		-- set 0x34 at address 0x4 (doesn't exist)
		ADDR <= x"4";
		DATA <= x"34";

		CLK <= '1';
		wait for 5 ns;
		CLK <= '0';
		wait for 5 ns;

		-- reset
		RST <= '1';
		wait for 5 ns;
		RST <= '0';
		wait for 5 ns;

		-- set REG to 0x12345678
		ADDR <= x"0";
		DATA <= x"12";

		CLK <= '1';
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;

		ADDR <= x"1";
		DATA <= x"34";

		CLK <= '1';
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;

		ADDR <= x"2";
		DATA <= x"56";

		CLK <= '1';
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;

		ADDR <= x"3";
		DATA <= x"78";

		CLK <= '1';
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;

		wait; -- stop for simulator
	end process;
end;
