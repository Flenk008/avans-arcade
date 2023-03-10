library ieee;
use ieee.std_logic_1164.all;
use work.ppu_consts.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ppu_vga_tiny is port (
	CLK : in std_logic; -- system clock
	RESET : in std_logic;

	X : out std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
	Y : out std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y

	VSYNC, VBLANK,
	HSYNC, HBLANK : out std_logic); -- VGA sync outputs
end ppu_vga_tiny;

architecture Behavioral of ppu_vga_tiny is
	signal hcount : std_logic_vector(PPU_POS_H_WIDTH-1 downto 0) := (others => '0');
	signal vcount : std_logic_vector(PPU_POS_V_WIDTH-1 downto 0) := (others => '0');
	signal clk_counter : std_logic_vector(4 downto 0) := (others => '0');
begin
	process (CLK)
	begin
		if rising_edge(CLK) then
			clk_counter <= clk_counter + 1;
			if(clk_counter > 15) then
				clk_counter <= (others => '0');
				-- x,y data out
				X <= hcount;
				Y <= vcount;

				--pulse width
				if hcount < 32 or hcount >= 320-80 then
					hsync <= '0';
				else
					hsync <= '1';
				end if;

				if vcount < 8 or vcount >= 240-15 then
					vsync <= '0';
				else
					vsync <= '1';
				end if;

				-- Hblank and Vblank outputs
				if hcount >= 320-80 then
					hblank <= '1';
				else
					hblank <= '0';
				end if;

				if vcount >= 240-15 then
					vblank <= '1';
				else
					vblank <= '0';
				end if;

				-- sync pulse time
				hcount <= hcount + 1;

				if hcount = 400 then
					vcount <= vcount + 1;
					hcount <= (others => '0');
				end if;

				if vcount = 255 then
					vcount <= (others => '0');
				end if;
			end if;
		end if;
	end process;
end Behavioral;
