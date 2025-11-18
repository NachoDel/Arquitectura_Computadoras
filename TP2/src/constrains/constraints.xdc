## =====================================================
## Basys3 Constraints para ALU (top_module)
## FPGA: XC7A35T-1CPG236C
## =====================================================

## =====================================================
## Basys3 Constraints para ALU (top_module)
## FPGA: XC7A35T-1CPG236C
## =====================================================

## -----------------------
## Clock (100 MHz onboard)
## -----------------------
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk -waveform {0 5} [get_ports clk]

## -----------------------
## Botón Reset (btnC)
## -----------------------
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## -----------------------
## UART pins
## -----------------------
set_property PACKAGE_PIN B18 [get_ports rx]
set_property IOSTANDARD LVCMOS33 [get_ports rx]
# RX idles high, enable pull-up to ensure idle state when disconnected
set_property PULLUP true [get_ports rx]

set_property PACKAGE_PIN A18 [get_ports tx]
set_property IOSTANDARD LVCMOS33 [get_ports tx]

## -----------------------
## LED tx_done y tx_start
## -----------------------
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]