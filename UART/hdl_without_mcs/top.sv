/**
 * @file top.sv
 * @brief top level HDL
 */
module top
   (
    input logic clk,
    input logic reset_n,
    // LED
    output logic [7:0] led,
    // uart
    output logic tx
    );

   // localparam declaration
   localparam sys_clk_hz = 100 * 1000000;
   localparam dvsr_9600 = (sys_clk_hz / 16 / 9600) - 1;
   localparam wait_count_1000ms = sys_clk_hz;
   localparam uart_text_len = 14;

   typedef enum  {tx_text, wait_next} state_type;

   // signal declaration
   logic [7:0]   uart_text [0:uart_text_len-1];
   logic [7:0]   uart_text_index_reg, uart_text_index_next;
   logic         reset;
   logic [10:0]  dvsr; // select enought bit size to match baud rate divisor
   logic         start_tick;
   logic         tx_start_reg, tx_start_next;
   logic [7:0]   din_reg, din_next;
   logic         tx_done_tick;
   logic         state_reg, state_next;
   logic [27:0]  wait_count_reg, wait_count_next; // select enough bit size to match wait_count

   // Load uart_text.txt to initial values of ram
   // You can generate uart_text.txt using script (generate_uart_text.py)
   // If you changed uart_text.txt, you need to change uart_text_len.
   initial
     $readmemh("uart_text.txt", uart_text);

   assign reset = ~reset_n;
   assign dvsr = dvsr_9600;

   // instantiate baud rate generator
   baud_gen baud_unit
     (.clk(clk),
      .reset(reset),
      .dvsr(dvsr),
      .tick(start_tick)
      );

   // instantiate UART TX unit
   uart_tx #(.DBIT(8), .SB_TICK(16)) uart_tx_unit
     (.clk(clk),
      .reset(reset),
      .tx_start(tx_start_reg),
      .s_tick(start_tick),
      .din(din_reg),
      .tx_done_tick(tx_done_tick),
      .tx(tx)
      );

   always_ff @(posedge clk, posedge reset)
     if (reset)
       begin
          // reset to init values
          uart_text_index_reg <= 7'b0;
          tx_start_reg <= 1;
          din_reg <= uart_text[0];
          state_reg <= tx_text;
          wait_count_reg <= 27'b0;
       end
     else
       begin
          uart_text_index_reg <= uart_text_index_next;
          tx_start_reg <= tx_start_next;
          din_reg <= din_next;
          state_reg <= state_next;
          wait_count_reg <= wait_count_next;
       end

   always_comb
     begin
        // default value
        uart_text_index_next = uart_text_index_reg;
        tx_start_next = tx_start_reg;
        din_next = din_reg;
        state_next = state_reg;
        wait_count_next = wait_count_reg;

        case (state_reg)
          tx_text: begin
             if (tx_done_tick)
               begin
                  if (uart_text_index_reg >= uart_text_len -1)
                    // switch to wait on end
                    begin
                       tx_start_next = 0;
                       state_next = wait_next;
                       wait_count_next = 27'b0;
                    end
                  else
                    // set to next character
                    begin
                       uart_text_index_next = uart_text_index_reg + 7'b1;
                       din_next = uart_text[uart_text_index_reg + 7'b1];
                    end
               end
          end

          default: begin // wait_next
             if (wait_count_reg == wait_count_1000ms)
               // start tx again
               begin
                  uart_text_index_next = 7'b0;
                  tx_start_next = 1;
                  din_next = uart_text[0];
                  state_next = tx_text;
               end
             else
               wait_count_next = wait_count_reg + 27'b1;
          end
        endcase // case (state_reg)
     end

   // output
   assign led = {(state_reg == tx_text) ? 1'b1 : 1'b0, 7'b0000001};

endmodule // top
