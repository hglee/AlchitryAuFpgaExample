/**
 * @file wishbone_if.sv
 * @brief WISHBONE interface definition
 */
`begin_keywords "1800-2017"

interface wishbone_if #(parameter ADDR_WIDTH=32, parameter DATA_WIDTH=32)
   (
    input logic CLK,
    input logic RST
    );

   logic [ADDR_WIDTH-1:0]  ADDR;
   logic [DATA_WIDTH-1:0]  DAT_I; // data input on slave (output on master)
   logic [DATA_WIDTH-1:0]  DAT_O; // data output on slave (input on master)
   logic                   CYC;
   logic                   STB;
   logic                   WE;
   logic                   ACK;

   modport master (input CLK, RST, DAT_O, ACK, output ADDR, DAT_I, CYC, STB, WE);
   modport slave (input CLK, RST, ADDR, DAT_I, CYC, STB, WE, output DAT_O, ACK);

endinterface: wishbone_if

`end_keywords
