/**
 * @file reg_file.sv
 * @brief register file
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 *
 * dynamic index 사용
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

module reg_file
  #(parameter DATA_WIDTH = 8, // number of bits
    ADDR_WIDTH = 2 // number of address bits
    )
   (
    input logic                     clk,
    input logic                     wr_en,
    input logic [ADDR_WIDTH - 1:0]  w_addr, r_addr,
    input logic [DATA_WIDTH - 1:0]  w_data,
    output logic [DATA_WIDTH - 1:0] r_data
    );

   // signal
   logic [DATA_WIDTH - 1:0]         array_reg [0:2**ADDR_WIDTH-1];

   // body
   // write operation
   always_ff @(posedge clk)
     if (wr_en)
       array_reg[w_addr] <= w_data; // 합성 시 decoding, mux logic으로 합성됨

   // read operation
   assign r_data = array_reg[r_addr]; // 합성 시 decoding, mux logic으로 합성됨
   
endmodule: reg_file

`end_keywords
