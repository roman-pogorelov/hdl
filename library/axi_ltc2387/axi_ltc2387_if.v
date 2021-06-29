// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
// This is the LVDS/DDR interface, note that overrange is independent of data path,
// software will not be able to relate overrange to a specific sample!

`timescale 1ns/100ps

module axi_ltc2387_if #(

  parameter   FPGA_TECHNOLOGY = 1,
  parameter   IO_DELAY_GROUP = "adc_if_delay_group",
  parameter   DELAY_REFCLK_FREQUENCY = 200,
  parameter   [0:0] TWOLANES = 1, // 0 for Single Lane, 1 for Two Lanes
  parameter   RESOLUTION = 16)(    // 16 or 18 bits

  // delay interface

  input                    up_clk,
  input   [ 1:0]           up_dld,
  input   [ 9:0]           up_dwdata,
  output  [ 9:0]           up_drdata,
  input                    delay_clk,
  input                    delay_rst,
  output                   delay_locked,

  // processor interface

  input                    adc_ddr_edgesel,

  // adc interface

  input                    clk,
  input                    clk_gate,
  input                    dco_p,
  input                    dco_n,
  input                    da_p,
  input                    da_n,
  input                    db_p,
  input                    db_n,

  // debug
  output                   dco_out,
  output                   da_out,
  output                   db_out,

  output                   adc_valid,
  output [RESOLUTION-1:0]  adc_data);

  localparam   ONE_L_WIDTH = (RESOLUTION == 18) ? 9 : 8;
  localparam   TWO_L_WIDTH = (RESOLUTION == 18) ? 5 : 4;
  localparam   WIDTH = (TWOLANES == 0) ? ONE_L_WIDTH : TWO_L_WIDTH;

  // internal wires

  wire                        da_p_int_s;
  wire                        da_n_int_s;
  wire                        db_p_int_s;
  wire                        db_n_int_s;
  wire                        dco;
  wire               [19:0]   adc_data_int;

  wire                        adc_dmux_a_p_s;
  wire                        adc_dmux_a_n_s;
  wire                        adc_dmux_b_p_s;
  wire                        adc_dmux_b_n_s;

  // internal registers

  reg      [     WIDTH-1:0]   adc_data_da_p = 'b0;
  reg      [     WIDTH-1:0]   adc_data_da_n = 'b0;
  reg      [     WIDTH-1:0]   adc_data_db_p = 'b0;
  reg      [     WIDTH-1:0]   adc_data_db_n = 'b0;
  reg      [           1:0]   clk_gate_d = 1'b0;

  // debug
  reg [3:0] reg_da_p = 4'd0;
  reg [3:0] reg_da_n = 4'd0;
  reg [3:0] reg_db_p = 4'd0;
  reg [3:0] reg_db_n = 4'd0;

  // assignments

  assign adc_valid = ~clk_gate_d[0] & clk_gate_d[1];

  always @(posedge clk) begin
    clk_gate_d <= {clk_gate_d, clk_gate};
  end


  assign adc_dmux_a_p_s = (adc_ddr_edgesel == 1'b1) ? da_p_int_s : da_n_int_s;
  assign adc_dmux_a_n_s = (adc_ddr_edgesel == 1'b1) ? da_n_int_s : da_p_int_s;
  assign adc_dmux_b_p_s = (adc_ddr_edgesel == 1'b1) ? db_p_int_s : db_n_int_s;
  assign adc_dmux_b_n_s = (adc_ddr_edgesel == 1'b1) ? db_n_int_s : db_p_int_s;

  always @(posedge dco) begin
    adc_data_da_p <= {adc_data_da_p[WIDTH-2:0], adc_dmux_a_p_s};
    adc_data_da_n <= {adc_data_da_n[WIDTH-2:0], adc_dmux_a_n_s};
    adc_data_db_p <= {adc_data_db_p[WIDTH-2:0], adc_dmux_b_p_s};
    adc_data_db_n <= {adc_data_db_n[WIDTH-2:0], adc_dmux_b_n_s};

    // debug
    reg_da_p <= {reg_da_p[2:0], da_p_int_s};
    reg_da_n <= {reg_da_n[2:0], da_n_int_s};
    reg_db_p <= {reg_db_p[2:0], db_p_int_s};
    reg_db_n <= {reg_db_n[2:0], db_n_int_s};
  end

  my_ila i_ila (
    .clk(delay_clk),
    .probe0(adc_data),
    .probe1(reg_da_p),
    .probe2(reg_da_n),
    .probe3(reg_db_p),
    .probe4(reg_db_n),
    .probe5(adc_valid),
    .probe6(dco),
    .probe7(da_p_int_s),
    .probe8(da_n_int_s),
    .probe9(db_p_int_s),
    .probe10(db_n_int_s),
    .probe11(up_dld),
    .probe12(up_dwdata),
    .probe13(up_drdata));

  // bits rearrangement

   genvar i;
   generate
     for (i = 0; i < WIDTH; i = i+1) begin
       if (!TWOLANES) begin
         assign adc_data_int[2*i+1:2*i] = {adc_data_da_p[i], adc_data_da_n[i]};
       end else begin
         assign adc_data_int[4*i+3:4*i] = {adc_data_da_p[i], adc_data_db_p[i],
	 	                                  adc_data_da_n[i], adc_data_db_n[i]};
       end
     end
   endgenerate

   generate
     if (RESOLUTION == 16) begin
       assign adc_data = adc_data_int[RESOLUTION-1:0];
     end else begin
       if (RESOLUTION == 18) begin
         if (!TWOLANES) begin
           assign adc_data = adc_data_int[RESOLUTION-1:0];
         end else begin
           assign adc_data = adc_data_int[RESOLUTION+1:2];
         end
       end
     end
   endgenerate

  // data interface - differential to single ended

  ad_data_in #(
    .FPGA_TECHNOLOGY (FPGA_TECHNOLOGY),
    .IODELAY_CTRL (1),
    .IODELAY_GROUP (IO_DELAY_GROUP),
    .REFCLK_FREQUENCY (DELAY_REFCLK_FREQUENCY))
  i_rx_da (
    .rx_clk (clk),
    .rx_data_in_p (da_p),
    .rx_data_in_n (da_n),
    .rx_data_p (da_p_int_s),
    .rx_data_n (da_n_int_s),
    .up_clk (up_clk),
    .up_dld (up_dld[0]),
    .up_dwdata (up_dwdata[4:0]),
    .up_drdata (up_drdata[4:0]),
    .delay_clk (delay_clk),
    .delay_rst (delay_rst),
    .delay_locked (delay_locked));

  ad_data_in #(
    .FPGA_TECHNOLOGY (FPGA_TECHNOLOGY),
    .IODELAY_CTRL (0),
    .IODELAY_GROUP (IO_DELAY_GROUP),
    .REFCLK_FREQUENCY (DELAY_REFCLK_FREQUENCY))
  i_rx_db (
    .rx_clk (clk),
    .rx_data_in_p (db_p),
    .rx_data_in_n (db_n),
    .rx_data_p (db_p_int_s),
    .rx_data_n (db_n_int_s),
    .up_clk (up_clk),
    .up_dld (up_dld[1]),
    .up_dwdata (up_dwdata[9:5]),
    .up_drdata (up_drdata[9:5]),
    .delay_clk (delay_clk),
    .delay_rst (delay_rst),
    .delay_locked ());


  // clock

  ad_data_clk #(
    .SINGLE_ENDED (0))
  i_adc_dco (
    .rst (delay_rst),
    .locked (),
    .clk_in_p (dco_p),
    .clk_in_n (dco_n),
    .clk (dco));

  // debug
  assign  da_out = da_p_int_s;
  assign  db_out = da_n_int_s;

endmodule

// ***************************************************************************
// ***************************************************************************
