library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity apu_lut_reader_tb is
end entity;

architecture Behavioral of apu_lut_reader_tb is
    component apu_lut_reader is
        port (
            clk   : in std_logic;
            rst : in std_logic;
            freq : in std_logic_vector(11 downto 0);
            wave : in std_logic_vector(1 downto 0);
            value : out std_logic_vector(7 downto 0)
        );
    end component;

    signal OK : boolean := false;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal freq : std_logic_vector(11 downto 0) := (others => '0');
    signal wave : std_logic_vector(1 downto 0) := (others => '0');

begin

    TB: process
    begin
        wave <= "00";
        for I in 0 to 255 loop
            clk <= '1';

            -- freq <= '1';


            wait for 1 ps;
            clk <= '0';
            wait for 1 ps;


        end loop;
    end process;

end architecture;
