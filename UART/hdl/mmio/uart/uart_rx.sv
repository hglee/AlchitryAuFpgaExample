/**
 * @file uart_rx.sv
 * @brief UART receiver HDL
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

module uart_rx
  #(
    parameter DBIT = 8, // data bits
    SB_TICK = 16 // ticks for stop bits. 16 => 1, 24 => 1.5, 32 => 2 stop bits
    )
   (
    input logic clk, reset,
    input logic rx, s_tick,
    output logic rx_done_tick,
    output logic [7:0] dout
    );

   // fsm state
   typedef enum logic [1:0] {idle, start, data, stop} state_type;

   // signal declare
   state_type state_reg, state_next;
   logic [3:0]  s_reg, s_next;
   logic [2:0]  n_reg, n_next;
   logic [7:0]  b_reg, b_next;

   // body
   // FSMD state & data register
   always_ff @(posedge clk, posedge reset)
     if (reset) begin
        state_reg <= idle;
        s_reg <= 0;
        n_reg <= 0;
        b_reg <= 0;
     end
     else begin
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
     end // else: !if(reset)

   // FSMD next-state logic
   always_comb
     begin
        state_next = state_reg;
        rx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        case (state_reg)
          idle:
            // 시작 시 start bit low가 됨
            if (~rx) begin
               state_next = start;
               s_next = 0;
            end
          start:
            if (s_tick)
              // start bit 이후 실제 data
              if (s_reg == 7) begin
                 state_next = data;
                 s_next = 0;
                 n_next = 0;
              end
              else
                s_next = s_reg + 1;
          data:
            if (s_tick)
              // sample rate으로 지정한 16마다 다음 bit
              if (s_reg == 15) begin
                 s_next = 0;
                 b_next = {rx, b_reg[7:1]};
                 if (n_reg == (DBIT-1))
                   state_next = stop;
                 else
                   n_next = n_reg + 1;
              end
              else
                s_next = s_reg + 1;
          stop:
            if (s_tick)
              // stop bit 이후 done
              if (s_reg == (SB_TICK-1)) begin
                 state_next = idle;
                 rx_done_tick = 1'b1;
              end
              else
                s_next = s_reg + 1;
        endcase // case (state_reg)
     end // always_comb
   // output
   assign dout = b_reg;

endmodule: uart_rx

`end_keywords
