
# ltc2387

# debug ports
#set_property -dict {PACKAGE_PIN W8     IOSTANDARD LVCMOS33} [get_ports db_out      ] ; ## JB4 da_n
#set_property -dict {PACKAGE_PIN V10    IOSTANDARD LVCMOS33} [get_ports da_out      ] ; ## JB3 da_p
#set_property -dict {PACKAGE_PIN W11    IOSTANDARD LVCMOS33} [get_ports s_clk_out    ] ; ## JB2
#set_property -dict {PACKAGE_PIN W12    IOSTANDARD LVCMOS33} [get_ports dco_out     ] ; ## JB1
#
#set_property -dict {PACKAGE_PIN AA9    IOSTANDARD LVCMOS33} [get_ports test_pat    ] ; ## JA4
#set_property -dict {PACKAGE_PIN Y10    IOSTANDARD LVCMOS33} [get_ports two_lanes   ] ; ## JA3
#set_property -dict {PACKAGE_PIN AA11   IOSTANDARD LVCMOS33} [get_ports cnv_out     ] ; ## JA2
#set_property -dict {PACKAGE_PIN Y11    IOSTANDARD LVCMOS33} [get_ports clk_gate_out] ; ## JA1
# end of debug ports

set_property -dict {PACKAGE_PIN D18    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports ref_clk_p] ; ## G02  FMC_LPC_CLK1_M2C_P
set_property -dict {PACKAGE_PIN C19    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports ref_clk_n] ; ## G03  FMC_LPC_CLK1_M2C_N
set_property -dict {PACKAGE_PIN M19    IOSTANDARD LVDS_25 } [get_ports clk_p]                   ; ## G06  FMC_LPC_LA00_CC_P
set_property -dict {PACKAGE_PIN M20    IOSTANDARD LVDS_25 } [get_ports clk_n]                   ; ## G07  FMC_LPC_LA00_CC_N
set_property -dict {PACKAGE_PIN L18    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports dco_p]     ; ## H04  FMC_LPC_CLK0_M2C_P
set_property -dict {PACKAGE_PIN L19    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports dco_n]     ; ## H05  FMC_LPC_CLK0_M2C_N
set_property -dict {PACKAGE_PIN P17    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports da_p]       ; ## H07  FMC_LPC_LA02_P
set_property -dict {PACKAGE_PIN P18    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports da_n]       ; ## H08  FMC_LPC_LA02_N
set_property -dict {PACKAGE_PIN M21    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports db_p]       ; ## H10  FMC_LPC_LA04_P
set_property -dict {PACKAGE_PIN M22    IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports db_n]       ; ## H11  FMC_LPC_LA04_N
set_property -dict {PACKAGE_PIN N19    IOSTANDARD LVDS_25} [get_ports cnv_p]      ; ## D08  FMC_LPC_LA01_CC_P
set_property -dict {PACKAGE_PIN N20    IOSTANDARD LVDS_25} [get_ports cnv_n]      ; ## D09  FMC_LPC_LA01_CC_N
#set_property -dict {PACKAGE_PIN N22    IOSTANDARD LVCMOS25} [get_ports pll_sync_fmc]           ; ## G09  FMC_LPC_LA03_P
#set_property -dict {PACKAGE_PIN P22    IOSTANDARD LVCMOS25} [get_ports cnv_en]                 ; ## G10  FMC_LPC_LA03_N

# clocks

create_clock -name dco     -period  4.762   [get_ports dco_p]
create_clock -name ref_clk -period 10.000   [get_ports ref_clk_p]

set_input_delay -clock dco -max 2.58 [get_ports da_p];
set_input_delay -clock dco -min 2.18 [get_ports da_p];
set_input_delay -clock dco -max 2.58 [get_ports da_p] -clock_fall -add_delay;
set_input_delay -clock dco -min 2.18 [get_ports da_p] -clock_fall -add_delay;

set_input_delay -clock dco -max 2.58 [get_ports db_p];
set_input_delay -clock dco -min 2.18 [get_ports db_p];
set_input_delay -clock dco -max 2.58 [get_ports db_p] -clock_fall -add_delay;
set_input_delay -clock dco -min 2.18 [get_ports db_p] -clock_fall -add_delay;

# dco is generated from the axi_clkgen, it is an echoed clock axi_clkgen/clk0

#set_false_path -from [get_clocks dco] -to [get_clocks -of_objects [get_pins i_system_wrapper/system_i/axi_clkgen/inst/i_mmcm_drp/i_mmcm/CLKOUT0]]
#set_false_path -from [get_clocks -of_objects [get_pins i_system_wrapper/system_i/axi_clkgen/inst/i_mmcm_drp/i_mmcm/CLKOUT0]] -to [get_clocks dco]

# debug false path constraints
#set_false_path -from [get_clocks dco] -to [get_clocks -of_objects [get_pins i_system_wrapper/system_i/axi_clkgen/inst/i_mmcm_drp/i_mmcm/CLKOUT1]]
#set_false_path -from [get_pins {i_system_wrapper/system_i/util_ltc2387/inst/adc_data_db_n_reg[0]/C}] -to [get_pins {i_system_wrapper/system_i/util_ltc2387/inst/i_ila/inst/PROBE_PIPE.shift_probes_reg*/D}]
