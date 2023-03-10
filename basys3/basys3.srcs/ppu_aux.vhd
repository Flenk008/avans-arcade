library ieee;
library work;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use work.ppu_consts.all;

entity ppu_aux is port(
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
end ppu_aux;

architecture Behavioral of ppu_aux is
	component er_ram
		generic(
			ADDR_W : natural := PPU_AUX_ADDR_WIDTH; -- ADDR line width
			DATA_W : natural := PPU_AUX_DATA_WIDTH; -- DATA line width
			ADDR_LOW : natural := 16#0000#; -- starting address
			ADDR_RANGE : natural := 16#0002#); -- amount of valid addresses after ADDR_LOW
		port(
			CLK : in std_logic; -- clock
			RST : in std_logic; -- async memory clear
			WEN : in std_logic; -- write enable
			ADDR : in std_logic_vector(ADDR_W-1 downto 0);
			DATA : in std_logic_vector(DATA_W-1 downto 0);
			REG : out std_logic_vector((ADDR_RANGE*DATA_W)-1 downto 0)); -- exposed register output
	end component;

	signal INT_REG : std_logic_vector(2 * PPU_AUX_DATA_WIDTH - 1 downto 0);
begin
	-- docs/architecture.md#auxiliary-memory
	FG_FETCH <= INT_REG(17);
	BG_SHIFT_X <= INT_REG(16 downto 8);
	BG_SHIFT_Y <= INT_REG(7 downto 0);

	RAM : component er_ram port map(
		CLK => CLK,
		RST => RESET,
		WEN => AUX_WEN,
		ADDR => AUX_ADDR,
		DATA => AUX_DATA,
		REG => INT_REG);
end Behavioral;
