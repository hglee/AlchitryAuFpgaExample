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
  import ft_mcs_pkg::*;
  #(parameter BRG_BASE = 32'hc000_0000)
   (
    input logic        clk,
    input logic        reset_n,
    // LED
    output logic [7:0] led,
    // uart
    input logic        rx,
    output logic       tx,
    // FT
    input logic        ft_clk,
    input logic        ft_rxf_n, // rx full
    input logic        ft_txe_n, // tx empty
    inout logic [15:0] ft_data, // data
    inout logic [1:0]  ft_be, // byte enable
    output logic       ft_rd_n, // read enable
    output logic       ft_wr_n, // write enable
    output logic       ft_oe_n // output enable
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
   wishbone_if #(.ADDR_WIDTH(`MMIO_ADDR_WIDTH), .DATA_WIDTH(`DATA_WIDTH)) wb (.CLK(clk), .RST(reset_sys));

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

   // FT600 interface
   ft600_if ft (
                .clk(ft_clk),
                .rxf_n(ft_rxf_n),
                .txe_n(ft_txe_n),
                .data(ft_data),
                .be(ft_be),
                .rd_n(ft_rd_n),
                .wr_n(ft_wr_n),
                .oe_n(ft_oe_n)
                );

   // instantiate I/O subsystem
   mmio_sys #(.N_LED(8)) mmio_unit (
                                    .wb(wb),
                                    .led(led),
                                    .rx(rx),
                                    .tx(tx),
                                    .ft(ft)
                                    );

endmodule: mcs_top

`end_keywords
