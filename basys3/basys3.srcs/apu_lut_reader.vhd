library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity apu_lut_reader is
    port (
        clk : in std_logic;
        rst : in std_logic;
        freq : in std_logic_vector(11 downto 0);
        wave : in std_logic_vector(1 downto 0);
        value : out std_logic_vector(7 downto 0)
    );
end entity;

architecture behavioral of apu_lut_reader is

    constant AMPLITUDE : natural := 0;
    constant SAMPLE_SIZE : natural := 256;

    signal idx : unsigned := (others => '0');
    signal buf : unsigned := (others => '0');
    
begin

    process (clk)
    begin
        if rst = '1' then
            idx <= x"00";
            buf <= x"00";
            value <= x"00";
        elsif rising_edge(clk) then
            -- main code here

            if wave = "00" then     -- Sawtooth
                value <= std_logic_vector( idx );
            elsif wave = "01" then  -- Square
                if idx < (SAMPLE_SIZE/2) then
                    value <= x"00"; --std_logic_vector( SAMPLE_SIZE-AMPLITUDE ); -- TODO: make so that this work with a changable amplitude (for square wave)
                else
                    value <= x"FF";
                end if;
            elsif wave = "10" then  -- Triangle
                if idx < (SAMPLE_SIZE/2) then
                    value <= std_logic_vector( idx*2 );
                else
                    value <= std_logic_vector( (SAMPLE_SIZE-idx)*2 );
                end if;
            else-- wave = "11" then -- Noise
                -- TODO: implement noise function here:
                value <= x"80"; -- remove this
            end if;



            if buf < unsigned(freq) then -- change frequency
                buf <= buf + 1;
            else
                buf <= x"00";
                if idx < (SAMPLE_SIZE-1) then -- moves to next index value
                    idx <= idx + 1;
                else
                    idx <= x"00";
                end if;
            end if;

        end if;
    end process;

end architecture;
