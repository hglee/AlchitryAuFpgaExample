/**
 * @file io_map.svh
 * @brief IO MAP header
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */
`ifndef	_IO_MAP_INCLUDED
 `define	_IO_MAP_INCLUDED

 // system clock rate in MHZ; used for timer, uart, ddfs etc
 `define	SYS_CLK_FREQ	100

 // io base address for microBlaze MCS
 `define	BRIDGE_BASE	0xc0000000

 // slot moudle definition
 // format: SLOT`_ModuleType_Name
 `define	S0_SYS_TIMER	0
 `define	S1_UART1	1
 `define	S2_LED	2
 `define	S3_SW	3

`endif	// _IO_MAP
