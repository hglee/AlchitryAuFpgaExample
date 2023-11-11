/**
 * @file mcs_top.sv
 * @brief Microblaze MCS top level
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * video 제외 기본 4개의 I/O core로 구성된 MMIO
 *
 * 1. IP catalog에서 MicroBlaze MCS
 *  - name cpu
 *  - Memory 128KB
 *  - Input clock frequency 100 Mhz
 *  - Enable I/O ports
 *  - Deselect all other I/O peripherals
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

`include "io_map.svh"

module mcs_top
  import vanilla_pkg::*;
  #(parameter BRG_BASE = 32'hc000_0000)
   (
    input logic        clk,
    input logic        reset_n,
    // LED
    output logic [7:0] led,
    // uart
    input logic        rx,
    output logic       tx
    );

   // declaration
   logic                reset_sys;
   // MCS IO bus
   logic                io_addr_strobe;
   logic                io_read_strobe;
   logic                io_write_strobe;
   logic [3:0]          io_byte_enable;
   logic [`CPU_ADDR_WIDTH-1:0] io_address;
   logic [`DATA_WIDTH-1:0]     io_write_data;
   logic [`DATA_WIDTH-1:0]     io_read_data;
   logic                       io_ready;

   // WISHBONE interface
   logic                        CYC_O;
   logic                        STB_O;
   logic                        WE_O;
   logic [`MMIO_ADDR_WIDTH-1:0] ADDR_O;
   logic [`DATA_WIDTH-1:0]      DAT_O;
   logic [`DATA_WIDTH-1:0]      DAT_I;
   logic                        ACK_I;

   // body
   assign reset_sys = !reset_n;

   // instantiate Microblaze MCS
   cpu cpu_unit (
                 .Clk(clk),
                 .Reset(reset_sys),
                 .IO_addr_strobe(io_addr_strobe),
                 .IO_address(io_address),
                 .IO_byte_enable(io_byte_enable),
                 .IO_read_data(io_read_data),
                 .IO_read_strobe(io_read_strobe),
                 .IO_ready(io_ready),
                 .IO_write_data(io_write_data),
                 .IO_write_strobe(io_write_strobe)
                 );

   // instantiate bridge
   mcs_bridge #(.BRG_BASE(BRG_BASE)) bridge_unit (.*);

   // instantiate I/O subsystem
   mmio_sys #(.N_LED(8)) mmio_unit (
                                    .CLK_I(clk),
                                    .RST_I(reset_sys),
                                    .ADDR_I(ADDR_O),
                                    .DAT_I(DAT_O),
                                    .DAT_O(DAT_I),
                                    .CYC_I(CYC_O),
                                    .STB_I(STB_O),
                                    .WE_I(WE_O),
                                    .ACK_O(ACK_I),
                                    .led(led),
                                    .rx(rx),
                                    .tx(tx)
                                    );

endmodule: mcs_top

`end_keywords
