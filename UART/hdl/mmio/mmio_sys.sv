/**
 * @file mmio_sys.sv
 * @brief MMIO system HDL
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * 3 I/O cores: timer, UART, GPO
 */
`include "io_map.svh"
module mmio_sys
  #(
    parameter N_LED = 8
    )
   (
    input logic              clk,
    input logic              reset,
    // FPro bus
    input logic              mmio_cs,
    input logic              mmio_wr,
    input logic              mmio_rd,
    input logic [20:0]       mmio_addr,
    input logic [31:0]       mmio_wr_data,
    output logic [31:0]      mmio_rd_data,
    // LEDs
    output logic [N_LED-1:0] led,
    // uart
    input logic              rx,
    output logic             tx
    );

   // signal
   logic [63:0]              mem_rd_array;
   logic [63:0]              mem_wr_array;
   logic [63:0]              cs_array;
   logic [4:0]               reg_addr_array [63:0];
   logic [31:0]              rd_data_array [63:0];
   logic [31:0]              wr_data_array [63:0];

   // body
   mmio_controller ctrl_unit
     (.clk(clk),
      .reset(reset),
      .mmio_cs(mmio_cs),
      .mmio_wr(mmio_wr),
      .mmio_rd(mmio_rd),
      .mmio_addr(mmio_addr),
      .mmio_wr_data(mmio_wr_data),
      .mmio_rd_data(mmio_rd_data),
      // slot interface
      .slot_cs_array(cs_array),
      .slot_mem_rd_array(mem_rd_array),
      .slot_mem_wr_array(mem_wr_array),
      .slot_reg_addr_array(reg_addr_array),
      .slot_rd_data_array(rd_data_array),
      .slot_wr_data_array(wr_data_array)
      );

   // slot 0: timer
   dev_timer timer_slot0
     (.clk(clk),
      .reset(reset),
      .cs(cs_array[`S0_SYS_TIMER]),
      .read(mem_rd_array[`S0_SYS_TIMER]),
      .write(mem_wr_array[`S0_SYS_TIMER]),
      .addr(reg_addr_array[`S0_SYS_TIMER]),
      .rd_data(rd_data_array[`S0_SYS_TIMER]),
      .wr_data(wr_data_array[`S0_SYS_TIMER])
      );

   // slot 1: UART
   dev_uart uart_slot1
     (.clk(clk),
      .reset(reset),
      .cs(cs_array[`S1_UART1]),
      .read(mem_rd_array[`S1_UART1]),
      .write(mem_wr_array[`S1_UART1]),
      .addr(reg_addr_array[`S1_UART1]),
      .rd_data(rd_data_array[`S1_UART1]),
      .wr_data(wr_data_array[`S1_UART1]),
      .tx(tx),
      .rx(rx)
      );

   // slot 2: GPO
   dev_gpo #(.W(N_LED)) gpo_slot2
     (.clk(clk),
      .reset(reset),
      .cs(cs_array[`S2_LED]),
      .read(mem_rd_array[`S2_LED]),
      .write(mem_wr_array[`S2_LED]),
      .addr(reg_addr_array[`S2_LED]),
      .rd_data(rd_data_array[`S2_LED]),
      .wr_data(wr_data_array[`S2_LED]),
      .dout(led)
      );
   
   // assign 0's to all unused slot rd_data signals
   generate
      genvar                 i;

      for (i = 3; i < 64; i = i + 1)
        begin: unused_slot_gen
           assign rd_data_array[i] = 32'hffffffff;
        end
      endgenerate

endmodule // mmio_sys
