library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity er_ram is -- exposed register RAM
	generic(
		ADDR_W : natural := 2; -- ADDR line width
		DATA_W : natural := 2; -- DATA line width
		ADDR_LOW : natural := 16#0000#; -- starting address
		ADDR_RANGE : natural := 16#0002#); -- amount of valid addresses after ADDR_LOW
	port(
		CLK : in std_logic; -- clock
		RST : in std_logic; -- async memory clear
		WEN : in std_logic; -- write enable
		ADDR : in std_logic_vector(ADDR_W-1 downto 0); -- address line
		DATA : in std_logic_vector(DATA_W-1 downto 0); -- data input
		REG : out std_logic_vector((ADDR_RANGE*DATA_W)-1 downto 0)); -- exposed register output
end er_ram;

architecture Behavioral of er_ram is
	component er_ram_mod
		generic(
			W : natural := DATA_W; -- module data width
			ADDR_W : natural := ADDR_W; -- address width
			ADDR_M : std_logic_vector(ADDR_W-1 downto 0) := (others => '0')); -- address match
		port(
			CLK : in std_logic; -- clock
			RST : in std_logic; -- async memory clear
			WEN : in std_logic; -- write enable
			ADDR : in std_logic_vector(ADDR_W-1 downto 0);
			DATA : in std_logic_vector(W-1 downto 0); -- data
			REG : out std_logic_vector(W-1 downto 0)); -- direct register out
	end component;
	signal INT_REG : std_logic_vector((ADDR_RANGE*DATA_W)-1 downto 0);
begin
	REG <= INT_REG;

	registers : for idx in 0 to ADDR_RANGE - 1 generate
		reg : component er_ram_mod
			generic map(
				W => DATA_W,
				ADDR_W => ADDR_W,
				ADDR_M => std_logic_vector(to_unsigned(ADDR_LOW + idx, ADDR_W)))
			port map(
				CLK => CLK,
				RST => RST,
				WEN => WEN,
				ADDR => ADDR,
				DATA => DATA,
				REG => INT_REG(idx*DATA_W+DATA_W-1 downto idx*DATA_W));
	end generate;
end Behavioral;
