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
  import ft_mcs_pkg::*;
  #(
    parameter N_LED = 8
    )
   (
    wishbone_if.slave        wb,

    // LEDs
    output logic [N_LED-1:0] led,

    // uart
    input logic              rx,
    output logic             tx,

    // FT
    ft600_if.master          ft
    );

   // signal
   logic [`NUM_SLOTS-1:0]    CYC_array;
   logic [`NUM_SLOTS-1:0]    STB_array;
   logic [`NUM_SLOTS-1:0]    WE_array;
   // Note that different size from wb.ADDR. It will be shrink to REG_ADDR_WIDTH in mmio_controller
   logic [`REG_ADDR_WIDTH-1:0] ADDR_array [`NUM_SLOTS-1:0];
   logic [`DATA_WIDTH-1:0]     DAT_I_array [`NUM_SLOTS-1:0]; // data input on slave
   logic [`DATA_WIDTH-1:0]     DAT_O_array [`NUM_SLOTS-1:0]; // data output on slave
   logic [`NUM_SLOTS-1:0]      ACK_array;

   // body
   mmio_controller ctrl_unit
     (
      .wb(wb),

      // WISHBONE interface for slot
      .CYC_array(CYC_array),
      .STB_array(STB_array),
      .WE_array(WE_array),
      .ADDR_array(ADDR_array),
      .DAT_I_array(DAT_I_array),
      .DAT_O_array(DAT_O_array),
      .ACK_array(ACK_array)
      );

   // slot 0: timer
   wishbone_if #(.ADDR_WIDTH(`REG_ADDR_WIDTH), .DATA_WIDTH(`DATA_WIDTH)) timer_wb
     (.CLK(wb.CLK), .RST(wb.RST));

   assign timer_wb.ADDR = ADDR_array[`S0_SYS_TIMER];
   assign timer_wb.DAT_I = DAT_I_array[`S0_SYS_TIMER];
   assign DAT_O_array[`S0_SYS_TIMER] = timer_wb.DAT_O;
   assign timer_wb.CYC = CYC_array[`S0_SYS_TIMER];
   assign timer_wb.STB = STB_array[`S0_SYS_TIMER];
   assign timer_wb.WE = WE_array[`S0_SYS_TIMER];
   assign ACK_array[`S0_SYS_TIMER] = timer_wb.ACK;

   dev_timer timer_slot0 (.wb(timer_wb));

   // slot 1: UART
   wishbone_if #(.ADDR_WIDTH(`REG_ADDR_WIDTH), .DATA_WIDTH(`DATA_WIDTH)) uart_wb
     (.CLK(wb.CLK), .RST(wb.RST));

   assign uart_wb.ADDR = ADDR_array[`S1_UART1];
   assign uart_wb.DAT_I = DAT_I_array[`S1_UART1];
   assign DAT_O_array[`S1_UART1] = uart_wb.DAT_O;
   assign uart_wb.CYC = CYC_array[`S1_UART1];
   assign uart_wb.STB = STB_array[`S1_UART1];
   assign uart_wb.WE = WE_array[`S1_UART1];
   assign ACK_array[`S1_UART1] = uart_wb.ACK;

   dev_uart uart_slot1 (.wb(uart_wb), .tx(tx), .rx(rx));

   // slot 2: GPO
   wishbone_if #(.ADDR_WIDTH(`REG_ADDR_WIDTH), .DATA_WIDTH(`DATA_WIDTH)) gpo_wb
     (.CLK(wb.CLK), .RST(wb.RST));

   assign gpo_wb.ADDR = ADDR_array[`S2_LED];
   assign gpo_wb.DAT_I = DAT_I_array[`S2_LED];
   assign DAT_O_array[`S2_LED] = gpo_wb.DAT_O;
   assign gpo_wb.CYC = CYC_array[`S2_LED];
   assign gpo_wb.STB = STB_array[`S2_LED];
   assign gpo_wb.WE = WE_array[`S2_LED];
   assign ACK_array[`S2_LED] = gpo_wb.ACK;

   dev_gpo #(.W(N_LED)) gpo_slot2 (.wb(gpo_wb), .dout(led));

   // slot 3: FT600
   wishbone_if #(.ADDR_WIDTH(`REG_ADDR_WIDTH), .DATA_WIDTH(`DATA_WIDTH)) ft_wb
     (.CLK(wb.CLK), .RST(wb.RST));

   assign ft_wb.ADDR = ADDR_array[`S3_FT];
   assign ft_wb.DAT_I = DAT_I_array[`S3_FT];
   assign DAT_O_array[`S3_FT] = ft_wb.DAT_O;
   assign ft_wb.CYC = CYC_array[`S3_FT];
   assign ft_wb.STB = STB_array[`S3_FT];
   assign ft_wb.WE = WE_array[`S3_FT];
   assign ACK_array[`S3_FT] = ft_wb.ACK;

   dev_ft600 ft_slot3 (.wb(ft_wb), .ft(ft));

   // assign default value to unused slot signals
   generate
      genvar                   i;

      for (i = 4; i < `NUM_SLOTS; i = i + 1)
        begin: unused_slot_gen
           assign DAT_O_array[i] = 32'h0000_0000;
           assign ACK_array[i] = 1'b1;
        end
      endgenerate

endmodule: mmio_sys

`end_keywords
