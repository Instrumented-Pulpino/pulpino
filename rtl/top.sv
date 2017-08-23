// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "axi_bus.sv"
`include "debug_bus.sv"

`define AXI_ADDR_WIDTH         32
`define AXI_DATA_WIDTH         32
`define AXI_ID_MASTER_WIDTH     2
`define AXI_ID_SLAVE_WIDTH      4
`define AXI_USER_WIDTH          1

module pulpino_top
  (
    // Clock and Reset
    input logic               clk,
    input logic               rst_n,

    input logic               clk_sel_i,
    input logic               clk_standalone_i,
    input logic               testmode_i,
    input logic               fetch_enable_i,
    input logic               scan_enable_i,

    //SPI Slave
    input logic               spi_clk_i,
    input logic               spi_cs_i,
    output logic [1:0]        spi_mode_o,
    output logic              spi_sdo0_o,
    output logic              spi_sdo1_o,
    output logic              spi_sdo2_o,
    output logic              spi_sdo3_o,
    input logic               spi_sdi0_i,
    input logic               spi_sdi1_i,
    input logic               spi_sdi2_i,
    input logic               spi_sdi3_i,

    //SPI Master
    output logic              spi_master_clk_o,
    output logic              spi_master_csn0_o,
    output logic              spi_master_csn1_o,
    output logic              spi_master_csn2_o,
    output logic              spi_master_csn3_o,
    output logic [1:0]        spi_master_mode_o,
    output logic              spi_master_sdo0_o,
    output logic              spi_master_sdo1_o,
    output logic              spi_master_sdo2_o,
    output logic              spi_master_sdo3_o,
    input logic               spi_master_sdi0_i,
    input logic               spi_master_sdi1_i,
    input logic               spi_master_sdi2_i,
    input logic               spi_master_sdi3_i,

    input logic               scl_pad_i,
    output logic              scl_pad_o,
    output logic              scl_padoen_o,
    input logic               sda_pad_i,
    output logic              sda_pad_o,
    output logic              sda_padoen_o,

    output logic              uart_tx,
    input logic               uart_rx,
    output logic              uart_rts,
    output logic              uart_dtr,
    input logic               uart_cts,
    input logic               uart_dsr,

    output logic [31:0]       AXI_DDR_awaddr,
    output logic [2:0]        AXI_DDR_awprot,
    output logic [3:0]        AXI_DDR_awregion,
    output logic [7:0]        AXI_DDR_awlen,
    output logic [2:0]        AXI_DDR_awsize,
    output logic [1:0]        AXI_DDR_awburst,
    output logic              AXI_DDR_awlock,
    output logic [3:0]        AXI_DDR_awcache,
    output logic [3:0]        AXI_DDR_awqos,
    output logic [3:0]        AXI_DDR_awid,
    output logic [0:0]        AXI_DDR_awuser,
    input logic               AXI_DDR_awready,
    output logic              AXI_DDR_awvalid,

    output logic [31:0]       AXI_DDR_araddr,
    output logic [2:0]        AXI_DDR_arprot,
    output logic [3:0]        AXI_DDR_arregion,
    output logic [7:0]        AXI_DDR_arlen,
    output logic [2:0]        AXI_DDR_arsize,
    output logic [1:0]        AXI_DDR_arburst,
    output logic              AXI_DDR_arlock,
    output logic [3:0]        AXI_DDR_arcache,
    output logic [3:0]        AXI_DDR_arqos,
    output logic [3:0]        AXI_DDR_arid,
    output logic [0:0]        AXI_DDR_aruser,
    input logic               AXI_DDR_arready,
    output logic              AXI_DDR_arvalid,

    output logic              AXI_DDR_wvalid,
    output logic [31:0]       AXI_DDR_wdata,
    output logic [3:0]        AXI_DDR_wstrb,
    output logic [3:0]        AXI_DDR_wuser,
    output logic              AXI_DDR_wlast,
    input logic               AXI_DDR_wready,

    input logic [31:0]        AXI_DDR_rdata,
    input logic [1:0]         AXI_DDR_rresp,
    input logic               AXI_DDR_rlast,
    input logic [3:0]         AXI_DDR_rid,
    input logic [0:0]         AXI_DDR_ruser,
    output logic              AXI_DDR_rready,
    input logic               AXI_DDR_rvalid,

    input logic [1:0]         AXI_DDR_bresp,
    input logic [3:0]         AXI_DDR_bid,
    input logic [0:0]         AXI_DDR_buser,
    output logic              AXI_DDR_bready,
    input logic               AXI_DDR_bvalid,

    input logic [31:0]        gpio_in,
    output logic [31:0]       gpio_out,
    output logic [31:0]       gpio_dir,
    output logic [31:0] [5:0] gpio_padcfg,

   // JTAG signals
    input logic               tck_i,
    input logic               trstn_i,
    input logic               tms_i,
    input logic               tdi_i,
    output logic              tdo_o,

   // Monitor signal
    output logic              monitor_valid,

   // PULPino specific pad config
    output logic [31:0] [5:0] pad_cfg_o,
    output logic [31:0]       pad_mux_o
  );

  logic        clk_int;

  logic        fetch_enable_int;
  logic        core_busy_int;
  logic        clk_gate_core_int;
  logic [31:0] irq_to_core_int;

  logic        lock_fll_int;
  logic        cfgreq_fll_int;
  logic        cfgack_fll_int;
  logic [1:0]  cfgad_fll_int;
  logic [31:0] cfgd_fll_int;
  logic [31:0] cfgq_fll_int;
  logic        cfgweb_n_fll_int;
  logic        rstn_int;
  logic [31:0] boot_addr_int;

  AXI_BUS
  #(
    .AXI_ADDR_WIDTH ( `AXI_ADDR_WIDTH     ),
    .AXI_DATA_WIDTH ( `AXI_DATA_WIDTH     ),
    .AXI_ID_WIDTH   ( `AXI_ID_SLAVE_WIDTH ),
    .AXI_USER_WIDTH ( `AXI_USER_WIDTH     )
  )
  slaves[1:0]();

  AXI_BUS
  #(
    .AXI_ADDR_WIDTH ( `AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( `AXI_DATA_WIDTH      ),
    .AXI_ID_WIDTH   ( `AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH ( `AXI_USER_WIDTH      )
  )
  masters[3:0]();

  DEBUG_BUS
  debug();

  //----------------------------------------------------------------------------//
  // Clock and reset generation
  //----------------------------------------------------------------------------//
  clk_rst_gen
  clk_rst_gen_i
  (
      .clk_i            ( clk              ),
      .rstn_i           ( rst_n            ),

      .clk_sel_i        ( clk_sel_i        ),
      .clk_standalone_i ( clk_standalone_i ),
      .testmode_i       ( testmode_i       ),
      .scan_i           ( 1'b0             ),
      .scan_o           (                  ),
      .scan_en_i        ( scan_enable_i    ),

      .fll_req_i        ( cfgreq_fll_int   ),
      .fll_wrn_i        ( cfgweb_n_fll_int ),
      .fll_add_i        ( cfgad_fll_int    ),
      .fll_data_i       ( cfgd_fll_int     ),
      .fll_ack_o        ( cfgack_fll_int   ),
      .fll_r_data_o     ( cfgq_fll_int     ),
      .fll_lock_o       ( lock_fll_int     ),

      .clk_o            ( clk_int          ),
      .rstn_o           ( rstn_int         )

    );

  //----------------------------------------------------------------------------//
  // Core region
  //----------------------------------------------------------------------------//
  core_region
  #(
    .AXI_ADDR_WIDTH       ( `AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH       ( `AXI_DATA_WIDTH      ),
    .AXI_ID_MASTER_WIDTH  ( `AXI_ID_MASTER_WIDTH ),
    .AXI_ID_SLAVE_WIDTH   ( `AXI_ID_SLAVE_WIDTH  ),
    .AXI_USER_WIDTH       ( `AXI_USER_WIDTH      )
  )
  core_region_i
  (
    .clk            ( clk_int           ),
    .rst_n          ( rstn_int          ),

    .testmode_i     ( testmode_i        ),
    .fetch_enable_i ( fetch_enable_int  ),
    .irq_i          ( irq_to_core_int   ),
    .core_busy_o    ( core_busy_int     ),
    .clock_gating_i ( clk_gate_core_int ),
    .boot_addr_i    ( boot_addr_int     ),

    .instr_master   ( masters[0]        ),
    .core_master    ( masters[1]        ),
    .dbg_master     ( masters[3]        ),
    .debug          ( debug             ),

    .tck_i          ( tck_i             ),
    .trstn_i        ( trstn_i           ),
    .tms_i          ( tms_i             ),
    .tdi_i          ( tdi_i             ),
    .tdo_o          ( tdo_o             )
  );

  assign AXI_DDR_awaddr = slaves[1].aw_addr;
  assign AXI_DDR_awprot = slaves[1].aw_prot;
  assign AXI_DDR_awregion = slaves[1].aw_region;
  assign AXI_DDR_awlen = slaves[1].aw_len;
  assign AXI_DDR_awsize = slaves[1].aw_size;
  assign AXI_DDR_awburst = slaves[1].aw_burst;
  assign AXI_DDR_awlock = slaves[1].aw_lock;
  assign AXI_DDR_awcache = slaves[1].aw_cache;
  assign AXI_DDR_awqos = slaves[1].aw_qos;
  assign AXI_DDR_awid = slaves[1].aw_id;
  assign AXI_DDR_awuser = slaves[1].aw_user;
  assign slaves[1].aw_ready = AXI_DDR_awready;
  assign AXI_DDR_awvalid = slaves[1].aw_valid;
  assign AXI_DDR_araddr = slaves[1].ar_addr;
  assign AXI_DDR_arprot = slaves[1].ar_prot;
  assign AXI_DDR_arregion = slaves[1].ar_region;
  assign AXI_DDR_arlen = slaves[1].ar_len;
  assign AXI_DDR_arsize = slaves[1].ar_size;
  assign AXI_DDR_arburst = slaves[1].ar_burst;
  assign AXI_DDR_arlock = slaves[1].ar_lock;
  assign AXI_DDR_arcache = slaves[1].ar_cache;
  assign AXI_DDR_arqos = slaves[1].ar_qos;
  assign AXI_DDR_arid = slaves[1].ar_id;
  assign AXI_DDR_aruser = slaves[1].ar_user;
  assign slaves[1].ar_ready = AXI_DDR_arready;
  assign AXI_DDR_arvalid = slaves[1].ar_valid;
  assign AXI_DDR_wvalid = slaves[1].w_valid;
  assign AXI_DDR_wdata = slaves[1].w_data;
  assign AXI_DDR_wstrb = slaves[1].w_strb;
  assign AXI_DDR_wuser = slaves[1].w_user;
  assign AXI_DDR_wlast = slaves[1].w_last;
  assign slaves[1].w_ready = AXI_DDR_wready;
  assign slaves[1].r_data = AXI_DDR_rdata;
  assign slaves[1].r_resp = AXI_DDR_rresp;
  assign slaves[1].r_last = AXI_DDR_rlast;
  assign slaves[1].r_id = AXI_DDR_rid;
  assign slaves[1].r_user = AXI_DDR_ruser;
  assign AXI_DDR_rready = slaves[1].r_ready;
  assign slaves[1].r_valid = AXI_DDR_rvalid;
  assign slaves[1].b_resp = AXI_DDR_bresp;
  assign slaves[1].b_id = AXI_DDR_bid;
  assign slaves[1].b_user = AXI_DDR_buser;
  assign AXI_DDR_bready = slaves[1].b_ready;
  assign slaves[1].b_valid = AXI_DDR_bvalid;

  //----------------------------------------------------------------------------//
  // Peripherals
  //----------------------------------------------------------------------------//
  peripherals
  #(
    .AXI_ADDR_WIDTH      ( `AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH      ( `AXI_DATA_WIDTH      ),
    .AXI_SLAVE_ID_WIDTH  ( `AXI_ID_SLAVE_WIDTH  ),
    .AXI_MASTER_ID_WIDTH ( `AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH      ( `AXI_USER_WIDTH      )
  )
  peripherals_i
  (
    .clk_i           ( clk_int           ),
    .rst_n           ( rstn_int          ),

    .axi_spi_master  ( masters[2]        ),
    .debug           ( debug             ),

    .spi_clk_i       ( spi_clk_i         ),
    .testmode_i      ( testmode_i        ),
    .spi_cs_i        ( spi_cs_i          ),
    .spi_mode_o      ( spi_mode_o        ),
    .spi_sdo0_o      ( spi_sdo0_o        ),
    .spi_sdo1_o      ( spi_sdo1_o        ),
    .spi_sdo2_o      ( spi_sdo2_o        ),
    .spi_sdo3_o      ( spi_sdo3_o        ),
    .spi_sdi0_i      ( spi_sdi0_i        ),
    .spi_sdi1_i      ( spi_sdi1_i        ),
    .spi_sdi2_i      ( spi_sdi2_i        ),
    .spi_sdi3_i      ( spi_sdi3_i        ),

    .slave           ( slaves[0]         ),

    .uart_tx         ( uart_tx           ),
    .uart_rx         ( uart_rx           ),
    .uart_rts        ( uart_rts          ),
    .uart_dtr        ( uart_dtr          ),
    .uart_cts        ( uart_cts          ),
    .uart_dsr        ( uart_dsr          ),

    .spi_master_clk  ( spi_master_clk_o  ),
    .spi_master_csn0 ( spi_master_csn0_o ),
    .spi_master_csn1 ( spi_master_csn1_o ),
    .spi_master_csn2 ( spi_master_csn2_o ),
    .spi_master_csn3 ( spi_master_csn3_o ),
    .spi_master_mode ( spi_master_mode_o ),
    .spi_master_sdo0 ( spi_master_sdo0_o ),
    .spi_master_sdo1 ( spi_master_sdo1_o ),
    .spi_master_sdo2 ( spi_master_sdo2_o ),
    .spi_master_sdo3 ( spi_master_sdo3_o ),
    .spi_master_sdi0 ( spi_master_sdi0_i ),
    .spi_master_sdi1 ( spi_master_sdi1_i ),
    .spi_master_sdi2 ( spi_master_sdi2_i ),
    .spi_master_sdi3 ( spi_master_sdi3_i ),

    .scl_pad_i       ( scl_pad_i         ),
    .scl_pad_o       ( scl_pad_o         ),
    .scl_padoen_o    ( scl_padoen_o      ),
    .sda_pad_i       ( sda_pad_i         ),
    .sda_pad_o       ( sda_pad_o         ),
    .sda_padoen_o    ( sda_padoen_o      ),

    .gpio_in         ( gpio_in           ),
    .gpio_out        ( gpio_out          ),
    .gpio_dir        ( gpio_dir          ),
    .gpio_padcfg     ( gpio_padcfg       ),

    .monitor_valid   ( monitor_valid     ),

    .core_busy_i     ( core_busy_int     ),
    .irq_o           ( irq_to_core_int   ),
    .fetch_enable_i  ( fetch_enable_i    ),
    .fetch_enable_o  ( fetch_enable_int  ),
    .clk_gate_core_o ( clk_gate_core_int ),

    .fll1_req_o      ( cfgreq_fll_int    ),
    .fll1_wrn_o      ( cfgweb_n_fll_int  ),
    .fll1_add_o      ( cfgad_fll_int     ),
    .fll1_wdata_o    ( cfgd_fll_int      ),
    .fll1_ack_i      ( cfgack_fll_int    ),
    .fll1_rdata_i    ( cfgq_fll_int      ),
    .fll1_lock_i     ( lock_fll_int      ),
    .pad_cfg_o       ( pad_cfg_o         ),
    .pad_mux_o       ( pad_mux_o         ),
    .boot_addr_o     ( boot_addr_int     )
  );


  //----------------------------------------------------------------------------//
  // Axi node
  //----------------------------------------------------------------------------//

  axi_node_intf_wrap
  #(
    .NB_MASTER      ( 2                    ),
    .NB_SLAVE       ( 4                    ),
    .AXI_ADDR_WIDTH ( `AXI_ADDR_WIDTH      ),
    .AXI_DATA_WIDTH ( `AXI_DATA_WIDTH      ),
    .AXI_ID_WIDTH   ( `AXI_ID_MASTER_WIDTH ),
    .AXI_USER_WIDTH ( `AXI_USER_WIDTH      )
  )
  axi_interconnect_i
  (
    .clk       ( clk_int    ),
    .rst_n     ( rstn_int   ),
    .test_en_i ( testmode_i ),

    .master    (   slaves     ),
    .slave     (   masters    ),

    .start_addr_i ( { 32'h1000_0000, 32'h1A10_0000 } ),
    .end_addr_i   ( { 32'h17FF_FFFF, 32'h1A11_FFFF } )
  );

endmodule
