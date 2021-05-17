# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create util_ltc2387
adi_ip_files util_ltc2387 [list \
  "$ad_hdl_dir/library/xilinx/common/ad_data_clk.v" \
  "util_ltc2387.v" ]

adi_ip_properties_lite util_ltc2387

ipx::infer_bus_interface ref_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface dco_p xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface dco_n xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

ipx::save_core [ipx::current_core]
