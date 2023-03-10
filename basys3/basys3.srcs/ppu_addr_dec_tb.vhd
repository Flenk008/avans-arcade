library ieee;
library unisim;
library work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;
use work.ppu_consts.all;

entity ppu_addr_dec_tb is
end ppu_addr_dec_tb;

architecture behavioral of ppu_addr_dec_tb is
	component ppu_addr_dec port(
		EN : in std_logic; -- EXT *ADDR enable (switch *AO to ADDR instead of *AI)
		WEN : in std_logic; -- EXT write enable
		TMM_WEN,
		BAM_WEN,
		FAM_WEN,
		PAL_WEN,
		AUX_WEN : out std_logic; -- write enable MUX
		ADDR : in std_logic_vector(PPU_RAM_BUS_ADDR_WIDTH-1 downto 0); -- address in
		TMM_AI : in std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
		BAM_AI : in std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
		FAM_AI : in std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0);
		PAL_AI : in std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0);
		AUX_AI : in std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0);
		TMM_AO : out std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
		BAM_AO : out std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
		FAM_AO : out std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0);
		PAL_AO : out std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0);
		AUX_AO : out std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0));
	end component;
	signal EN : std_logic;
	signal WEN : std_logic;
	signal TMM_WEN, BAM_WEN, FAM_WEN, PAL_WEN, AUX_WEN : std_logic;
	signal ADDR : std_logic_vector(PPU_RAM_BUS_ADDR_WIDTH-1 downto 0);
	signal TMM_AI : std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
	signal BAM_AI : std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
	signal FAM_AI : std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0);
	signal PAL_AI : std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0);
	signal AUX_AI : std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0);
	signal TMM_AO : std_logic_vector(PPU_TMM_ADDR_WIDTH-1 downto 0);
	signal BAM_AO : std_logic_vector(PPU_BAM_ADDR_WIDTH-1 downto 0);
	signal FAM_AO : std_logic_vector(PPU_FAM_ADDR_WIDTH-1 downto 0);
	signal PAL_AO : std_logic_vector(PPU_PAL_ADDR_WIDTH-1 downto 0);
	signal AUX_AO : std_logic_vector(PPU_AUX_ADDR_WIDTH-1 downto 0);
begin
	uut : ppu_addr_dec port map(
    EN => EN,
    WEN => WEN,
    TMM_WEN => TMM_WEN,
    BAM_WEN => BAM_WEN,
    FAM_WEN => FAM_WEN,
    PAL_WEN => PAL_WEN,
    AUX_WEN => AUX_WEN,
    ADDR => ADDR,
    TMM_AI => TMM_AI,
    BAM_AI => BAM_AI,
    FAM_AI => FAM_AI,
    PAL_AI => PAL_AI,
    AUX_AI => AUX_AI,
    TMM_AO => TMM_AO,
    BAM_AO => BAM_AO,
    FAM_AO => FAM_AO,
    PAL_AO => PAL_AO,
    AUX_AO => AUX_AO);

  EN <= '1';
  WEN <= '1';

  TMM_AI <= (others => '1');
  BAM_AI <= (others => '0');
  FAM_AI <= (others => '1');
  PAL_AI <= (others => '0');
  AUX_AI <= (others => '0');

	tb : process
	begin
		for i in 0 to 65535 loop
      ADDR <= std_logic_vector(to_unsigned(i,16));
      wait for 10 ps;
		end loop;
		wait; -- stop for simulator
	end process;
end;
