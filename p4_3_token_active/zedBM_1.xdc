create_clock -period 10.000 -name pllclk [get_ports clk_pll]
create_generated_clock -name clk -source [get_ports clk_pll] -divide_by 120 [get_pins clk_div/o_div_clk]
#create_clock -period 30.000 -name clk [get_ports clk]
#set_input_delay -clock clk -min 2.000 [get_ports clk_pll]
#set_input_delay -clock clk -max 1.000 [get_ports rst]


#set_output_delay -clock clk -min 5.000 [get_ports o_Tx_Serial]

#set_min_delay -from [get_ports rst] -to [get_cells rst_d1_f_reg]

#set_property PACKAGE_PIN Y9 [get_ports clock]
#set_property IOSTANDARD LVCMOS33 [get_ports clock]
#set_property PACKAGE_PIN T22 [get_ports o_Tx_Serial]
#set_property IOSTANDARD LVCMOS33 [get_ports o_Tx_Serial]
#set_property PACKAGE_PIN F22 [get_ports rst]
#set_property IOSTANDARD LVCMOS25 [get_ports rst]

set_property PACKAGE_PIN F22 [get_ports rst]
set_property IOSTANDARD LVCMOS25 [get_ports rst]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rst_IBUF]


set_property PACKAGE_PIN Y9 [get_ports clk_pll]
set_property IOSTANDARD LVCMOS33 [get_ports clk_pll]
set_property IOSTANDARD LVCMOS33 [get_ports o_Tx_Serial]


set_property PACKAGE_PIN G22 [get_ports rst_pll]
set_property IOSTANDARD LVCMOS25 [get_ports rst_pll]


set_property PACKAGE_PIN T22 [get_ports {o_byte_w[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_byte_w[7]}]
set_property PACKAGE_PIN T21 [get_ports {o_byte_w[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_byte_w[6]}]
set_property PACKAGE_PIN U22 [get_ports {o_byte_w[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_byte_w[5]}]
set_property PACKAGE_PIN U21 [get_ports {o_byte_w[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_byte_w[4]}]
set_property PACKAGE_PIN V22 [get_ports {o_byte_w[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_byte_w[3]}]
set_property PACKAGE_PIN W22 [get_ports {o_byte_w[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_byte_w[2]}]
set_property PACKAGE_PIN U19 [get_ports {o_byte_w[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_byte_w[1]}]
set_property PACKAGE_PIN U14 [get_ports {o_byte_w[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {o_byte_w[0]}]
set_property PACKAGE_PIN Y15 [get_ports o_Tx_Serial]
