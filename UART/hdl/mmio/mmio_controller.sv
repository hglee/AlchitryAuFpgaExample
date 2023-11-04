/**
 * @file mmio_controller.sv
 * @brief MMIO contoller
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
module mmio_controller
  (
   // FPro bus
   input logic clk,
   input logic reset,
   input logic mmio_cs,
   input logic mmio_wr,
   input logic mmio_rd,
   input logic [20:0] mmio_addr, // 21 bit address 중 11 bit만 사용 slot_addr 6 bit, reg_addr 5 bit
   input logic [31:0] mmio_wr_data,
   input logic [31:0] mmio_rd_data,

   // slot interface
   output logic [63:0] slot_cs_array,
   output logic [63:0] slot_mem_rd_array,
   output logic [63:0] slot_mem_wr_array,
   output logic [4:0] slot_reg_addr_array [63:0],
   input logic [31:0] slot_rd_data_array [63:0],
   output logic [31:0] slot_wr_data_array [63:0]
   );

   // declaration
   logic [5:0]         slot_addr;
   logic [4:0]         reg_addr;

   // body
   assign slot_addr = mmio_addr[10:5];
   assign reg_addr = mmio_addr[4:0];

   // address decoding
   always_comb
     begin
        // 모든 slot_cs_array를 0으로 초기화 후, mmio 가 활성화 된 경우 지정된 slot_addr만 활성화
        slot_cs_array = 0;
        if (mmio_cs)
          slot_cs_array[slot_addr] = 1;
     end

   // broadcast to all slots
   generate
      genvar i;
      for (i = 0; i < 64; i = i + 1)
        begin: slot_signal_gen
           // 이외 모든 bus 신호는 모두에게 전달됨
           assign slot_mem_rd_array[i] = mmio_rd;
           assign slot_mem_wr_array[i] = mmio_wr;
           assign slot_wr_data_array[i] = mmio_wr_data;
           assign slot_reg_addr_array[i] = reg_addr;
        end
      endgenerate

   // mux for read data
   assign mmio_rd_data = slot_rd_data_array[slot_addr];
endmodule // mmio_controller
