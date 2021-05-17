
# ltc2387

set_property -dict {PACKAGE_PIN D18    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports ref_clk_p]       ; ## G02  FMC_LPC_CLK1_M2C_P
set_property -dict {PACKAGE_PIN C19    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports ref_clk_n]       ; ## G03  FMC_LPC_CLK1_M2C_N
set_property -dict {PACKAGE_PIN M19    IOSTANDARD LVDS_25 } [get_ports clk_p]                         ; ## G06  FMC_LPC_LA00_CC_P
set_property -dict {PACKAGE_PIN M20    IOSTANDARD LVDS_25 } [get_ports clk_n]                         ; ## G07  FMC_LPC_LA00_CC_N
set_property -dict {PACKAGE_PIN L18    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports dco_p]           ; ## H04  FMC_LPC_CLK0_M2C_P
set_property -dict {PACKAGE_PIN L19    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports dco_n]           ; ## H05  FMC_LPC_CLK0_M2C_N
set_property -dict {PACKAGE_PIN P17    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports da_p]            ; ## H07  FMC_LPC_LA02_P
set_property -dict {PACKAGE_PIN P18    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports da_n]            ; ## H08  FMC_LPC_LA02_N
set_property -dict {PACKAGE_PIN M21    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports db_p]            ; ## H10  FMC_LPC_LA04_P
set_property -dict {PACKAGE_PIN M22    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports db_n]            ; ## H11  FMC_LPC_LA04_N
set_property -dict {PACKAGE_PIN N19    IOSTANDARD LVDS_25} [get_ports cnv_p]                          ; ## D08  FMC_LPC_LA01_CC_P
set_property -dict {PACKAGE_PIN N20    IOSTANDARD LVDS_25} [get_ports cnv_n]                          ; ## D09  FMC_LPC_LA01_CC_N

# clocks

create_clock -name dco     -period  4.762   [get_ports dco_p]
create_clock -name ref_clk -period 10.000   [get_ports ref_clk_p]

# input delays
set_input_delay -clock [get_clocks dco] -min -2.0 [get_ports da_p]
set_input_delay -clock [get_clocks dco] -max -2.5 [get_ports da_n]
set_input_delay -clock [get_clocks dco] -min -2.0 [get_ports db_p]
set_input_delay -clock [get_clocks dco] -max -2.5 [get_ports db_n]

# false paths

# dco is generated from the axi_clkgen, it is an echoed clock axi_clkgen/clk0
set_false_path -from [get_clocks dco] -to [get_clocks -of_objects [get_pins i_system_wrapper/system_i/axi_clkgen/inst/i_mmcm_drp/i_mmcm/CLKOUT0]]
# an IDDR is inferred
set_false_path -from [get_ports da_p] -to [get_pins {i_system_wrapper/system_i/util_ltc2387/inst/adc_data_da_p_reg[0]adc_data_da_n_reg[0]/D}]
set_false_path -from [get_ports db_p] -to [get_pins {i_system_wrapper/system_i/util_ltc2387/inst/adc_data_db_p_reg[0]adc_data_db_n_reg[0]/D}]
