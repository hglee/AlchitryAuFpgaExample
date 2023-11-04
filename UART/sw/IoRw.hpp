#ifndef	GUARD_IO_RW_HPP
#define	GUARD_IO_RW_HPP

/**
 * @file IoRw.hpp
 * @brief Common definition for IO header.
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#include <inttypes.h>

#ifdef	__cplusplus
extern "C" {
#endif

#define	IO_READ(xBaseAddr, xOffset)                             \
        (*(volatile uint32_t *)((xBaseAddr) + 4 * (xOffset)))

#define	IO_WRITE(xBaseAddr, xOffset, xData)                             \
        (*(volatile uint32_t *)((xBaseAddr) + 4 * (xOffset)) = (xData))

#define	GET_SLOT_ADDR(xMmioBase, xSlot)                 \
        ((uint32_t)((xMmioBase) + (xSlot) * 32 * 4))

#ifdef	__cplusplus
}
#endif
        
#endif	/* !GUARD_IO_RW_HPP */
