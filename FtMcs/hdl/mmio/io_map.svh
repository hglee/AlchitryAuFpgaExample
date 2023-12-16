/**
 * @file io_map.svh
 * @brief IO MAP header
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
`begin_keywords "1800-2017"

`ifndef	_IO_MAP_INCLUDED
 `define	_IO_MAP_INCLUDED

  package ft_mcs_pkg;

   // system clock rate in MHZ; used for timer, uart
   `define	SYS_CLK_FREQ	100

   // io base address for microBlaze MCS
   `define	BRIDGE_BASE	0xc0000000

   `define	CPU_ADDR_WIDTH	32
   `define	MMIO_ADDR_WIDTH	21
   `define	DATA_WIDTH	32
   `define	REG_ADDR_WIDTH	5
   `define	SLOT_ADDR_WIDTH	6
   `define	NUM_SLOTS	64

   // slot moudle definition
   // format: SLOT`_ModuleType_Name
   `define	S0_SYS_TIMER	0
   `define	S1_UART1	1
   `define	S2_LED	2
   `define	S3_FT	3

  endpackage: ft_mcs_pkg

`endif	// _IO_MAP

`end_keywords
