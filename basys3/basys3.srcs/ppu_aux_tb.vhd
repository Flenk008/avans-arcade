library ieee;
library unisim;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;
use work.ppu_consts.all;

entity ppu_aux_tb is
end ppu_aux_tb;

architecture behavioral of ppu_aux_tb is
	component ppu_aux port(
		CLK : in std_logic; -- system clock
		RESET : in std_logic; -- reset memory

		-- internal memory block (AUX)
		AUX_WEN : in std_logic; -- VRAM AUX write enable
		AUX_ADDR : in std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0); -- VRAM AUX address
		AUX_DATA : in std_logic_vector(PPU_AUX_DATA_WIDTH-1 downto 0); -- VRAM AUX data
		
		-- aux outputs
		BG_SHIFT_X : out std_logic_vector(PPU_POS_H_WIDTH-1 downto 0);
		BG_SHIFT_Y : out std_logic_vector(PPU_POS_V_WIDTH-1 downto 0);
		FG_FETCH : out std_logic);
	end component;

	signal CLK, RST, WEN : std_logic := '0';
	signal ADDR : std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0) := (others => '0');
	signal DATA : std_logic_vector(PPU_AUX_DATA_WIDTH-1 downto 0) := (others => '0');

	signal BG_SHIFT_X : std_logic_vector(PPU_POS_H_WIDTH-1 downto 0);
	signal BG_SHIFT_Y : std_logic_vector(PPU_POS_V_WIDTH-1 downto 0);
	signal FG_FETCH : std_logic;
begin
	uut : component ppu_aux
		port map(
			CLK => CLK,
			RESET => RST,
			AUX_WEN => WEN,
			AUX_ADDR => ADDR,
			AUX_DATA => DATA,
			BG_SHIFT_X => BG_SHIFT_X,
			BG_SHIFT_Y => BG_SHIFT_Y,
			FG_FETCH => FG_FETCH);

	tb : process
	begin
		-- reset
		RST <= '1';
		wait for 5 ns;
		RST <= '0';
		wait for 5 ns;

		WEN <= '1';
		-- set BG_SHIFT_X to 178
		-- set BG_SHIFT_Y to 39
		-- set FG_FETCH to 1
		ADDR(0) <= '0';
		DATA <= x"b327";

		CLK <= '1';
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;

		ADDR(0) <= '1';
		DATA <= x"0002";

		CLK <= '1';
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;

		wait for 5 ns;

		-- set BG_SHIFT_X to 30
		-- set BG_SHIFT_Y to 69
		-- set FG_FETCH to 0
		ADDR(0) <= '0';
		DATA <= x"1e45";

		CLK <= '1';
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;

		ADDR(0) <= '1';
		DATA <= x"0000";

		CLK <= '1';
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;


		wait; -- stop for simulator
	end process;
end;
