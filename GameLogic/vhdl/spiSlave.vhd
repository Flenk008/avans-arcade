----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2023 21:09:16
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spiSlave is
  Port (    clkBoard : in std_logic; -- clock basys3 100MHz
            clkSPI : in std_logic; -- incoming clock of SPI 
            dataSPI : in std_logic; -- incoming data of SPI
            csSPI : in std_logic;   -- incoming select of SPI
            dataRead : out std_logic_vector(23 downto 0) := (others => '0') --  data read

  );
end spiSlave;

architecture Behavioral of spiSlave is
    signal PulseFF0,PulseFF1,PulseFF2,PulseFF3 : std_logic := '0';     -- signal for metastability synchronizer of clk SPI
    signal dataFF0,dataFF1,dataFF2,dataFF3 : std_logic := '0';          -- signal for metastability synchronizer of data SPI
    signal ssFF0,ssFF1,ssFF2,ssFF3 : std_logic := '0';                  -- signal for metastability synchronizer of slave select SPI
    
    signal data : std_logic_vector(23 downto 0) := (others => '0');      -- signal to store incomming data of dataSPI (2x 8bit)
    signal counter : integer := 23;                                      --counter for data position
    signal enable : std_logic := '0';                                   -- enable signal if slave is selected
begin
    
    process (clkBoard)
    begin
        
        if rising_edge(clkBoard) then       
            -- flip flop for clk SPI to synchronise a
            PulseFF0 <= clkSPI;
            PulseFF1 <= PulseFF0;
            PulseFF2 <= PulseFF1;
            PulseFF3 <= PulseFF2;  
            -- flip flop for data SPI to synchronise      
            dataFF0 <= dataSPI;
            dataFF1 <= dataFF0;
            dataFF2 <= dataFF1;
            dataFF3 <= dataFF2;             
             -- flip flop for slave select SPI to synchronise                  
            ssFF0 <= csSPI;
            ssFF1 <= ssFF0;
            ssFF2 <= ssFF1;
            ssFF3 <= ssFF2; 
            -- check if slave select signal has falling edge (slave is selected by master)    
            if(ssFF3 = '1' and ssFF2 = '0') then
            --reset counter if true
                counter <= 23;
            --disable data read if rising edge (slave is not selected)    
            elsif (ssFF3 = '0' and ssFF2 = '1') then
                enable <= '0';
            end if;            
            --check if synchronised slave select signal is falling edge or data read is enabled
            if(ssFF3 = '1' and ssFF2 = '0') or enable = '1' then
                enable <= '1';                                          --enable data read
                if (PulseFF3 = '0' and PulseFF2 = '1') then             -- check for rising edge of clk SPI
                    if counter > -1 then                                
                        counter <= counter - 1;
                        -- data transfer into vector  
                        data(counter) <= dataFF3;
                    end if;
                end if;
                --check if counter is done
                if counter = -1 then
                    counter <= 23;       --reset counter 
                    dataRead <= data;             
                end if;      
            elsif (enable = '0') then
            --dataRead <= data;
            
            end if;

        end if;

    end process;

end Behavioral;
