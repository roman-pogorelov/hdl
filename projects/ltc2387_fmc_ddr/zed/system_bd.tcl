# specify ADC resolution -- the design supports 16/18 bit resolutions
set adc_resolution 18

# specify number of channels -- the design supports one lane/two lanes
set two_lanes 1


source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl
source ../common/ltc2387_bd.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9
set sys_cstring "sys rom custom string placeholder"
sysid_gen_sys_init_file $sys_cstring

#create_bd_port -dir I test_pat
#create_bd_port -dir I two_lanes

# create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0
# set_property -dict [list CONFIG.C_DATA_DEPTH {4096} CONFIG.C_NUM_OF_PROBES {4} CONFIG.C_ENABLE_ILA_AXI_MON {false} CONFIG.C_MONITOR_TYPE {Native}] [get_bd_cells ila_0]
# connect_bd_net [get_bd_pins ila_0/clk] [get_bd_pins sys_ps7/FCLK_CLK0]
# connect_bd_net [get_bd_ports test_pat ] [get_bd_pins ila_0/probe0]
# connect_bd_net [get_bd_ports two_lanes] [get_bd_pins ila_0/probe1]
# connect_bd_net [get_bd_pins axi_pwm_gen/pwm_0] [get_bd_pins ila_0/probe2]
# connect_bd_net [get_bd_pins axi_pwm_gen/pwm_1] [get_bd_pins ila_0/probe3]
#
