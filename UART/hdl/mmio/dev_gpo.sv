/**
 * @file dev_gpo.sv
 * @brief GPO HDL module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * rd_data는 합성시 0으로 연결됨
 */
module dev_gpo
  #(parameter W = 8) // width of output port
   (
    input logic clk,
    input logic reset,
    // slot interface
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // external signal
    output logic [W-1:0] dout
    );

   // signal
   logic [W-1:0]         buf_reg;
   logic                 wr_en;

   // body
   // output buffer
   always_ff @(posedge clk, posedge reset)
     if (reset)
       buf_reg <= 0;
     else
       if (wr_en)
         buf_reg <= wr_data[W-1:0];

   // decoding logic
   assign wr_en = cs && write;
   // slot read interface
   assign rd_data = 0;
   // external output
   assign dout = buf_reg;
endmodule // dev_gpo

