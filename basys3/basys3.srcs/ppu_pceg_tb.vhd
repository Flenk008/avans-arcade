library ieee;
library unisim;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;

entity ppu_pceg_tb is
end ppu_pceg_tb;

architecture behavioral of ppu_pceg_tb is
	component ppu_pceg port(
		CLK : in std_logic; -- system clock
		RESET : in std_logic; -- async reset
		SPRITE : out std_logic; -- sprite info fetch + sprite pixel fetch
		COMP_PAL : out std_logic; -- compositor + palette lookup
		DONE : out std_logic); -- last pipeline stage done
	end component;
	signal CLK : std_logic := '0';
	signal RESET : std_logic := '0';
	signal SPRITE : std_logic;
	signal COMP_PAL : std_logic;
	signal DONE : std_logic;

begin
	uut : ppu_pceg port map(
		CLK => CLK,
		RESET => RESET,
		SPRITE => SPRITE,
		COMP_PAL => COMP_PAL,
		DONE => DONE);

	tb : process
	begin
		for i in 0 to 32 loop
			if i > 20 then
				RESET <= '1';
			end if;
	
			wait for 5 ns;
			CLK <= '1';
			wait for 5 ns;
			CLK <= '0';
		end loop;
		wait; -- stop for simulator
	end process;
end;
