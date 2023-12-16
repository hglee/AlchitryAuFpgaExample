/**
 * @file fifo_if.sv
 * @brief FIFO interface definition
 */
`begin_keywords "1800-2017"

interface fifo_if
  #(parameter DATA_WIDTH=18)
   (
    input logic rd_clk,
    input logic wr_clk
    );

   logic [DATA_WIDTH-1:0] dout;
   logic                  empty;
   logic                  full;
   logic                  rd_rst_busy;
   logic                  wr_rst_busy;
   logic [DATA_WIDTH-1:0] din;
   logic                  data_valid;
   logic                  prog_full;
   logic                  rd_en;
   logic                  rst;
   logic                  wr_en;

endinterface: fifo_if

`end_keywords
