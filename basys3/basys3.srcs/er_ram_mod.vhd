library ieee;
library work;
use ieee.std_logic_1164.all;

entity er_ram_mod is -- exposed register RAM module (single register)
	generic(
		W : natural := 1; -- module data width
		ADDR_W : natural := 1; -- address width
		ADDR_M : std_logic_vector(ADDR_W-1 downto 0) := (others => '0')); -- address match
	port(
		CLK : in std_logic; -- clock
		RST : in std_logic; -- async memory clear
		WEN : in std_logic; -- write enable
		ADDR : in std_logic_vector(ADDR_W-1 downto 0); -- RAM address line
		DATA : in std_logic_vector(W-1 downto 0); -- RAM input data line
		REG : out std_logic_vector(W-1 downto 0)); -- direct register output lines
end er_ram_mod;

architecture Behavioral of er_ram_mod is
	signal DATA_REG : std_logic_vector(W-1 downto 0);
begin
	REG <= DATA_REG;

	process(CLK, RST)
	begin
		if RST = '1' then
			DATA_REG <= (others => '0');
		elsif rising_edge(CLK) then
			if WEN = '1' and ADDR = ADDR_M then
				DATA_REG <= DATA;
			end if;
		end if;
	end process;
end Behavioral;
