/**
 * @file mmio_controller.sv
 * @brief MMIO contoller
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

`include "io_map.svh"

module mmio_controller
  import ft_mcs_pkg::*;
  (
   wishbone_if.slave                  wb,

   // WISHBONE interface for slot
   output logic [`NUM_SLOTS-1:0]      CYC_array,
   output logic [`NUM_SLOTS-1:0]      STB_array,
   output logic [`NUM_SLOTS-1:0]      WE_array,
   output logic [`REG_ADDR_WIDTH-1:0] ADDR_array [`NUM_SLOTS-1:0],
   output logic [`DATA_WIDTH-1:0]      DAT_I_array [`NUM_SLOTS-1:0], // data input on slave
   input logic [`DATA_WIDTH-1:0]     DAT_O_array [`NUM_SLOTS-1:0], // data output on slave
   input logic [`NUM_SLOTS-1:0]       ACK_array
   );

   // declaration
   logic [`SLOT_ADDR_WIDTH-1:0]       slot_addr;
   logic [`REG_ADDR_WIDTH:0]          reg_addr;

   // body - total 11 bits used. slot_addr 6 bit, reg_addr 5 bit
   assign slot_addr = wb.ADDR[10:`REG_ADDR_WIDTH];
   assign reg_addr = wb.ADDR[`REG_ADDR_WIDTH-1:0];

   // address decoding
   always_comb
     begin
        // initializes CYC_array, STB_array to 0. Assign to slot_addr only
        CYC_array = 0;
        STB_array = 0;

        if (wb.CYC)
          CYC_array[slot_addr] = 1;

        if (wb.STB)
          STB_array[slot_addr] = 1;
     end

   // broadcast to all slots
   generate
      genvar i;
      for (i = 0; i < `NUM_SLOTS; i = i + 1)
        begin: slot_signal_gen
           // broadcast other bus signals
           assign WE_array[i] = wb.WE;
           assign ADDR_array[i] = reg_addr;
           assign DAT_I_array[i] = wb.DAT_I;
        end
      endgenerate

   // mux for read, ack data
   assign wb.DAT_O = DAT_O_array[slot_addr];
   assign wb.ACK = ACK_array[slot_addr];

endmodule: mmio_controller

`end_keywords
