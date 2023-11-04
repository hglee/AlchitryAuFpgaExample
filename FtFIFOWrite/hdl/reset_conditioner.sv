/**
 * @file reset_conditioner.sv
 * @brief reset HDL module
 *
 * Origin from Alchitry Labs
 *
 * stays reset while STAGES clock
 */
module reset_conditioner
  #(parameter STAGES=4)
   (
    input logic clk,
    input logic in,
    output logic out
    );

   logic [STAGES - 1:0] state_reg, state_next;

   // register
   always_ff @(posedge clk)
     begin
        if (in)
          state_reg <= ~0;
        else
          state_reg <= state_next;
     end

   // next state
   always_comb
     begin
        state_next = {state_reg[STAGES - 2:0], 1'h0};
     end

   // output
   assign out = state_reg[STAGES - 1];

endmodule // reset_conditioner
