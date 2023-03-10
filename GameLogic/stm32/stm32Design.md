Pin layout 

| pin STM | function |
|---------|----------|
| PA5 / D13 | SPI clock |
| PA7 / D11 | SPI MOSI |
| PA9 / D8 | SPI cs |
| PB4 / D5 | button 1 |
| PB5 / D4 | button 2 |
| PB6 / D10 | button 3 |
| PB8 / D15 | button 4 |

| pin FPGA | function |
|---------|----------|
| JB 7 | SPI clock |
| JB 8 | SPI data |
| JB 9 | SPI cs |



constraints:

set_property PACKAGE_PIN A15 [get_ports clkSPI] 

set_property PACKAGE_PIN C15 [get_ports csSPI] 

set_property PACKAGE_PIN A17 [get_ports dataSPI] 

set_property IOSTANDARD LVCMOS33 [get_ports dataSPI] 

set_property IOSTANDARD LVCMOS33 [get_ports csSPI] 

set_property IOSTANDARD LVCMOS33 [get_ports clkSPI] .
