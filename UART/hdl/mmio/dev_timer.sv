/**
 * @file dev_timer.sv
 * @brief Timer HDL module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

`include "io_map.svh"

module dev_timer
  import vanilla_pkg::*;
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
   output logic                      ACK_O
   );

   // signal
   logic [47:0]        count_reg;
   logic               ctrl_reg, ack_reg;
   logic               rd_en, wr_en, clear, go;

   /////////////////////////////////////////////////////////////////////////////
   // counter
   always_ff @(posedge CLK_I, posedge RST_I)
     if (RST_I)
       count_reg <= 0;
     else
       if (clear)
         count_reg <= 0;
       else if (go)
         count_reg <= count_reg + 1;

   /////////////////////////////////////////////////////////////////////////////
   // wrapping
   /////////////////////////////////////////////////////////////////////////////
   // ctrl register
   always_ff @(posedge CLK_I, posedge RST_I)
     if (RST_I)
       begin
          ctrl_reg <= 0;
          ack_reg <= 0;
       end
     else
       begin
          if (wr_en)
            ctrl_reg <= DAT_I[0]; // wr_en일 때 최하위 bit 할당

          ack_reg = CYC_I && STB_I;
       end

   // decoding
   assign rd_en = CYC_I && STB_I && !WE_I;
   assign wr_en = CYC_I && STB_I && WE_I && (ADDR_I[1:0] == 2'b10); // addr에 따라서 wr_en
   assign clear = wr_en && DAT_I[1];
   assign go = ctrl_reg;
   // slot read interface
   assign DAT_O = rd_en ?
                  ((ADDR_I[0] == 0) ?
                   count_reg[31:0]: // 하위 32bit
                   {16'h0000, count_reg[47:32]}) : // 상위 16 bit
                  32'b0;
   assign ACK_O = ack_reg;

endmodule: dev_timer

`end_keywords
