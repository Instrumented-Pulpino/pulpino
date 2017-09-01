// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module pulpino(
  clk,
  rst_n,

  fetch_enable_i,

  spi_clk_i,
  spi_cs_i,
  spi_mode_o,
  spi_sdo0_o,
  spi_sdo1_o,
  spi_sdo2_o,
  spi_sdo3_o,
  spi_sdi0_i,
  spi_sdi1_i,
  spi_sdi2_i,
  spi_sdi3_i,

  spi_master_clk_o,
  spi_master_csn0_o,
  spi_master_csn1_o,
  spi_master_csn2_o,
  spi_master_csn3_o,
  spi_master_mode_o,
  spi_master_sdo0_o,
  spi_master_sdo1_o,
  spi_master_sdo2_o,
  spi_master_sdo3_o,
  spi_master_sdi0_i,
  spi_master_sdi1_i,
  spi_master_sdi2_i,
  spi_master_sdi3_i,

  uart_tx,
  uart_rx,
  uart_rts,
  uart_dtr,
  uart_cts,
  uart_dsr,

  scl_i,
  scl_o,
  scl_oen_o,
  sda_i,
  sda_o,
  sda_oen_o,

  gpio_in,
  gpio_out,
  gpio_dir,

  monitor_valid,

  AXI_DDR_awaddr,
  AXI_DDR_awprot,
  AXI_DDR_awregion,
  AXI_DDR_awlen,
  AXI_DDR_awsize,
  AXI_DDR_awburst,
  AXI_DDR_awlock,
  AXI_DDR_awcache,
  AXI_DDR_awqos,
  AXI_DDR_awid,
  AXI_DDR_awuser,
  AXI_DDR_awready,
  AXI_DDR_awvalid,

  AXI_DDR_araddr,
  AXI_DDR_arprot,
  AXI_DDR_arregion,
  AXI_DDR_arlen,
  AXI_DDR_arsize,
  AXI_DDR_arburst,
  AXI_DDR_arlock,
  AXI_DDR_arcache,
  AXI_DDR_arqos,
  AXI_DDR_arid,
  AXI_DDR_aruser,
  AXI_DDR_arready,
  AXI_DDR_arvalid,

  AXI_DDR_wvalid,
  AXI_DDR_wdata,
  AXI_DDR_wstrb,
  AXI_DDR_wuser,
  AXI_DDR_wlast,
  AXI_DDR_wready,

  AXI_DDR_rdata,
  AXI_DDR_rresp,
  AXI_DDR_rlast,
  AXI_DDR_rid,
  AXI_DDR_ruser,
  AXI_DDR_rready,
  AXI_DDR_rvalid,

  AXI_DDR_bresp,
  AXI_DDR_bid,
  AXI_DDR_buser,
  AXI_DDR_bready,
  AXI_DDR_bvalid,

  AXI_DDR_clk,
  AXI_DDR_rstn,

  tck_i,
  trstn_i,
  tms_i,
  tdi_i,
  tdo_o
  );

  // Clock and Reset
  input         clk;
  input         rst_n;

  input         fetch_enable_i;

  input         spi_clk_i;
  input         spi_cs_i;
  output  [1:0] spi_mode_o;
  output        spi_sdo0_o;
  output        spi_sdo1_o;
  output        spi_sdo2_o;
  output        spi_sdo3_o;
  input         spi_sdi0_i;
  input         spi_sdi1_i;
  input         spi_sdi2_i;
  input         spi_sdi3_i;

  output        spi_master_clk_o;
  output        spi_master_csn0_o;
  output        spi_master_csn1_o;
  output        spi_master_csn2_o;
  output        spi_master_csn3_o;
  output  [1:0] spi_master_mode_o;
  output        spi_master_sdo0_o;
  output        spi_master_sdo1_o;
  output        spi_master_sdo2_o;
  output        spi_master_sdo3_o;
  input         spi_master_sdi0_i;
  input         spi_master_sdi1_i;
  input         spi_master_sdi2_i;
  input         spi_master_sdi3_i;

  output        uart_tx;
  input         uart_rx;
  output        uart_rts;
  output        uart_dtr;
  input         uart_cts;
  input         uart_dsr;

  input         scl_i;
  output        scl_o;
  output        scl_oen_o;
  input         sda_i;
  output        sda_o;
  output        sda_oen_o;

  input  [31:0] gpio_in;
  output [31:0] gpio_out;
  output [31:0] gpio_dir;

  output        monitor_valid;

  output [31:0] AXI_DDR_awaddr;
  output [2:0]  AXI_DDR_awprot;
  output [3:0]  AXI_DDR_awregion;
  output [7:0]  AXI_DDR_awlen;
  output [2:0]  AXI_DDR_awsize;
  output [1:0]  AXI_DDR_awburst;
  output        AXI_DDR_awlock;
  output [3:0]  AXI_DDR_awcache;
  output [3:0]  AXI_DDR_awqos;
  output [3:0]  AXI_DDR_awid;
  output [0:0]  AXI_DDR_awuser;
  input         AXI_DDR_awready;
  output        AXI_DDR_awvalid;

  output [31:0] AXI_DDR_araddr;
  output [2:0]  AXI_DDR_arprot;
  output [3:0]  AXI_DDR_arregion;
  output [7:0]  AXI_DDR_arlen;
  output [2:0]  AXI_DDR_arsize;
  output [1:0]  AXI_DDR_arburst;
  output        AXI_DDR_arlock;
  output [3:0]  AXI_DDR_arcache;
  output [3:0]  AXI_DDR_arqos;
  output [3:0]  AXI_DDR_arid;
  output [0:0]  AXI_DDR_aruser;
  input         AXI_DDR_arready;
  output        AXI_DDR_arvalid;

  output        AXI_DDR_wvalid;
  output [31:0] AXI_DDR_wdata;
  output [3:0]  AXI_DDR_wstrb;
  output [3:0]  AXI_DDR_wuser;
  output        AXI_DDR_wlast;
  input         AXI_DDR_wready;

  input [31:0]  AXI_DDR_rdata;
  input [1:0]   AXI_DDR_rresp;
  input         AXI_DDR_rlast;
  input [3:0]   AXI_DDR_rid;
  input [0:0]   AXI_DDR_ruser;
  output        AXI_DDR_rready;
  input         AXI_DDR_rvalid;

  input [1:0]   AXI_DDR_bresp;
  input [3:0]   AXI_DDR_bid;
  input [0:0]   AXI_DDR_buser;
  output        AXI_DDR_bready;
  input         AXI_DDR_bvalid;

  output        AXI_DDR_clk;
  output        AXI_DDR_rstn;

  // JTAG signals
  input  tck_i;
  input  trstn_i;
  input  tms_i;
  input  tdi_i;
  output tdo_o;

  // PULP SoC
  pulpino_top pulpino_i
  (
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),

    .clk_sel_i         ( 1'b0              ),
    .clk_standalone_i  ( 1'b0              ),

    .testmode_i        ( 1'b0              ),
    .fetch_enable_i    ( fetch_enable_i    ),
    .scan_enable_i     ( 1'b0              ),

    .spi_clk_i         ( spi_clk_i         ),
    .spi_cs_i          ( spi_cs_i          ),
    .spi_mode_o        ( spi_mode_o        ),
    .spi_sdo0_o        ( spi_sdo0_o        ),
    .spi_sdo1_o        ( spi_sdo1_o        ),
    .spi_sdo2_o        ( spi_sdo2_o        ),
    .spi_sdo3_o        ( spi_sdo3_o        ),
    .spi_sdi0_i        ( spi_sdi0_i        ),
    .spi_sdi1_i        ( spi_sdi1_i        ),
    .spi_sdi2_i        ( spi_sdi2_i        ),
    .spi_sdi3_i        ( spi_sdi3_i        ),

    .spi_master_clk_o  ( spi_master_clk_o  ),
    .spi_master_csn0_o ( spi_master_csn0_o ),
    .spi_master_csn1_o ( spi_master_csn1_o ),
    .spi_master_csn2_o ( spi_master_csn2_o ),
    .spi_master_csn3_o ( spi_master_csn3_o ),
    .spi_master_mode_o ( spi_master_mode_o ),
    .spi_master_sdo0_o ( spi_master_sdo0_o ),
    .spi_master_sdo1_o ( spi_master_sdo1_o ),
    .spi_master_sdo2_o ( spi_master_sdo2_o ),
    .spi_master_sdo3_o ( spi_master_sdo3_o ),
    .spi_master_sdi0_i ( spi_master_sdi0_i ),
    .spi_master_sdi1_i ( spi_master_sdi1_i ),
    .spi_master_sdi2_i ( spi_master_sdi2_i ),
    .spi_master_sdi3_i ( spi_master_sdi3_i ),

    .uart_tx           ( uart_tx           ), // output
    .uart_rx           ( uart_rx           ), // input
    .uart_rts          ( uart_rts          ), // output
    .uart_dtr          ( uart_dtr          ), // output
    .uart_cts          ( uart_cts          ), // input
    .uart_dsr          ( uart_dsr          ), // input

    .scl_pad_i         ( scl_i             ),
    .scl_pad_o         ( scl_o             ),
    .scl_padoen_o      ( scl_oen_o         ),
    .sda_pad_i         ( sda_i             ),
    .sda_pad_o         ( sda_o             ),
    .sda_padoen_o      ( sda_oen_o         ),

    .gpio_in           ( gpio_in           ),
    .gpio_out          ( gpio_out          ),
    .gpio_dir          ( gpio_dir          ),
    .gpio_padcfg       (                   ),

    .monitor_valid     ( monitor_valid     ),

  .AXI_DDR_awaddr ( AXI_DDR_awaddr ),
  .AXI_DDR_awprot ( AXI_DDR_awprot ),
  .AXI_DDR_awregion ( AXI_DDR_awregion ),
  .AXI_DDR_awlen ( AXI_DDR_awlen ),
  .AXI_DDR_awsize ( AXI_DDR_awsize ),
  .AXI_DDR_awburst ( AXI_DDR_awburst ),
  .AXI_DDR_awlock ( AXI_DDR_awlock ),
  .AXI_DDR_awcache ( AXI_DDR_awcache ),
  .AXI_DDR_awqos ( AXI_DDR_awqos ),
  .AXI_DDR_awid ( AXI_DDR_awid ),
  .AXI_DDR_awuser ( AXI_DDR_awuser ),
  .AXI_DDR_awready ( AXI_DDR_awready ),
  .AXI_DDR_awvalid ( AXI_DDR_awvalid ),

  .AXI_DDR_araddr ( AXI_DDR_araddr ),
  .AXI_DDR_arprot ( AXI_DDR_arprot ),
  .AXI_DDR_arregion ( AXI_DDR_arregion ),
  .AXI_DDR_arlen ( AXI_DDR_arlen ),
  .AXI_DDR_arsize ( AXI_DDR_arsize ),
  .AXI_DDR_arburst ( AXI_DDR_arburst ),
  .AXI_DDR_arlock ( AXI_DDR_arlock ),
  .AXI_DDR_arcache ( AXI_DDR_arcache ),
  .AXI_DDR_arqos ( AXI_DDR_arqos ),
  .AXI_DDR_arid ( AXI_DDR_arid ),
  .AXI_DDR_aruser ( AXI_DDR_aruser ),
  .AXI_DDR_arready ( AXI_DDR_arready ),
  .AXI_DDR_arvalid ( AXI_DDR_arvalid ),

  .AXI_DDR_wvalid ( AXI_DDR_wvalid ),
  .AXI_DDR_wdata ( AXI_DDR_wdata ),
  .AXI_DDR_wstrb ( AXI_DDR_wstrb ),
  .AXI_DDR_wuser ( AXI_DDR_wuser ),
  .AXI_DDR_wlast ( AXI_DDR_wlast ),
  .AXI_DDR_wready ( AXI_DDR_wready ),

  .AXI_DDR_rdata ( AXI_DDR_rdata ),
  .AXI_DDR_rresp ( AXI_DDR_rresp ),
  .AXI_DDR_rlast ( AXI_DDR_rlast ),
  .AXI_DDR_rid ( AXI_DDR_rid ),
  .AXI_DDR_ruser ( AXI_DDR_ruser ),
  .AXI_DDR_rready ( AXI_DDR_rready ),
  .AXI_DDR_rvalid ( AXI_DDR_rvalid ),

  .AXI_DDR_bresp ( AXI_DDR_bresp ),
  .AXI_DDR_bid ( AXI_DDR_bid ),
  .AXI_DDR_buser ( AXI_DDR_buser ),
  .AXI_DDR_bready ( AXI_DDR_bready ),
  .AXI_DDR_bvalid ( AXI_DDR_bvalid ),

   .AXI_DDR_clk ( AXI_DDR_clk ),
   .AXI_DDR_rstn ( AXI_DDR_rstn ),

    .tck_i             ( tck_i             ),
    .trstn_i           ( trstn_i           ),
    .tms_i             ( tms_i             ),
    .tdi_i             ( tdi_i             ),
    .tdo_o             ( tdo_o             ),

    .pad_cfg_o         (                   ),
    .pad_mux_o         (                   )
  );

endmodule
