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
## Botones para enable_a, enable_b, enable_op
## (btnL, btnR, btnU)
## -----------------------
set_property PACKAGE_PIN W19 [get_ports enable_a] ;# btnL
set_property IOSTANDARD LVCMOS33 [get_ports enable_a]

set_property PACKAGE_PIN T17 [get_ports enable_b] ;# btnR
set_property IOSTANDARD LVCMOS33 [get_ports enable_b]

set_property PACKAGE_PIN T18 [get_ports enable_op] ;# btnU
set_property IOSTANDARD LVCMOS33 [get_ports enable_op]

## -----------------------
## Switches (16 disponibles)
## Usamos los 8 LSB para 'data' (puedes ampliar si quieres)
## -----------------------
set_property PACKAGE_PIN V17 [get_ports {data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[0]}]

set_property PACKAGE_PIN V16 [get_ports {data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[1]}]

set_property PACKAGE_PIN W16 [get_ports {data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[2]}]

set_property PACKAGE_PIN W17 [get_ports {data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[3]}]

set_property PACKAGE_PIN W15 [get_ports {data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[4]}]

set_property PACKAGE_PIN V15 [get_ports {data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[5]}]

set_property PACKAGE_PIN W14 [get_ports {data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[6]}]

set_property PACKAGE_PIN W13 [get_ports {data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data[7]}]

## -----------------------
## LEDs (result + flags)
## -----------------------
set_property PACKAGE_PIN U16 [get_ports {result[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {result[0]}]

set_property PACKAGE_PIN E19 [get_ports {result[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {result[1]}]

set_property PACKAGE_PIN U19 [get_ports {result[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {result[2]}]

set_property PACKAGE_PIN V19 [get_ports {result[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {result[3]}]

set_property PACKAGE_PIN W18 [get_ports {result[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {result[4]}]

set_property PACKAGE_PIN U15 [get_ports {result[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {result[5]}]

set_property PACKAGE_PIN U14 [get_ports {result[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {result[6]}]

set_property PACKAGE_PIN V14 [get_ports {result[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {result[7]}]

## LED extra para carry
set_property PACKAGE_PIN N3 [get_ports carry]
set_property IOSTANDARD LVCMOS33 [get_ports carry]

## LED extra para zero
set_property PACKAGE_PIN L1 [get_ports zero]
set_property IOSTANDARD LVCMOS33 [get_ports zero]
