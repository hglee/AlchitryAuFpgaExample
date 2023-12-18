/**
 * @file dev_ft600.sv
 * @brief FT600 HDL module
 *
 * 2-Process FSM style
 */
`begin_keywords "1800-2017"
`timescale 1ns/1ps

module dev_ft600
  (
   wishbone_if.slave wb,
   ft600_if.master ft
   );

   // signal declaration
   logic rd_en, wr_en;
   logic rx_en;
   logic [17:0] rx_data;
   logic        rx_valid;
   logic        tx_en;
   logic        tx_full;

   ft600 #(.RX_FIFO_DEPTH(64)) ft_unit (.clk(wb.CLK),
                                        .rst(wb.RST),
                                        .ft(ft),
                                        .rx_en(rx_en),
                                        .rx_data(rx_data),
                                        .rx_valid(rx_valid),
                                        .tx_en(tx_en),
                                        .tx_data(wb.DAT_I[15:0]),
                                        .tx_full(tx_full));

   assign rd_en = wb.CYC && wb.STB && !wb.WE;
   assign wr_en = wb.CYC && wb.STB && wb.WE;
   assign rx_en = (wr_en && (wb.ADDR[1:0] == 2'b10)); // register 0x02
   assign tx_en = (wr_en && (wb.ADDR[1:0] == 2'b01)); // register 0x01

   assign wb.DAT_O = {12'h0, rx_data[17:16], tx_full, rx_valid, rx_data[15:0]};
   assign wb.ACK = wb.CYC && wb.STB;

endmodule: dev_ft600

`end_keywords
