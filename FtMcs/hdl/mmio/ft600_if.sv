/**
 * @file ft600_if.sv
 * @brief FT600 interface definition
 */
`begin_keywords "1800-2017"

interface ft600_if #(parameter DATA_WIDTH=16, parameter BE_WIDTH=2)
  (
   input                  clk,
   input                  rxf_n, // rx full
   input                  txe_n, // tx empty
   inout [DATA_WIDTH-1:0] data, // data
   inout [BE_WIDTH-1:0]   be, // byte enable
   output                 rd_n, // read enable
   output                 wr_n, // write enable
   output                 oe_n // output enable
   );

   modport master (input clk, rxf_n, txe_n, inout data, be, output rd_n, wr_n, oe_n);

endinterface: ft600_if

`end_keywords
