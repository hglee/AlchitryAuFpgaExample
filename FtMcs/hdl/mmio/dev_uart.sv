/**
 * @file dev_uart.sv
 * @brief UART HDL top level module
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

module dev_uart
   #(parameter FIFO_DEPTH_BIT = 8)
   (
    wishbone_if.slave wb,

    // external IO
    output logic      tx,
    input logic       rx
    );

   // signal declaration
   logic              rd_en, wr_en;
   logic              wr_uart, rd_uart, wr_dvsr;
   logic              tx_full, rx_empty;
   logic [10:0]       dvsr_reg;
   logic [7:0]        r_data;
   logic              ack_reg;

   // body
   uart #(.DBIT(8), .SB_TICK(16), .FIFO_W(FIFO_DEPTH_BIT)) uart_unit
     (.*, .clk(wb.CLK), .reset(wb.RST), .dvsr(dvsr_reg), .w_data(wb.DAT_I[7:0]));

   // dvsr register
   always_ff @(posedge wb.CLK, posedge wb.RST)
     if (wb.RST)
       begin
          dvsr_reg <= 0;
          ack_reg <= 0;
       end
     else
       begin
          if (wr_dvsr)
            dvsr_reg <= wb.DAT_I[10:0];

          ack_reg <= wb.CYC && wb.STB;
       end

   // decoding logic. addr 하위 2 bit 사용
   assign rd_en = wb.CYC && wb.STB && !wb.WE;
   assign wr_en = wb.CYC && wb.STB && wb.WE;
   assign wr_dvsr = (wr_en && (wb.ADDR[1:0] == 2'b01));
   assign wr_uart = (wr_en && (wb.ADDR[1:0] == 2'b10));
   assign rd_uart = (wr_en && (wb.ADDR[1:0] == 2'b11));

   // slot read interface. 하위 10 bit만 사용
   assign wb.DAT_O = {22'h000000, tx_full, rx_empty, r_data};
   assign wb.ACK = ack_reg;

endmodule: dev_uart

`end_keywords
