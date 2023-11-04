/**
 * @file top.sv
 * @brief top level for DDR test
 */
module top
  (
   input logic clk,
   input logic rst_n,
   output logic [7:0] led,
   // DDR3
   inout logic [15:0] ddr3_dq,
   inout logic [1:0] ddr3_dqs_p,
   inout logic [1:0] ddr3_dqs_n,
   output logic [13:0] ddr3_addr,
   output logic [2:0] ddr3_ba,
   output logic ddr3_ras_n,
   output logic ddr3_cas_n,
   output logic ddr3_we_n,
   output logic ddr3_reset_n,
   output logic [0:0] ddr3_ck_p,
   output logic [0:0] ddr3_ck_n,
   output logic [0:0] ddr3_cke,
   output logic [0:0] ddr3_cs_n,
   output logic [1:0] ddr3_dm,
   output logic [0:0] ddr3_odt
   );

   logic              rst;
   logic              locked;
   logic              rst_mig;
   logic              clk_200;
   logic              init_calib_complete;

   // DDR application
   logic [27:0]       app_addr;
   logic [2:0]        app_cmd;
   logic              app_en;
   logic [127:0]      app_wdf_data;
   logic              app_wdf_end;
   logic              app_wdf_wren;
   logic [127:0]      app_rd_data;
   logic              app_rd_data_end;
   logic              app_rd_data_valid;
   logic              app_rdy;
   logic              app_wdf_rdy;
   logic              ui_clk;
   logic              ui_clk_sync_rst;
   logic [15:0]       app_wdf_mask;

   // test output
   logic              test_progress;
   logic              test_ok;
   logic              test_error;

   assign rst = ~rst_n;
   assign rst_mig = ~locked | rst;

   clk_wiz clk_unit
     (.reset(rst),
      .locked(locked),
      .clk_in(clk),
      .clk_out_200(clk_200)
      );

   mig_7series_0 mig_unit
     (
      //  Input clk_ref_i if you not using system clock as reference clock with
      // fixed 200 MHz
      .sys_clk_i(clk_200),
      //.clk_ref_i(clk_200),
      .sys_rst(rst_mig),
      .init_calib_complete(init_calib_complete),
      // DDR3
      .ddr3_dq(ddr3_dq),
      .ddr3_dqs_p(ddr3_dqs_p),
      .ddr3_dqs_n(ddr3_dqs_n),
      .ddr3_addr(ddr3_addr),
      .ddr3_ba(ddr3_ba),
      .ddr3_ras_n(ddr3_ras_n),
      .ddr3_cas_n(ddr3_cas_n),
      .ddr3_we_n(ddr3_we_n),
      .ddr3_reset_n(ddr3_reset_n),
      .ddr3_ck_p(ddr3_ck_p),
      .ddr3_ck_n(ddr3_ck_n),
      .ddr3_cke(ddr3_cke),
      .ddr3_cs_n(ddr3_cs_n),
      .ddr3_dm(ddr3_dm),
      .ddr3_odt(ddr3_odt),
      // DDR3 application
      .app_addr(app_addr),
      .app_cmd(app_cmd),
      .app_en(app_en),
      .app_wdf_data(app_wdf_data),
      .app_wdf_end(app_wdf_end),
      .app_wdf_wren(app_wdf_wren),
      .app_rd_data(app_rd_data),
      .app_rd_data_end(app_rd_data_end),
      .app_rd_data_valid(app_rd_data_valid),
      .app_rdy(app_rdy),
      .app_wdf_rdy(app_wdf_rdy),
      .app_sr_req(0),   // reserved
      .app_ref_req(0),  // refresh request
      .app_zq_req(0),   // ZQ calibration request
      .app_sr_active(), // reserved
      .app_ref_ack(),   // refresh ack
      .app_zq_ack(),    // ZQ calibration ack
      .ui_clk(ui_clk),
      .ui_clk_sync_rst(ui_clk_sync_rst),
      .app_wdf_mask(app_wdf_mask)
      );

   ddr_test #(.ADDR_WIDTH(28), .APP_DATA_WIDTH(128), .MASK_WIDTH(16)) ddr_test_unit
     (.app_addr(app_addr),
      .app_cmd(app_cmd),
      .app_en(app_en),
      .app_wdf_data(app_wdf_data),
      .app_wdf_end(app_wdf_end),
      .app_wdf_wren(app_wdf_wren),
      .app_rd_data(app_rd_data),
      .app_rd_data_end(app_rd_data_end),
      .app_rd_data_valid(app_rd_data_valid),
      .app_rdy(app_rdy),
      .app_wdf_rdy(app_wdf_rdy),
      .ui_clk(ui_clk),
      .ui_clk_sync_rst(ui_clk_sync_rst),
      .app_wdf_mask(app_wdf_mask),
      .test_progress(test_progress),
      .test_ok(test_ok),
      .test_error(test_error)
      );

   // output
   assign led = { test_progress, test_ok, test_error, 2'b00, locked, init_calib_complete, 1'b1};

endmodule // top
