library ieee;
library work;
library unisim;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;
use work.ppu_consts.all;

entity ppu_sprite_bg_tb is
end ppu_sprite_bg_tb;

architecture Behavioral of ppu_sprite_bg_tb is
	component ppu_sprite_bg port(
		-- inputs
		CLK : in std_logic; -- pipeline clock
		RESET : in std_logic; -- reset clock counter
		OE : in std_logic; -- output enable (of CIDX)
		X : in std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
		Y : in std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y
		
		-- aux inputs
		BG_SHIFT_X : in std_logic_vector(PPU_POS_H_WIDTH-1 downto 0);
		BG_SHIFT_Y : in std_logic_vector(PPU_POS_V_WIDTH-1 downto 0);

		-- used memory blocks
		BAM_ADDR : out std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
		BAM_DATA : in std_logic_vector(PPU_BAM_DATA_WIDTH-1 downto 0);
		TMM_ADDR : out std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
		TMM_DATA : in std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0);

		-- outputs
		CIDX : out std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0)); -- output color
	end component;
	signal CLK : std_logic := '0'; -- pipeline clock
	signal RESET : std_logic := '0'; -- reset clock counter
	signal OE : std_logic := '0'; -- output enable (of CIDX)
	signal X : std_logic_vector(PPU_POS_H_WIDTH-1 downto 0) := (others => '0'); -- current screen pixel x
	signal Y : std_logic_vector(PPU_POS_V_WIDTH-1 downto 0) := (others => '0'); -- current screen pixel y
	signal BG_SHIFT_X : std_logic_vector(PPU_POS_H_WIDTH-1 downto 0) := (others => '0');
	signal BG_SHIFT_Y : std_logic_vector(PPU_POS_V_WIDTH-1 downto 0) := (others => '0');
	signal BAM_ADDR : std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
	signal BAM_DATA : std_logic_vector(PPU_BAM_DATA_WIDTH-1 downto 0) := (others => '0');
	signal TMM_ADDR : std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
	signal TMM_DATA : std_logic_vector(PPU_TMM_DATA_WIDTH-1 downto 0) := (others => '0');
	signal CIDX : std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0); -- output color
begin
	uut : ppu_sprite_bg port map(
		CLK => CLK,
		RESET => RESET,
		OE => OE,
		X => X,
		Y => Y,
		BG_SHIFT_X => BG_SHIFT_X,
		BG_SHIFT_Y => BG_SHIFT_Y,
		BAM_ADDR => BAM_ADDR,
		BAM_DATA => BAM_DATA,
		TMM_ADDR => TMM_ADDR,
		TMM_DATA => TMM_DATA,
		CIDX => CIDX);

	-- inputs
	-- BAM_DATA -> FLIP_H + palette index 2 + tilemap index 10
	-- TMM_DATA -> all pixels color 7
	-- X -> 25
	-- Y -> 60
	-- BG_SHIFT_X -> 3
	-- BG_SHIFT_Y -> 3
	BAM_DATA <= 15x"4814"; -- hex((1 << 14) | (0 << 13) | (2 << 10) | (20 << 0))
	TMM_DATA <= 15x"7e3f"; -- hex(0x7fff & ~(0b111 << 6))
	X <= std_logic_vector(to_unsigned(25, PPU_POS_H_WIDTH));
	Y <= std_logic_vector(to_unsigned(60, PPU_POS_V_WIDTH));
	BG_SHIFT_X <= std_logic_vector(to_unsigned(3, PPU_POS_H_WIDTH));
	BG_SHIFT_Y <= std_logic_vector(to_unsigned(3, PPU_POS_V_WIDTH));

	-- expected outputs:
	-- absolute pixel coordinates -> (28, 63)
	-- absolute background canvas tile index coordinates -> (1, 3)
	-- tile index -> 3 * 40 + 1 = 121
	-- BAM_ADDR => 121 (OK)
	-- sprite local coordinates -> (12, 15)
	-- transformed local coordinates -> (12, 0) (apply FLIP_H)
	-- pixel index -> 0 * 16 + 12 = 12
	-- pixel word address -> 52 * 20 + 12//5 -> 1042
	-- TMM_ADDR => 1042 (OK)
	-- pixel bits -> [pixel n+] = 12 % 5 = 2 -> 8 downto 6
	-- cidx should be -- (2 << 3) | (0 << 0) = 16
	-- CIDX => 16 (OK)

	tb : process
	begin
		for i in 0 to 32 loop
			if i > 10 then
				OE <= '1';
			end if;
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
end Behavioral;
