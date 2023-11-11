/**
 * @file dev_gpo.sv
 * @brief GPO HDL module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * rd_data는 합성시 0으로 연결됨
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

`include "io_map.svh"

module dev_gpo
  import vanilla_pkg::*;
  #(parameter W = 8) // width of output port
   (
    // WISHBONE interface
    input logic                       CLK_I,
    input logic                       RST_I,
    input logic [`REG_ADDR_WIDTH-1:0] ADDR_I,
    input logic [`DATA_WIDTH-1:0]     DAT_I,
    output logic [`DATA_WIDTH-1:0]    DAT_O,
    input logic                       CYC_I,
    input logic                       STB_I,
    input logic                       WE_I,
    output logic                      ACK_O,

    // external signal: digital output
    output logic [W-1:0]              dout
    );

   // signal
   logic [W-1:0]         buf_reg;
   logic                 ack_reg;

   // body
   // output buffer
   always_ff @(posedge CLK_I, posedge RST_I)
     if (RST_I)
       begin
          buf_reg <= 0;
          ack_reg <= 0;
       end
     else
       begin
          if (CYC_I && STB_I && WE_I)
            buf_reg <= DAT_I[W-1:0];

          ack_reg <= CYC_I && STB_I;
       end

   assign DAT_O = 32'b0;
   assign ACK_O = ack_reg;

   // external output
   assign dout = buf_reg;

endmodule // dev_gpo

`end_keywords
