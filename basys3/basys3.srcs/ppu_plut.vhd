library ieee;
use ieee.std_logic_1164.all;
use work.ppu_consts.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ppu_plut is port ( 
	CLK : in std_logic; -- system clock
	CIDX : in std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0); -- color in
	RESET : in std_logic;

	-- internal memory block (AUX)
	PAL_WEN : in std_logic; -- VRAM PAL write enable
	PAL_ADDR : in std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0); -- VRAM PAL address
	PAL_DATA : in std_logic_vector(PPU_PAL_DATA_WIDTH-1 downto 0); -- VRAM PAL data

	R,G,B : out std_logic_vector(PPU_COLOR_OUTPUT_DEPTH-1 downto 0)); -- VGA color out
end ppu_plut;

architecture Behavioral of ppu_plut is
	component er_ram
		generic(
			ADDR_W : natural := PPU_PAL_ADDR_WIDTH; -- ADDR line width
			DATA_W : natural := PPU_PAL_DATA_WIDTH; -- DATA line width
			ADDR_LOW : natural := 16#0000#; -- starting address
			ADDR_RANGE : natural := 16#0040#); -- amount of valid addresses after ADDR_LOW
		port(
			CLK : in std_logic; -- clock
			RST : in std_logic; -- async memory clear
			WEN : in std_logic; -- write enable
			ADDR : in std_logic_vector(ADDR_W-1 downto 0);
			DATA : in std_logic_vector(DATA_W-1 downto 0);
			REG : out std_logic_vector((ADDR_RANGE*DATA_W)-1 downto 0)); -- exposed register output
	end component;
	
	signal PLUT : std_logic_vector((64 * PPU_PAL_DATA_WIDTH)-1 downto 0) := (others => '0');
	signal CHECK_ZERO_CIDX : std_logic_vector(PPU_PALETTE_CIDX_WIDTH-1 downto 0) := (others => '0'); -- color in
begin
	RAM : component er_ram port map(
		CLK => CLK,
		RST => RESET,
		WEN => PAL_WEN,
		ADDR => PAL_ADDR,
		DATA => PAL_DATA,
		REG => PLUT);

	process(CLK, RESET)
		variable COLOR : std_logic_vector(PPU_PAL_DATA_WIDTH-1 downto 0) := (others => '0'); -- COLORS RGB IN
		variable CIDX_INT : integer := 0;
	begin
		if RESET = '1' then
			PLUT <= (others => '0');
		else
			if rising_edge (CLK) then
				if (CIDX /= CHECK_ZERO_CIDX) then
					CIDX_INT := to_integer(unsigned(CIDX));
					COLOR := PLUT((12 * CIDX_INT) + 11 downto (12*CIDX_INT));
					R <= COLOR(11 downto  8);
					G <= COLOR(7 downto 4);
					B <= COLOR(3 downto 0);
				else
					R <= x"0";
					G <= x"0";
					B <= x"0";
				end if;
			end if;
		end if;
	end process;
end Behavioral;
