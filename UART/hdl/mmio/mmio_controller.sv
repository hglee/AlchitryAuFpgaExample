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
  import vanilla_pkg::*;
  (
   // WISHBONE interface
   input logic                        CLK_I,
   input logic                        RST_I,
   input logic [`MMIO_ADDR_WIDTH-1:0] ADDR_I, // total 11 bits used. slot_addr 6 bit, reg_addr 5 bit
   input logic [`DATA_WIDTH-1:0]      DAT_I,
   output logic [`DATA_WIDTH-1:0]     DAT_O,
   input logic                        CYC_I,
   input logic                        STB_I,
   input logic                        WE_I,
   output logic                       ACK_O,

   // WISHBONE interface for slot
   output logic [`NUM_SLOTS-1:0]      CYC_O_array,
   output logic [`NUM_SLOTS-1:0]      STB_O_array,
   output logic [`NUM_SLOTS-1:0]      WE_O_array,
   output logic [`REG_ADDR_WIDTH-1:0] ADDR_O_array [`NUM_SLOTS-1:0],
   input logic [`DATA_WIDTH-1:0]      DAT_I_array [`NUM_SLOTS-1:0],
   output logic [`DATA_WIDTH-1:0]     DAT_O_array [`NUM_SLOTS-1:0],
   input logic [`NUM_SLOTS-1:0]       ACK_I_array
   );

   // declaration
   logic [`SLOT_ADDR_WIDTH-1:0]       slot_addr;
   logic [`REG_ADDR_WIDTH:0]          reg_addr;

   // body
   assign slot_addr = ADDR_I[10:`REG_ADDR_WIDTH];
   assign reg_addr = ADDR_I[`REG_ADDR_WIDTH-1:0];

   // address decoding
   always_comb
     begin
        // initializes CYC_O_array, STB_O_array to 0. Assign to slot_addr only
        CYC_O_array = 0;
        STB_O_array = 0;

        if (CYC_I)
          CYC_O_array[slot_addr] = 1;

        if (STB_I)
          STB_O_array[slot_addr] = 1;
     end

   // broadcast to all slots
   generate
      genvar i;
      for (i = 0; i < `NUM_SLOTS; i = i + 1)
        begin: slot_signal_gen
           // broadcast other bus signals
           assign WE_O_array[i] = WE_I;
           assign ADDR_O_array[i] = reg_addr;
           assign DAT_O_array[i] = DAT_I;
        end
      endgenerate

   // mux for read, ack data
   assign DAT_O = DAT_I_array[slot_addr];
   assign ACK_O = ACK_I_array[slot_addr];

endmodule: mmio_controller

`end_keywords
