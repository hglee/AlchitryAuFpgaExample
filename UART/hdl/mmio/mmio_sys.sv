/**
 * @file mmio_sys.sv
 * @brief MMIO system HDL
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * 3 I/O cores: timer, UART, GPO
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

`include "io_map.svh"

module mmio_sys
  import vanilla_pkg::*;
  #(
    parameter N_LED = 8
    )
   (
    // WISHBONE interface
    input logic                        CLK_I,
    input logic                        RST_I,
    input logic [`MMIO_ADDR_WIDTH-1:0] ADDR_I,
    input logic [`DATA_WIDTH-1:0]      DAT_I,
    output logic [`DATA_WIDTH-1:0]     DAT_O,
    input logic                        CYC_I,
    input logic                        STB_I,
    input logic                        WE_I,
    output logic                       ACK_O,

    // LEDs
    output logic [N_LED-1:0]           led,

    // uart
    input logic                        rx,
    output logic                       tx
    );

   // signal
   logic [`NUM_SLOTS-1:0]              CYC_O_array;
   logic [`NUM_SLOTS-1:0]              STB_O_array;
   logic [`NUM_SLOTS-1:0]              WE_O_array;
   logic [`REG_ADDR_WIDTH-1:0]         ADDR_O_array [`NUM_SLOTS-1:0];
   logic [`DATA_WIDTH-1:0]             DAT_I_array [`NUM_SLOTS-1:0];
   logic [`DATA_WIDTH-1:0]             DAT_O_array [`NUM_SLOTS-1:0];
   logic [`NUM_SLOTS-1:0]              ACK_I_array;

   // body
   mmio_controller ctrl_unit
     (
      // WISHBONE interface
      .CLK_I(CLK_I),
      .RST_I(RST_I),
      .ADDR_I(ADDR_I),
      .DAT_I(DAT_I),
      .DAT_O(DAT_O),
      .CYC_I(CYC_I),
      .STB_I(STB_I),
      .WE_I(WE_I),
      .ACK_O(ACK_O),

      // WISHBONE interface for slot
      .CYC_O_array(CYC_O_array),
      .STB_O_array(STB_O_array),
      .WE_O_array(WE_O_array),
      .ADDR_O_array(ADDR_O_array),
      .DAT_I_array(DAT_I_array),
      .DAT_O_array(DAT_O_array),
      .ACK_I_array(ACK_I_array)
      );

   // slot 0: timer
   dev_timer timer_slot0
     (
      .CLK_I(CLK_I),
      .RST_I(RST_I),
      .ADDR_I(ADDR_O_array[`S0_SYS_TIMER]),
      .DAT_I(DAT_O_array[`S0_SYS_TIMER]),
      .DAT_O(DAT_I_array[`S0_SYS_TIMER]),
      .CYC_I(CYC_O_array[`S0_SYS_TIMER]),
      .STB_I(STB_O_array[`S0_SYS_TIMER]),
      .WE_I(WE_O_array[`S0_SYS_TIMER]),
      .ACK_O(ACK_I_array[`S0_SYS_TIMER])
      );

   // slot 1: UART
   dev_uart uart_slot1
     (
      .CLK_I(CLK_I),
      .RST_I(RST_I),
      .ADDR_I(ADDR_O_array[`S1_UART1]),
      .DAT_I(DAT_O_array[`S1_UART1]),
      .DAT_O(DAT_I_array[`S1_UART1]),
      .CYC_I(CYC_O_array[`S1_UART1]),
      .STB_I(STB_O_array[`S1_UART1]),
      .WE_I(WE_O_array[`S1_UART1]),
      .ACK_O(ACK_I_array[`S1_UART1]),
      .tx(tx),
      .rx(rx)
      );

   // slot 2: GPO
   dev_gpo #(.W(N_LED)) gpo_slot2
     (
      .CLK_I(CLK_I),
      .RST_I(RST_I),
      .ADDR_I(ADDR_O_array[`S2_LED]),
      .DAT_I(DAT_O_array[`S2_LED]),
      .DAT_O(DAT_I_array[`S2_LED]),
      .CYC_I(CYC_O_array[`S2_LED]),
      .STB_I(STB_O_array[`S2_LED]),
      .WE_I(WE_O_array[`S2_LED]),
      .ACK_O(ACK_I_array[`S2_LED]),
      .dout(led)
      );

   // assign default value to unused slot signals
   generate
      genvar                 i;

      for (i = 3; i < `NUM_SLOTS; i = i + 1)
        begin: unused_slot_gen
           assign DAT_I_array[i] = 32'h0000_0000;
           assign ACK_I_array[i] = 1'b1;
        end
      endgenerate

endmodule: mmio_sys

`end_keywords
