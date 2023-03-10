library ieee;
library unisim;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;

entity er_ram_mod_tb is
end er_ram_mod_tb;

architecture behavioral of er_ram_mod_tb is
	component er_ram_mod
		generic(
			W : natural := 1; -- module data width
			ADDR_W : natural := 1; -- address width
			ADDR_M : std_logic_vector(ADDR_W-1 downto 0) := (others => '0')); -- address match
		port(
			CLK : in std_logic; -- clock
			RST : in std_logic; -- async memory clear
			WEN : in std_logic; -- write enable
			ADDR : in std_logic_vector(ADDR_W-1 downto 0);
			DATA : in std_logic_vector(W-1 downto 0); -- data
			REG : out std_logic_vector(W-1 downto 0)); -- direct register out
	end component;

	signal CLK, RST, WEN : std_logic := '0';
	signal ADDR : std_logic_vector(3 downto 0);
	signal DATA : std_logic_vector(7 downto 0);
	signal REG : std_logic_vector(7 downto 0);
begin
	uut : component er_ram_mod
		generic map(
			W => 8,
			ADDR_W => 4,
			ADDR_M => x"5")
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

		-- set 0xef at address 0x5 (exists)
		DATA <= x"ef";
		ADDR <= x"5";
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

		wait; -- stop for simulator
	end process;
end;
