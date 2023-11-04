/**
 * @file ddr_test.sv
 * @brief Test module for DDR operation.
 * 
 * Write once by pattern and verify by read.
 * 
 * Change width with your setting. See UG586 guide for details.
 * 
 * ADDR_WIDTH = RANK_WIDTH(1) + BANK_WIDTH(3) + ROW_WIDTH(14) + COL_WIDTH(10)
 *            = 28
 * 
 * PAYLOAD_WIDTH = DATA_WIDTH
 *               = 16
 * 
 * nCK_PER_CLK = number of memory clocks per clock. 4 for 4:1, 2 for 2:1 ratio
 * 
 * APP_DATA_WIDTH = 2 * nCK_PER_CLK * PAYLOAD_WIDTH
 *                = 2 * 4 * 16 = 128
 */
module ddr_test
  #(parameter ADDR_WIDTH = 28, APP_DATA_WIDTH = 128, MASK_WIDTH = 16)
  (
   // IO from DDR application interface ports
   output logic [ADDR_WIDTH-1:0]     app_addr,
   output logic [2:0]                app_cmd,
   output logic                      app_en,
   
   output logic [APP_DATA_WIDTH-1:0] app_wdf_data,
   output logic                      app_wdf_end,
   output logic                      app_wdf_wren,
   
   input logic [APP_DATA_WIDTH-1:0]  app_rd_data,
   input logic                       app_rd_data_end,
   input logic                       app_rd_data_valid,

   input logic                       app_rdy,
   input logic                       app_wdf_rdy,
   
   input logic                       ui_clk,
   input logic                       ui_clk_sync_rst,

   output logic [MASK_WIDTH-1:0]     app_wdf_mask,
   
   // result output
   output logic                      test_progress,
   output logic                      test_ok,
   output logic                      test_error
   );

   // localparam declaration
   localparam [APP_DATA_WIDTH-1:0] test_pattern = 128'h55AA_0123_4567_89AB_FEDC_BA98_7654_3210;
   
   // FSM
   typedef enum         {init, write, write_wait, read, read_wait, test_end} state_type;

   // signal declaration
   state_type           state_reg, state_next;
   logic [ADDR_WIDTH-1:0] app_addr_reg, app_addr_next;
   logic [2:0]          app_cmd_reg, app_cmd_next;
   logic                app_en_reg, app_en_next;
   logic [APP_DATA_WIDTH-1:0] app_wdf_data_reg, app_wdf_data_next;
   logic                      app_wdf_end_reg, app_wdf_end_next;
   logic                      app_wdf_wren_reg, app_wdf_wren_next;
   logic                      test_progress_reg, test_progress_next;
   logic                      test_ok_reg, test_ok_next;
   logic                      test_error_reg, test_error_next;
   
   always_ff @(posedge ui_clk, posedge ui_clk_sync_rst)
     if (ui_clk_sync_rst)
       begin
          state_reg <= init;
          app_addr_reg <= {ADDR_WIDTH{1'b0}};
          app_cmd_reg <= 3'b000;
          app_en_reg <= 1'b0;
          app_wdf_data_reg <= {APP_DATA_WIDTH{1'b0}};
          app_wdf_end_reg <= 1'b0;
          app_wdf_wren_reg <= 1'b0;
          test_progress_reg <= 1'b0;
          test_ok_reg <= 1'b0;
          test_error_reg <= 1'b0;
       end
     else
       begin
          state_reg <= state_next;
          app_addr_reg <= app_addr_next;
          app_cmd_reg <= app_cmd_next;
          app_en_reg <= app_en_next;
          app_wdf_data_reg <= app_wdf_data_next;
          app_wdf_end_reg <= app_wdf_end_next;
          app_wdf_wren_reg <= app_wdf_wren_next;
          test_progress_reg <= test_progress_next;
          test_ok_reg <= test_ok_next;
          test_error_reg <= test_error_next;
       end

   always_comb
     begin
        // default value
        state_next = state_reg;
        app_addr_next = app_addr_reg;
        app_cmd_next = app_cmd_reg;
        app_en_next = app_en_reg;
        app_wdf_data_next = app_wdf_data_reg;
        app_wdf_end_next = app_wdf_end_reg;
        app_wdf_wren_next = app_wdf_wren_reg;
        test_progress_next = test_progress_reg;
        test_ok_next = test_ok_reg;
        test_error_next = test_error_reg;

        case (state_reg)
          init: begin
             // clear register
             app_cmd_next = 3'b000;
             app_en_next = 1'b0;
             app_wdf_data_next = {APP_DATA_WIDTH{1'b0}};
             app_wdf_end_next = 1'b0;
             app_wdf_wren_next = 1'b0;
             test_progress_next = 1'b0;
             test_ok_next = 1'b0;
             test_error_next = 1'b0;
             
             if (app_rdy && app_wdf_rdy)
               begin
                  state_next = write;
               end
          end
          write: begin
             // issue write command on app_rdy, app_wdf_rdy
             if (app_rdy && app_wdf_rdy)
               begin
                  state_next = write_wait;
                  app_addr_next = {ADDR_WIDTH{1'b0}}; // rank 0, bank 0, row 0, col 0
                  app_cmd_next = 3'b000;        // write cmd
                  app_en_next = 1'b1;
                  app_wdf_data_next = test_pattern;
                  app_wdf_end_next = 1'b1;
                  app_wdf_wren_next = 1'b1;
                  test_progress_next = 1'b1;
               end
             else
               begin
                  // reset to init
                  state_next = init;
               end
          end
          write_wait: begin
             // keep write register to app_rdy
             if (app_rdy)
               begin
                  state_next = read;
             
                  // clear register
                  app_cmd_next = 3'b000;
                  app_en_next = 1'b0;
                  app_wdf_data_next = {APP_DATA_WIDTH{1'b0}};
                  app_wdf_end_next = 1'b0;
                  app_wdf_wren_next = 1'b0;
               end
          end
          read: begin
             // issue read command on app_rdy
             // @todo limit max wait
             if (app_rdy)
               begin
                  state_next = read_wait;
                  app_cmd_next = 3'b001; // read cmd
                  app_en_next = 1'b1;
               end
          end
          read_wait: begin
             // clear register
             app_cmd_next = 3'b000;
             app_en_next = 1'b0;

             // wait to app_rd_data_valid
             // @todo limit max wait
             if (app_rd_data_valid)
               begin
                  state_next = test_end;

                  test_progress_next = 1'b0;
                  
                  if (app_rd_data == test_pattern)
                    begin
                       test_ok_next = 1'b1;
                       test_error_next = 1'b0;
                    end
                  else
                    begin
                       test_ok_next = 1'b0;
                       test_error_next = 1'b1;
                    end
               end
          end
          default: begin
             // test_end
          end
        endcase // case (state_reg)
     end // always_comb

   // output
   assign app_addr = app_addr_reg;
   assign app_cmd = app_cmd_reg;
   assign app_en = app_en_reg;
   assign app_wdf_data = app_wdf_data_reg;
   assign app_wdf_end = app_wdf_end_reg;
   assign app_wdf_wren = app_wdf_wren_reg;
   assign app_wdf_mask = {MASK_WIDTH{1'b0}}; // non mask
   assign test_progress = test_progress_reg;
   assign test_ok = test_ok_reg;
   assign test_error = test_error_reg;

endmodule // ddr_test
