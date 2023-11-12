/**
 * @file top.sv
 * @brief top level without FIFO HDL
 */
module top
  (
   input logic        clk,
   input logic        rst_n,
   output logic [7:0] led,
   input logic        ft_clk,
   input logic        ft_rxf_n, // rx full
   input logic        ft_txe_n, // tx empty
   input logic [15:0] ft_data, // data
   input logic [1:0]  ft_be, // byte enable
   output logic       ft_rd_n, // read enable
   output logic       ft_wr_n, // write enable
   output logic       ft_oe_n // output enable
   );

   logic [15:0]       rx_data;
   logic              rd_reg, rd_next;
   logic              oe_reg, oe_next;
   logic [7:0]        led_reg, led_next;

   always_ff @(posedge ft_clk)
     begin
        if (rst_n)
          begin
             // not reset
             rd_reg <= rd_next;
             oe_reg <= oe_next;
             led_reg <= led_next;
          end
        else
          begin
             // reset
             rd_reg <= 1;
             oe_reg <= 1;
             led_reg <= 0;
          end
     end

   always_comb
     begin
        if (ft_rxf_n)
          begin
             // empty
             oe_next = 1;
             rd_next = 1;
             led_next = 8'h01;
          end
        else
          begin
             // ready to read
             oe_next = 0;
             rd_next = 0;

             // real data on command
             if (ft_be == 2'b11)
               begin
                  rx_data = ft_data;
                  led_next = 8'hf1;
               end
             else
               led_next = 8'h11;
          end
     end

   // output
   assign led = led_reg;
   assign ft_rd_n = rd_reg;
   assign ft_wr_n = 1;
   assign ft_oe_n = oe_reg;

endmodule // top
