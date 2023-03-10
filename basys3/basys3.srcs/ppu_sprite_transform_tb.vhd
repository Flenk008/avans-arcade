library ieee;
library unisim;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;
use work.ppu_consts.all;

entity ppu_sprite_transform_tb is
end ppu_sprite_transform_tb;

architecture behavioral of ppu_sprite_transform_tb is
	component ppu_sprite_transform port( -- flip sprites
		XI : in unsigned(PPU_SPRITE_POS_H_WIDTH-1 downto 0); -- pixel position relative to tile
		YI : in unsigned(PPU_SPRITE_POS_V_WIDTH-1 downto 0); -- pixel position relative to tile
		FLIP_H, FLIP_V : in std_logic; -- flip sprite
		XO : out unsigned(PPU_SPRITE_POS_H_WIDTH-1 downto 0); -- new pixel position relative to tile
		YO : out unsigned(PPU_SPRITE_POS_V_WIDTH-1 downto 0)); -- new pixel position relative to tile
	end component;

	signal XI : unsigned(PPU_SPRITE_POS_H_WIDTH-1 downto 0);
	signal YI : unsigned(PPU_SPRITE_POS_V_WIDTH-1 downto 0);
	signal FLIP_H, FLIP_V : std_logic := '0';
	signal XO : unsigned(PPU_SPRITE_POS_H_WIDTH-1 downto 0);
	signal YO : unsigned(PPU_SPRITE_POS_V_WIDTH-1 downto 0);
begin
	uut : component ppu_sprite_transform
		port map(
			XI => XI,
			YI => YI,
			FLIP_H => FLIP_H,
			FLIP_V => FLIP_V,
			XO => XO,
			YO => YO);

	tb : process
	begin
		XI <= to_unsigned(4, PPU_SPRITE_POS_H_WIDTH);
		YI <= to_unsigned(6, PPU_SPRITE_POS_V_WIDTH);
		wait for 5 ns;

		XI <= to_unsigned(2, PPU_SPRITE_POS_H_WIDTH);
		YI <= to_unsigned(14, PPU_SPRITE_POS_V_WIDTH);
		wait for 5 ns;

		FLIP_H <= '1';
		wait for 5 ns;

		FLIP_V <= '1';
		wait for 5 ns;

		XI <= to_unsigned(6, PPU_SPRITE_POS_H_WIDTH);
		YI <= to_unsigned(8, PPU_SPRITE_POS_V_WIDTH);
		wait for 5 ns;

		FLIP_H <= '0';
		wait for 5 ns;

		XI <= to_unsigned(2, PPU_SPRITE_POS_H_WIDTH);
		YI <= to_unsigned(14, PPU_SPRITE_POS_V_WIDTH);
		wait for 5 ns;

		wait; -- stop for simulator
	end process;
end;
