/**
 * @file dev_uart.sv
 * @brief UART HDL top level module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
module dev_uart
  #(parameter FIFO_DEPTH_BIT = 8)
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
    output logic tx,
    input logic rx
    );

   // signal declaration
   logic        wr_uart, rd_uart, wr_dvsr;
   logic        tx_full, rx_empty;
   logic [10:0] dvsr_reg;
   logic [7:0]  r_data;
   logic        ctrl_reg;

   // body
   uart #(.DBIT(8), .SB_TICK(16), .FIFO_W(FIFO_DEPTH_BIT)) uart_unit
     (.*, .dvsr(dvsr_reg), .w_data(wr_data[7:0]));

   // dvsr register
   always_ff @(posedge clk, posedge reset)
     if (reset)
       dvsr_reg <= 0;
     else
       if (wr_dvsr)
         dvsr_reg <= wr_data[10:0];

   // decoding logic. addr 하위 2 bit 사용
   assign wr_dvsr = (write && cs && (addr[1:0] == 2'b01));
   assign wr_uart = (write && cs && (addr[1:0] == 2'b10));
   assign rd_uart = (write && cs && (addr[1:0] == 2'b11));

   // slot read interface. 하위 10 bit만 사용
   assign rd_data = {22'h000000, tx_full, rx_empty, r_data};
endmodule // dev_uart
