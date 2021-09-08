#
# The ADI JESD204 Core is released under the following license, which is
# different than all other HDL cores in this repository.
#
# Please read this, and understand the freedoms and responsibilities you have
# by using this source code/core.
#
# The JESD204 HDL, is copyright © 2016-2017 Analog Devices Inc.
#
# This core is free software, you can use run, copy, study, change, ask
# questions about and improve this core. Distribution of source, or resulting
# binaries (including those inside an FPGA or ASIC) require you to release the
# source of the entire project (excluding the system libraries provide by the
# tools/compiler/FPGA vendor). These are the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
#
# This core  is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License version 2
# along with this source code, and binary.  If not, see
# <http://www.gnu.org/licenses/>.
#
# Commercial licenses (with commercial support) of this JESD204 core are also
# available under terms different than the General Public License. (e.g. they
# do not require you to accompany any image (FPGA or ASIC) using the JESD204
# core with any corresponding source code.) For these alternate terms you must
# purchase a license from Analog Devices Technology Licensing Office. Users
# interested in such a license should contact jesd204-licensing@analog.com for
# more information. This commercial license is sub-licensable (if you purchase
# chips from Analog Devices, incorporate them into your PCB level product, and
# purchase a JESD204 license, end users of your product will also have a
# license to use this core in a commercial setting without releasing their
# source code).
#
# In addition, we kindly ask you to acknowledge ADI in any program, application
# or publication in which you use this JESD204 HDL core. (You are not required
# to do so; it is up to your common sense to decide whether you want to comply
# with this request or not.) For general publications, we suggest referencing :
# “The design and implementation of the JESD204 HDL Core used in this project
# is copyright © 2016-2017, Analog Devices, Inc.”
#

package require qsys
source ../../scripts/adi_env.tcl
source ../../scripts/adi_ip_alt.tcl

#
# Wrapper module that instantiates and connects all the components required
# for a JESD204 link PLL.
#

ad_ip_create adi_jesd204_link_pll {Analog Devices JESD204 link PLL}
set_module_property VALIDATION_CALLBACK jesd204_link_pll_validate
set_module_property COMPOSITION_CALLBACK jesd204_link_pll_compose

# parameters

ad_ip_parameter LANE_RATE FLOAT 10000 false { \
    DISPLAY_NAME "Lane Rate" \
    DISPLAY_UNITS "Mbps" \
}

ad_ip_parameter SYSCLK_FREQUENCY FLOAT 100.0 false { \
    DISPLAY_NAME "System Clock Frequency" \
    UNITS Megahertz
}

ad_ip_parameter REFCLK_FREQUENCY FLOAT 500.0 false { \
    DISPLAY_NAME "Reference Clock Frequency" \
    UNITS Megahertz \
}

ad_ip_parameter LINK_COUNT NATURAL 1 false { \
    DISPLAY_NAME "Number Of JESD204 links" \
    ALLOWED_RANGES {1 2 3 4} \
}


proc jesd204_link_pll_validate {} {

}


