library ieee;
library unisim;
use ieee.std_logic_1164.all;
use work.ppu_consts.all;
use unisim.vcomponents.all;

entity ppu_comp_tb is
end ppu_comp_tb;

architecture behavioral of ppu_comp_tb is
	component ppu_comp port (
		FG_HIT : in std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0);
		BG_EN : out std_logic;
		FG_EN : out std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0));
	end component;
	signal FG_HIT : std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0) := (others => '0');
	signal BG_EN : std_logic := '0';
	signal FG_EN : std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0) := (others => '0');
begin
	uut : ppu_comp port map (
		FG_HIT => FG_HIT,
		BG_EN => BG_EN,
		FG_EN => FG_EN
	);
	tb : process
	begin
		FG_HIT <= (others => '0');
		wait for 1 ps;
		FG_HIT(6) <= '1';
		FG_HIT(5) <= '1';
		FG_HIT(100) <= '1';
		wait for 1 ps;

		FG_HIT(0) <= '1';
		wait for 1 ps;
		FG_HIT <= (others => '0');
		wait for 1 ps;
		wait;
	end process;
end Behavioral;
