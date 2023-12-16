/**
 * @file dev_timer.sv
 * @brief Timer HDL module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

module dev_timer
   (
    wishbone_if.slave wb
    );

   // signal
   logic [47:0]        count_reg;
   logic               ctrl_reg, ack_reg;
   logic               rd_en, wr_en, clear, go;

   /////////////////////////////////////////////////////////////////////////////
   // counter
   always_ff @(posedge wb.CLK, posedge wb.RST)
     if (wb.RST)
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
   always_ff @(posedge wb.CLK, posedge wb.RST)
     if (wb.RST)
       begin
          ctrl_reg <= 0;
          ack_reg <= 0;
       end
     else
       begin
          if (wr_en)
            ctrl_reg <= wb.DAT_I[0]; // wr_en일 때 최하위 bit 할당

          ack_reg = wb.CYC && wb.STB;
       end

   // decoding
   assign rd_en = wb.CYC && wb.STB && !wb.WE;
   assign wr_en = wb.CYC && wb.STB && wb.WE && (wb.ADDR[1:0] == 2'b10); // addr에 따라서 wr_en
   assign clear = wr_en && wb.DAT_I[1];
   assign go = ctrl_reg;
   // slot read interface
   assign wb.DAT_O = rd_en ?
                     ((wb.ADDR[0] == 0) ?
                      count_reg[31:0]: // 하위 32bit
                      {16'h0000, count_reg[47:32]}) : // 상위 16 bit
                     32'b0;
   assign wb.ACK = ack_reg;

endmodule: dev_timer

`end_keywords
