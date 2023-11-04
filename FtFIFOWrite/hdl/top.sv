/**
 * @file top.sv
 * @brief top level HDL
 */
module top
  (
   input logic clk,
   input logic rst_n,
   output logic [7:0] led,
   input logic ft_clk,
   input logic ft_rxf_n,
   input logic ft_txe_n,
   output logic [15:0] ft_data,
   output logic [1:0] ft_be,
   output logic ft_rd_n,
   output logic ft_wr_n,
   output logic ft_oe_n
   );

   logic        rst;
   logic [15:0] din_reg, din_next;
   logic [1:0]  din_valid_reg, din_valid_next;
   logic        full, rst_busy;
   logic [7:0]  led_reg, led_next;

   assign rst = ~rst_n;

   ft600_write #(.TX_FIFO_DEPTH(512)) ft600
     (.clk(clk),
      .rst(rst),
      .ft_clk(ft_clk),
      .ft_txe_n(ft_txe_n),
      .ft_data(ft_data),
      .ft_be(ft_be),
      .ft_wr_n(ft_wr_n),
      .din(din_reg),
      .din_valid(din_valid_reg),
      .full(full),
      .rst_busy(rst_busy)
      );

   always_ff @(posedge clk)
     begin
        if (rst)
          begin
             din_reg <= 0;
             din_valid_reg <= 0;
             led_reg <= 0;
          end
        else
          begin
             din_reg <= din_next;
             din_valid_reg <= din_valid_next;
             led_reg <= led_next;
          end
     end

   always_comb
     begin
        if (rst_busy)
          begin
             din_next = din_reg;
             din_valid_next = 2'b00;
             led_next = {7'b0000101, ~ft_txe_n};
          end
        else if (full)
          begin
             din_next = din_reg;
             din_valid_next = 2'b00;
             led_next = {7'b0000001, ~ft_txe_n};
          end
        else
          begin
             // increase if not full
             din_next = din_reg + 1;
             // 현재는 245 mode로만 사용하므로 2'b11 로 고정하여도 됨
             din_valid_next = 2'b11;
             led_next = {7'b1111001, ~ft_txe_n};
          end
     end

   // output
   assign led = led_reg;
   assign ft_rd_n = 1;
   assign ft_oe_n = 1;

endmodule // top
