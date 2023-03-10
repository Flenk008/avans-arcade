library ieee;
library work;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use work.ppu_consts.all;

entity ppu_addr_dec is port(
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
end ppu_addr_dec;

architecture Behavioral of ppu_addr_dec is
	signal TMM_RANGE, BAM_RANGE, FAM_RANGE, PAL_RANGE, AUX_RANGE : std_logic := '0'; -- ADDR in range of memory area
begin
	-- address MUX
	TMM_AO <= ADDR(PPU_TMM_ADDR_WIDTH-1 downto 0) when EN = '1' else TMM_AI;
	BAM_AO <= ADDR(PPU_BAM_ADDR_WIDTH-1 downto 0) when EN = '1' else BAM_AI;
	FAM_AO <= ADDR(PPU_FAM_ADDR_WIDTH-1 downto 0) when EN = '1' else FAM_AI;
	PAL_AO <= ADDR(PPU_PAL_ADDR_WIDTH-1 downto 0) when EN = '1' else PAL_AI;
	AUX_AO <= ADDR(PPU_AUX_ADDR_WIDTH-1 downto 0) when EN = '1' else AUX_AI;

	-- WEN MUX
	TMM_WEN <= TMM_RANGE and WEN;
	BAM_WEN <= BAM_RANGE and WEN;
	FAM_WEN <= FAM_RANGE and WEN;
	PAL_WEN <= PAL_RANGE and WEN;
	AUX_WEN <= AUX_RANGE and WEN;

	-- address ranges
	TMM_RANGE <= '1' when not ((ADDR(15) and ADDR(14) and ADDR(13)) or (ADDR(15) and ADDR(14) and ADDR(12))) else '0';
	BAM_RANGE <= '1' when TMM_RANGE = '0' and (ADDR(11) = '0') else '0';
	FAM_RANGE <= '1' when TMM_RANGE = '0' and (ADDR(11) = '1' and ADDR(10) = '0') else '0';
	PAL_RANGE <= '1' when TMM_RANGE = '0' and (ADDR(11) = '1' and ADDR(10) = '1' and ADDR(9) = '0') else '0';
	AUX_RANGE <= '1' when TMM_RANGE = '0' and (ADDR(11) = '1' and ADDR(10) = '1' and ADDR(9) = '1') else '0';
end Behavioral;
