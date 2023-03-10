library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity apu is port(
	CLK100 : in std_logic; -- system clock
	RESET : in std_logic; -- global (async) system reset
	DATA : in std_logic_vector(15 downto 0);
	SOUND : out std_logic);

	-- EN : in std_logic; -- PPU VRAM enable (enable ADDR and DATA tri-state drivers)
	-- WEN : in std_logic; -- PPU VRAM write enable
	-- ADDR : in std_logic_vector(15 downto 0); -- PPU VRAM ADDR
	-- R,G,B : out std_logic_vector(3 downto 0);
	-- NVSYNC, NHSYNC : out std_logic; -- native VGA out
	-- TVSYNC, TVBLANK, THSYNC, THBLANK : out std_logic); -- tiny VGA out
end apu;

architecture Behavioral of apu is
	component apu_note_to_frequency port(
		data : in std_logic_vector(7 downto 0);
		freq : out std_logic_vector(7 downto 0)); --frequency
	end component;
	component apu_LUT_reader port(
		clk : in std_logic;
		rst : in std_logic;
		wave : in std_logic_vector(1 downto 0);
		level : out std_logic_vector(7 downto 0));
	end component;
begin

end architecture;
