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

module dev_gpo
  #(parameter W = 8) // width of output port
   (
    wishbone_if.slave    wb,

    // external signal: digital output
    output logic [W-1:0] dout
    );

   // signal
   logic [W-1:0]         buf_reg;
   logic                 ack_reg;

   // body
   // output buffer
   always_ff @(posedge wb.CLK, posedge wb.RST)
     if (wb.RST)
       begin
          buf_reg <= 0;
          ack_reg <= 0;
       end
     else
       begin
          if (wb.CYC && wb.STB && wb.WE)
            buf_reg <= wb.DAT_I[W-1:0];

          ack_reg <= wb.CYC && wb.STB;
       end

   assign wb.DAT_O = 32'b0;
   assign wb.ACK = ack_reg;

   // external output
   assign dout = buf_reg;

endmodule: dev_gpo

`end_keywords
