/**
 * @file ft600.sv
 * @brief FT600 device module
 *
 * - RX FIFO (fwft): write from FT, read from port
 * - TX FIFO: write from port, read from FT
 *
 * - rx_data: first data on RX FIFO. only valid on rx_valid
 * - rx_valid: rx_data validity. 0 latency
 * - tx_full: TX FIFO full flag. tx_full latency by read(internal): 1 rd_clk + (N+2) wr_clk
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

module ft600
  #(parameter RX_FIFO_DEPTH=512, parameter TX_FIFO_DEPTH=512, parameter DATA_WIDTH=16)
  (
   input logic                   clk,
   input logic                   rst,
   ft600_if.master               ft,

   // data in/out
   input logic                   rx_en,
   output logic [DATA_WIDTH+1:0] rx_data, // data + byte enable
   output logic                  rx_valid,

   input logic                   tx_en,
   input logic [DATA_WIDTH-1:0]  tx_data,
   output logic                  tx_full
   );

   typedef enum logic [2:0]      {idle, begin_write, write, begin_read, read} state_type;

   fifo_if #(.DATA_WIDTH(DATA_WIDTH+2)) rx_fifo (.rd_clk(clk), .wr_clk(ft.clk));
   fifo_if #(.DATA_WIDTH(DATA_WIDTH)) tx_fifo (.rd_clk(ft.clk), .wr_clk(clk));

   // signal declare
   state_type                    state_reg, state_next;
   logic [DATA_WIDTH-1:0]        data_in, data_reg;
   logic [1:0]                   be_in, be_reg;
   logic                         rd_n_reg;
   logic                         wr_n_reg;
   logic                         oe_n_reg;

   // RX FIFO reset 5 clocks by wr_clk
   xpm_cdc_sync_rst
     #(.DEST_SYNC_FF(5)) rx_fifo_rst_unit
     (
      .src_rst(rst),
      .dest_clk(rx_fifo.wr_clk),
      .dest_rst(rx_fifo.rst)
      );

   // TX FIFO reset 5 clocks by wr_clk
   xpm_cdc_sync_rst
     #(.DEST_SYNC_FF(5)) tx_fifo_rst_unit
     (
      .src_rst(rst),
      .dest_clk(tx_fifo.wr_clk),
      .dest_rst(tx_fifo.rst)
      );

   // RX FIFO
   xpm_fifo_async
     #(.CDC_SYNC_STAGES(2),
       .FIFO_MEMORY_TYPE("auto"),
       .FIFO_WRITE_DEPTH(RX_FIFO_DEPTH),
       .PROG_FULL_THRESH(RX_FIFO_DEPTH-16),
       .READ_DATA_WIDTH(DATA_WIDTH+2),
       .READ_MODE("fwft"),
       .WRITE_DATA_WIDTH(DATA_WIDTH+2),
`ifdef SYNTHESIS
       .USE_ADV_FEATURES("1002")
`else
       .RD_DATA_COUNT_WIDTH($clog2(RX_FIFO_DEPTH)+1),
       .WR_DATA_COUNT_WIDTH($clog2(RX_FIFO_DEPTH)+1),
       .USE_ADV_FEATURES("1707")
`endif
       ) rx_fifo_unit
       (
        .dout(rx_fifo.dout),
        .empty(rx_fifo.empty),
        .full(rx_fifo.full),
        .rd_rst_busy(rx_fifo.rd_rst_busy),
        .wr_rst_busy(rx_fifo.wr_rst_busy),
        .din(rx_fifo.din),
        .rd_clk(rx_fifo.rd_clk),
        .rd_en(rx_fifo.rd_en),
        .rst(rx_fifo.rst),
        .wr_clk(rx_fifo.wr_clk),
        .wr_en(rx_fifo.wr_en),
        .data_valid(rx_fifo.data_valid),
        .prog_full(rx_fifo.prog_full),
        // default input
        .sleep(0),
        .injectsbiterr(0),
        .injectdbiterr(0)
        );

   // TX FIFO
   xpm_fifo_async
     #(.CDC_SYNC_STAGES(2),
       .FIFO_MEMORY_TYPE("auto"),
       .FIFO_WRITE_DEPTH(TX_FIFO_DEPTH),
       .READ_DATA_WIDTH(DATA_WIDTH),
       .WRITE_DATA_WIDTH(DATA_WIDTH),
`ifdef SYNTHESIS
       .USE_ADV_FEATURES("0000")
`else
       .RD_DATA_COUNT_WIDTH($clog2(TX_FIFO_DEPTH)+1),
       .WR_DATA_COUNT_WIDTH($clog2(TX_FIFO_DEPTH)+1),
       .USE_ADV_FEATURES("0707")
`endif
       ) tx_fifo_unit
       (
        .dout(tx_fifo.dout),
        .empty(tx_fifo.empty),
        .full(tx_fifo.full),
        .rd_rst_busy(tx_fifo.rd_rst_busy),
        .wr_rst_busy(tx_fifo.wr_rst_busy),
        .din(tx_fifo.din),
        .rd_clk(tx_fifo.rd_clk),
        .rd_en(tx_fifo.rd_en),
        .rst(tx_fifo.rst),
        .wr_clk(tx_fifo.wr_clk),
        .wr_en(tx_fifo.wr_en),
        // default input
        .sleep(0),
        .injectsbiterr(0),
        .injectdbiterr(0)
        );

   always_ff @(posedge ft.clk, posedge rst)
     if (rst)
       state_reg <= idle;
     else
       state_reg <= state_next;

   always_comb
     begin
        state_next = state_reg;

        wr_n_reg = 1'b1;
        oe_n_reg = 1'b1;
        rd_n_reg = 1'b1;

        tx_fifo.rd_en = 1'b0;
        rx_fifo.wr_en = 1'b0;
        rx_fifo.din = {be_in, data_in};

        be_reg = 2'b11;
        data_reg = tx_fifo.dout;

        // write condition
        //  - ft_txe_n = 0
        //  - TX FIFO not empty
        //
        // read condition
        //  - ft_rxf_n = 0
        //  - ft_be != 0
        //  - RX FIFO not full
        case (state_reg)
          idle:
            begin
               if (!ft.rxf_n && !rx_fifo.prog_full)
                 begin
                    state_next = begin_read;
                    oe_n_reg = 1'b0;
                 end
               else if (!ft.txe_n && !tx_fifo.empty)
                 begin
                    state_next = begin_write;

                    // 1 clock latency on FIFO read (FIFO_READ_LATENCY)
                    // total 2 clock latency after first txe_n
                    tx_fifo.rd_en = 1'b1;
                 end
            end // case: idle
          begin_write:
            if (!ft.txe_n)
              begin
                 // valid data for tx on next clock edge
                 state_next = write;

                 tx_fifo.rd_en = !tx_fifo.empty;
              end
            else
              state_next = idle;

          write:
            begin
               if (!ft.txe_n)
                 begin
                    wr_n_reg = 1'b0;

                    if (!tx_fifo.empty)
                      tx_fifo.rd_en = 1'b1;
                    else
                      state_next = idle;

                 end
               else if (!ft.rxf_n && !rx_fifo.prog_full)
                 begin
                    state_next = begin_read;
                    oe_n_reg = 1'b0;
                 end
               else
                 state_next = idle;
            end
          begin_read:
            begin
               // read condition
               if (!ft.rxf_n && !rx_fifo.prog_full)
                 begin
                    state_next = read;
                    oe_n_reg = 1'b0;
                    rd_n_reg = 1'b0;
                 end
               else if (!ft.txe_n && !tx_fifo.empty)
                 begin
                    state_next = begin_write;

                    // 1 clock latency on FIFO read (FIFO_READ_LATENCY)
                    tx_fifo.rd_en = 1'b1;
                 end
               else
                 state_next = idle;
            end
          read:
            begin
               if (!ft.rxf_n && !rx_fifo.prog_full)
                 begin
                    oe_n_reg = 1'b0;
                    rd_n_reg = 1'b0;

                    rx_fifo.wr_en = 1'b1;
                 end
               else if (!ft.txe_n && !tx_fifo.empty)
                 begin
                    state_next = begin_write;

                    // 1 clock latency on FIFO read (FIFO_READ_LATENCY)
                    tx_fifo.rd_en = 1'b1;
                 end
               else
                 state_next = idle;
            end // case: read
          default:
            state_next = idle;

        endcase // case (state_reg)
     end // always_comb

   // FT600 signals
   assign ft.data = !oe_n_reg ? 'z : data_reg;
   assign data_in = ft.data;

   assign ft.be = !oe_n_reg ? 'z : be_reg;
   assign be_in = ft.be;

   assign ft.rd_n = rd_n_reg;
   assign ft.wr_n = wr_n_reg;
   assign ft.oe_n = oe_n_reg;

   // RX signals
   assign rx_fifo.rd_en = !rx_fifo.rd_rst_busy && rx_en;
   assign rx_data = rx_fifo.dout;
   assign rx_valid = !rx_fifo.rd_rst_busy && rx_fifo.data_valid;

   // TX signals
   assign tx_fifo.wr_en = !tx_fifo.wr_rst_busy && tx_en;
   assign tx_fifo.din = tx_data;
   assign tx_full = tx_fifo.wr_rst_busy || tx_fifo.full;

endmodule: ft600

`end_keywords
