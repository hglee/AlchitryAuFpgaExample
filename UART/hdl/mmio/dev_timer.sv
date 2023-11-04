/**
 * @file dev_timer.sv
 * @brief Timer HDL module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
module dev_timer
  (
   input logic clk,
   input logic reset,
   // slot interface
   input logic cs,
   input logic read,
   input logic write,
   input logic [4:0] addr,
   input logic [31:0] wr_data,
   output logic [31:0] rd_data
   );

   // signal
   logic [47:0]        count_reg;
   logic               ctrl_reg;
   logic               wr_en, clear, go;

   /////////////////////////////////////////////////////////////////////////////
   // counter
   always_ff @(posedge clk, posedge reset)
     if (reset)
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
   always_ff @(posedge clk, posedge reset)
     if (reset)
       ctrl_reg <= 0;
     else
       if (wr_en)
         ctrl_reg <= wr_data[0]; // wr_en일 때 최하위 bit 할당

   // decoding
   assign wr_en = write && cs && (addr[1:0] == 2'b10); // addr에 따라서 wr_en
   assign clear = wr_en && wr_data[1];
   assign go = ctrl_reg;
   // slot read interface
   assign rd_data = (addr[0] == 0) ?
                    count_reg[31:0]: // 하위 32bit
                    {16'h0000, count_reg[47:32]}; // 상위 16 bit

endmodule // dev_timer
