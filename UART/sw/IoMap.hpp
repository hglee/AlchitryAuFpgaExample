#ifndef	GUARD_IO_MAP_HPP
#define	GUARD_IO_MAP_HPP

/**
 * @file IoMap.hpp
 * @brief Common definition for IO map header.
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#ifdef	__cplusplus
extern "C" {
#endif

#define	SYS_CLK_FREQ 100

// io base address for microBlaze MCS
#define	BRIDGE_BASE	0xc0000000

// slot module definition
#define	S0_SYS_TIMER	0
#define	S1_UART1	1
#define	S2_LED		2
#define	S3_SW		3

#ifdef	__cplusplus
}
#endif
        
#endif	/* !GUARD_IO_MAP_HPP */