proc jesd204_link_pll_compose {} {

    # Get parameters set by user
    set lane_rate [get_parameter_value "LANE_RATE"]
    set sysclk_frequency [get_parameter_value "SYSCLK_FREQUENCY"]
    set refclk_frequency [get_parameter_value "REFCLK_FREQUENCY"]
    set link_count [get_parameter_value "LINK_COUNT"]

    # Do some calculations
    set linkclk_frequency [expr $lane_rate / 40]

    add_instance sys_clock clock_source
    set_instance_parameter_value sys_clock {clockFrequency} [expr $sysclk_frequency*1000000]
    set_instance_parameter_value sys_clock {resetSynchronousEdges} {deassert}

    add_interface sys_clk clock sink
    set_interface_property sys_clk EXPORT_OF sys_clock.clk_in

    add_interface sys_rstn reset sink
    set_interface_property sys_rstn EXPORT_OF sys_clock.clk_in_reset

    add_instance ref_clock altera_clock_bridge
    set_instance_parameter_value ref_clock {EXPLICIT_CLOCK_RATE} [expr $refclk_frequency*1000000]

    add_interface ref_clk clock sink
    set_interface_property ref_clk EXPORT_OF ref_clock.in_clk

    # FIXME: In phase alignment mode manual re-calibration fails
    add_instance link_pll altera_xcvr_fpll_a10
    set_instance_property link_pll SUPPRESS_ALL_WARNINGS true
    set_instance_property link_pll SUPPRESS_ALL_INFO_MESSAGES true
    set_instance_parameter_value link_pll {gui_fpll_mode} {0}
    set_instance_parameter_value link_pll {gui_reference_clock_frequency} $refclk_frequency
    set_instance_parameter_value link_pll {gui_number_of_output_clocks} 1
    # set_instance_parameter_value link_pll {gui_enable_phase_alignment} 1
    set_instance_parameter_value link_pll {gui_desired_outclk0_frequency} $linkclk_frequency
    # set pfdclk_frequency [get_instance_parameter_value link_pll gui_pfd_frequency]
    # set_instance_parameter_value link_pll {gui_desired_outclk1_frequency} $pfdclk_frequency
    set_instance_parameter_value link_pll {enable_pll_reconfig} {1}
    set_instance_parameter_value link_pll {set_capability_reg_enable} {1}
    set_instance_parameter_value link_pll {set_csr_soft_logic_enable} {1}
    set_instance_parameter_value link_pll {rcfg_separate_avmm_busy} {1}
    add_connection ref_clock.out_clk link_pll.pll_refclk0

    add_instance link_clock altera_clock_bridge
    set_instance_parameter_value link_clock {EXPLICIT_CLOCK_RATE} [expr $linkclk_frequency*1000000]
    add_connection link_pll.outclk0 link_clock.in_clk
    add_interface link_clk clock source
    set_interface_property link_clk EXPORT_OF link_clock.out_clk

    add_connection sys_clock.clk_reset link_pll.reconfig_reset0
    add_connection sys_clock.clk link_pll.reconfig_clk0

    add_interface link_pll_reconfig avalon slave
    set_interface_property link_pll_reconfig EXPORT_OF link_pll.reconfig_avmm0

    add_instance pll_locked_conv alt_ifconv
    set_instance_parameter_value pll_locked_conv INTERFACE_NAME_IN "pll_locked_in"
    set_instance_parameter_value pll_locked_conv INTERFACE_NAME_OUT "pll_locked_out"
    set_instance_parameter_value pll_locked_conv SIGNAL_NAME_IN "pll_locked"
    set_instance_parameter_value pll_locked_conv SIGNAL_NAME_OUT "export"
    add_connection link_pll.pll_locked pll_locked_conv.pll_locked_in

    add_instance pll_locked_splitter conduit_splitter
    set_instance_parameter_value pll_locked_splitter OUTPUT_NUM $link_count
    add_connection pll_locked_conv.pll_locked_out pll_locked_splitter.conduit_input
    for {set i 0} {$i < $link_count} {incr i} {
        add_instance pll_locked_conv_$i alt_ifconv
        set_instance_parameter_value pll_locked_conv_$i INTERFACE_NAME_IN "pll_locked_in"
        set_instance_parameter_value pll_locked_conv_$i INTERFACE_NAME_OUT "pll_locked_out"
        set_instance_parameter_value pll_locked_conv_$i SIGNAL_NAME_IN "export"
        set_instance_parameter_value pll_locked_conv_$i SIGNAL_NAME_OUT "pll_locked"
        add_connection pll_locked_splitter.conduit_output_$i pll_locked_conv_$i.pll_locked_in
        add_interface link_pll_locked_$i conduit end
        set_interface_property link_pll_locked_$i EXPORT_OF pll_locked_conv_$i.pll_locked_out
    }

    add_instance adxcvr_reset altera_reset_bridge
    add_connection sys_clock.clk adxcvr_reset.clk
    add_interface adxcvr_rst reset sink
    set_interface_property adxcvr_rst EXPORT_OF adxcvr_reset.in_reset

    add_instance link_reset altera_reset_bridge
    add_connection link_pll.outclk0 link_reset.clk
    add_connection adxcvr_reset.out_reset link_reset.in_reset
    add_interface link_rst reset source
    set_interface_property link_rst EXPORT_OF link_reset.out_reset

    add_instance link_pll_reset_control altera_xcvr_reset_control
    set_instance_parameter_value link_pll_reset_control {SYS_CLK_IN_MHZ} $sysclk_frequency
    set_instance_parameter_value link_pll_reset_control {TX_PLL_ENABLE} {1}
    set_instance_parameter_value link_pll_reset_control {T_PLL_POWERDOWN} {1000}
    set_instance_parameter_value link_pll_reset_control {TX_ENABLE} {0}
    set_instance_parameter_value link_pll_reset_control {RX_ENABLE} {0}
    set_instance_parameter_value link_pll_reset_control {SYNCHRONIZE_RESET} {0}
    add_connection sys_clock.clk link_pll_reset_control.clock
    add_connection adxcvr_reset.out_reset link_pll_reset_control.reset
    add_connection sys_clock.clk_reset link_pll_reset_control.reset
    add_connection link_pll_reset_control.pll_powerdown link_pll.pll_powerdown
}
