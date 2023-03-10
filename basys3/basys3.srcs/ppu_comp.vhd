library ieee;
use ieee.std_logic_1164.all;
use work.ppu_consts.all;

entity ppu_comp is port ( 
	FG_HIT : in std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0);
	BG_EN : out std_logic;
	FG_EN : out std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0));
end ppu_comp;

architecture Behavioral of ppu_comp is
	signal FG_HIT_EMPTY : std_logic_vector(PPU_FG_SPRITE_COUNT-1 downto 0) := (others => '0');
begin
	process (FG_HIT)
		variable HIT : boolean := false;
	begin
		-- check if FG_HIT is not empty
		if FG_HIT /= FG_HIT_EMPTY then
			BG_EN <= '0';
			for i in 0 to PPU_FG_SPRITE_COUNT-1 loop
				-- if FG_HIT is the first one then enable it
				if(FG_HIT(i) = '1' and HIT = false) then
					FG_EN(i) <= '1';
					HIT := true;
				else
					-- make rest low
					FG_EN(i) <= '0';
				end if;
			end loop;
			HIT := false;
		else
			BG_EN <= '1';
			FG_EN <= (others => '0');
		end if;
	end process;
end Behavioral;
