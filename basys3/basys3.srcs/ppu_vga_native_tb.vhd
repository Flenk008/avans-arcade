library ieee;
library unisim;
use ieee.std_logic_1164.all;
use work.ppu_consts.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use unisim.vcomponents.all;

entity ppu_vga_native_tb is
end ppu_vga_native_tb;

architecture Behavioral of ppu_vga_native_tb is
	component ppu_vga_native port (
		CLK : in std_logic; -- system clock
		RESET : in std_logic;

		X : in std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
		Y : in std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y
		PREADY : in std_logic; -- current pixel ready (pixel color is stable)
		RI,GI,BI : in std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0); -- VGA color in

		RO,GO,BO : out std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0); -- VGA color out
		VSYNC, HSYNC : out std_logic); -- VGA sync outputs
	end component;
	signal CLK : std_logic := '0';
	signal RST : std_logic := '0';
	signal PREADY : std_logic := '0';

	signal X : std_logic_vector(PPU_POS_H_WIDTH-1 downto 0) := (others => '0');
	signal Y : std_logic_vector(PPU_POS_V_WIDTH-1 downto 0) := (others => '0');

	signal RI,GI,BI : std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0) := (others => '0'); -- VGA color in
	signal RO,GO,BO : std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0) := (others => '0'); -- VGA color out
	signal VSYNC, HSYNC :  std_logic := '0';

	signal Xas : integer := 72;
	signal Yas : integer := 14;
	signal counter : std_logic_vector(1 downto 0) := (others => '0');
begin
	uut : ppu_vga_native port map(
		CLK => CLK,
		RESET => RST,
		X => X,
		Y => Y,
		PREADY => PREADY,
		RI => RI,
		GI => GI,
		BI => BI,
		RO => RO,
		GO => GO,
		BO => BO,
		VSYNC => VSYNC,
		HSYNC => HSYNC
	);

	tb : process
	begin
		CLK <= '1';
		wait for 1 ps;
		CLK <= '0';
		wait for 1 ps;
	end process;

	process(CLK)
	begin
		if rising_edge(CLK) then
			counter <= counter + 1;
		end if;

		if(counter = "11") then
			pready <= '1';
			ri <= x"d";
			gi <= x"a";
			bi <= x"d";
			x <= std_logic_vector(to_unsigned(Xas, x'length));
			if (Xas = 391) then
				Xas <= 72;
				y <= std_logic_vector(to_unsigned(Yas, y'length));
				if (Yas = 255) then
					Yas <= 14;
				else
					Yas <= Yas + 1;
				end if;
			else
				Xas <= Xas + 1;
			end if;
		end if;
	end process;
end Behavioral;
