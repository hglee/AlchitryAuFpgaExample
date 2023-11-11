/**
 * @file mcs_bridge.sv
 * @brief Microblaze MCS to WISHBONE bridge
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * MCS의 기준으로 FPro는 0xc0000000 에서 시작하는 24 byte 주소 영역의 단일 I/O 모듈이 됨
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

`include "io_map.svh"

module mcs_bridge
  import vanilla_pkg::*;
  #(parameter BRG_BASE=32'hc000_0000)
   (
    // Microblaze MCS I/O bus
    input logic                         io_addr_strobe,
    input logic                         io_read_strobe,
    input logic                         io_write_strobe,
    input logic [3:0]                   io_byte_enable,
    input logic [`CPU_ADDR_WIDTH-1:0]   io_address,
    input logic [`DATA_WIDTH-1:0]       io_write_data,
    output logic [`DATA_WIDTH-1:0]      io_read_data,
    output logic                        io_ready,

    // WISHBONE interface
    output logic                        CYC_O,
    output logic                        STB_O,
    output logic                        WE_O,
    output logic [`MMIO_ADDR_WIDTH-1:0] ADDR_O,
    output logic [`DATA_WIDTH-1:0]      DAT_O,
    input logic [`DATA_WIDTH-1:0]       DAT_I,
    input logic                         ACK_I
    );

   // signals
   logic                                mcs_bridge_en;
   logic [`CPU_ADDR_WIDTH-3:0]          word_addr;

   // body
   // address translation and decoding
   //  2 LBSs are "00" due to word alignment
   assign word_addr = io_address[`CPU_ADDR_WIDTH-1:2];
   assign mcs_bridge_en = (io_address[`CPU_ADDR_WIDTH-1:`CPU_ADDR_WIDTH-8] ==
                           BRG_BASE[`CPU_ADDR_WIDTH-1:`CPU_ADDR_WIDTH-8]);
   assign CYC_O = mcs_bridge_en;
   assign STB_O = (mcs_bridge_en && io_address[`CPU_ADDR_WIDTH-9] == 0);
   assign WE_O = io_write_strobe && !io_read_strobe;
   assign ADDR_O = word_addr[`MMIO_ADDR_WIDTH-1:0];
   assign DAT_O = io_write_data;
   assign io_read_data = DAT_I;
   assign io_ready = ACK_I;

endmodule: mcs_bridge

`end_keywords
