/**
 * @file baud_gen.sv
 * @brief baud rate generator: programmable counter
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * baud rate을 b, system clock rate를 f라고 할때
 * sample rate은 16 *b가 되고, count는 f / (16 * b)에서 wrap되어야 함
 * 따라서 v + 1 = f / (16 * b)
 * 즉 v = f / (16 * b) - 1
 */
module baud_gen
  (
   input logic clk, reset,
   input logic [10:0] dvsr,
   output logic tick
   );

   // declare
   logic [10:0] r_reg;
   logic [10:0] r_next;

   // body
   // register
   always_ff @(posedge clk, posedge reset)
     if (reset)
       r_reg <= 0;
     else
       r_reg <= r_next;

   // next state logic
   assign r_next = (r_reg == dvsr) ? 0 : r_reg + 1;

   // output logic
   assign tick = (r_reg == 1);
endmodule // baud_gen
