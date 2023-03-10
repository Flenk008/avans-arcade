library ieee;
use ieee.std_logic_1164.all;
use work.ppu_consts.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ppu_vga_native is port (
	CLK: in std_logic; -- system clock
	RESET: in std_logic;

	X: in std_logic_vector(PPU_POS_H_WIDTH-1 downto 0); -- current screen pixel x
	Y: in std_logic_vector(PPU_POS_V_WIDTH-1 downto 0); -- current screen pixel y
	PREADY: in std_logic; -- current pixel ready (pixel color is stable)
	RI,GI,BI: in std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0); -- VGA color in

	RO,GO,BO: out std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0); -- VGA color out
	VSYNC, HSYNC: out std_logic); -- VGA sync outputs
end ppu_vga_native;

architecture Behavioral of ppu_vga_native is
	type line_buffer is array(319 downto 0) of std_logic_vector(11 downto 0);
	signal ram_x0 : line_buffer; -- buffer 0
	signal ram_x1: line_buffer; -- buffer 1
	signal hcount: std_logic_vector(9 downto 0):= (others => '0');
	signal vcount: std_logic_vector(9 downto 0):= (others => '0');
	signal clk_counter: std_logic_vector(1 downto 0):= (others => '0');
	signal rgb_out : std_logic_vector(11 downto 0):= (others => '0'); -- output colors
	signal px : integer; -- conversion for hcount
	signal py :integer; -- conversion for vcount
	signal buffer_filled_on_buffer0 : integer;
	signal buffer_filled_on_buffer1 : integer;
begin
	process (clk, x, y)
		variable v_x : integer; -- integer to hold vector X
	begin
		if rising_edge(clk) then
			clk_counter <= clk_counter + 1;
			if clk_counter = "11" then
				v_x := to_integer(unsigned(x) - 72);
				if v_x >= 0 and v_x < 320 and PREADY = '1' then
					if y(0) = '0' then
						ram_x0(v_x) <= RI & GI & BI;
						if v_x = 319 then
							buffer_filled_on_buffer0 <= to_integer(unsigned(y) - 14);
						end if;
					else
						ram_x1(v_x) <= RI & GI & BI;
						if v_x = 319 then
							buffer_filled_on_buffer1 <= to_integer(unsigned(y) - 14);
						end if;
					end if;
				end if;
				-- T display(display data)
				if (hcount >= 144) and (hcount < 784) and (vcount >= 31) and (vcount < 511) then
					px <= to_integer(unsigned(hcount) - 144);
					py <= to_integer(unsigned(vcount) - 31);
					if buffer_filled_on_buffer0 = (py/2) then
						rgb_out <= ram_x0(px/2);
					elsif buffer_filled_on_buffer1 = (py/2) then
						rgb_out <= ram_x1(px/2);
					else
						rgb_out <= (others => '0');
					end if;
				end if;
				-- pulse width
				hsync <= '1';
				if hcount < 97 then
					hsync <= '0';
				end if;

				vsync <= '1';
				if vcount < 3 then
					vsync <= '0';
				end if;

				-- sync pulse time
				hcount <= hcount + 1;

				if hcount = 800 then
					vcount <= vcount + 1;
					hcount <= (others => '0');
				end if;

				if vcount = 521 then
					vcount <= (others => '0');
				end if;
			end if;

			-- output colors
		RO <= rgb_out(11 downto 8);
		GO <= rgb_out(7 downto 4);
		BO <= rgb_out(3 downto 0);
		end if;
	end process;
end Behavioral;
