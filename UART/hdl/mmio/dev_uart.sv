/**
 * @file dev_uart.sv
 * @brief UART HDL top level module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

`include "io_map.svh"

module dev_uart
  import vanilla_pkg::*;
   #(parameter FIFO_DEPTH_BIT = 8)
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

    // external IO
    output logic                      tx,
    input logic                       rx
    );

   // signal declaration
   logic                rd_en, wr_en;
   logic                wr_uart, rd_uart, wr_dvsr;
   logic                tx_full, rx_empty;
   logic [10:0]         dvsr_reg;
   logic [7:0]          r_data;
   logic                ack_reg;

   // body
   uart #(.DBIT(8), .SB_TICK(16), .FIFO_W(FIFO_DEPTH_BIT)) uart_unit
     (.*, .clk(CLK_I), .reset(RST_I), .dvsr(dvsr_reg), .w_data(DAT_I[7:0]));

   // dvsr register
   always_ff @(posedge CLK_I, posedge RST_I)
     if (RST_I)
       begin
          dvsr_reg <= 0;
          ack_reg <= 0;
       end
     else
       begin
          if (wr_dvsr)
            dvsr_reg <= DAT_I[10:0];

          ack_reg <= CYC_I && STB_I;
       end

   // decoding logic. addr 하위 2 bit 사용
   assign rd_en = CYC_I && STB_I && !WE_I;
   assign wr_en = CYC_I && STB_I && WE_I;
   assign wr_dvsr = (wr_en && (ADDR_I[1:0] == 2'b01));
   assign wr_uart = (wr_en && (ADDR_I[1:0] == 2'b10));
   assign rd_uart = (wr_en && (ADDR_I[1:0] == 2'b11));

   // slot read interface. 하위 10 bit만 사용
   assign DAT_O = {22'h000000, tx_full, rx_empty, r_data};
   assign ACK_O = ack_reg;

endmodule: dev_uart

`end_keywords
