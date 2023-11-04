/**
 * @file ft600_write.sv
 * @brief FT600 HDL top level module
 *
 * Origin from Alchitry Labs
 */
module ft600_write
  #(parameter TX_FIFO_DEPTH=512)
   (
    input logic clk,
    input logic rst,
    input logic ft_clk,
    input logic ft_txe_n, // tx empty
    output logic [15:0] ft_data,
    output logic [1:0] ft_be,
    output logic ft_wr_n,
    input [15:0] din,
    input [1:0] din_valid,
    output logic full,
    output logic rst_busy
    );

   logic [15:0]  data_write;
   logic [1:0]   be_write;
   logic         rst_out;
   logic         fifo_full;
   logic [17:0]  fifo_dout;
   logic         fifo_empty;
   logic [17:0]  fifo_din;
   logic         fifo_wput;
   logic         fifo_rget;
   logic         fifo_wr_rst_busy;
   logic         fifo_rd_rst_busy;

   // fifo reset 5 clock by wr_clk
   reset_conditioner #(.STAGES(5)) fifo_rst_unit
     (.clk(clk),
      .in(rst),
      .out(rst_out)
      );

   // Xilinx FIFO macro
   xpm_fifo_async
     #(.CDC_SYNC_STAGES(2),
       .FIFO_MEMORY_TYPE("block"),
       .FIFO_WRITE_DEPTH(TX_FIFO_DEPTH),
       .READ_DATA_WIDTH(18),
       .WRITE_DATA_WIDTH(18),
       .USE_ADV_FEATURES("0000")
       ) write_fifo
       (.dout(fifo_dout),
        .empty(fifo_empty),
        .full(fifo_full),
        .rd_rst_busy(fifo_rd_rst_busy),
        .wr_rst_busy(fifo_wr_rst_busy),
        .din(fifo_din),
        .rd_clk(ft_clk),
        .rd_en(fifo_rget),
        .rst(rst_out),
        .wr_clk(clk),
        .wr_en(fifo_wput),
        // default input
        .sleep(0),
        .injectsbiterr(0),
        .injectdbiterr(0)
        );

   always_comb
     begin
        fifo_wput = (|din_valid); // reduction. all bits OR
        fifo_din = {din_valid, din};
        full = fifo_full;

        be_write = fifo_dout[17:16];
        data_write = fifo_dout[15:0];

        ft_wr_n = fifo_empty; // write enable if not empty
        fifo_rget = ~fifo_rd_rst_busy & ~ft_txe_n; // get on txempty
     end

   // output
   genvar        idx;
   generate
      for (idx = 0; idx < 16; idx = idx + 1)
        begin
           assign ft_data[idx] = data_write[idx];
        end
   endgenerate

   assign ft_be[0] = be_write[0];
   assign ft_be[1] = be_write[1];

   assign rst_busy = fifo_wr_rst_busy | fifo_rd_rst_busy;

endmodule // ft600_write
