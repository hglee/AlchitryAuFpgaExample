#ifndef	GUARD_INIT_HPP
#define	GUARD_INIT_HPP

/**
 * @file Init.hpp
 * @brief Common definition header
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

// library
#include "IoRw.hpp"
#include "IoMap.hpp"
#include "TimerCore.hpp"
#include "UartCore.hpp"

#ifdef	__cplusplus
extern "C" {
#endif

// make uart visible by other code        
extern UartCore gUart;

// define timer and uart slots
#define	TIMER_SLOT	S0_SYS_TIMER // slot 0
#define	UART_SLOT	S1_UART1 // slot 1

// timing functions        
unsigned long nowUs();
unsigned long nowMs();
void sleepUs(unsigned long int t);
void sleepMs(unsigned long int t);

// define debug function
void debugOff();
void debugOn(const char *err, int n1, int n2);

#ifndef	_DEBUG
#define	debug(str, n1, n2) debugOff()
#endif

#ifdef	_DEBUG
#define	debug(str, n1, n2) debugOn((str), (n1), (n2))
#endif

// low level bit manipulation macros
#define	BIT_SET(xData, xN)	((xData) |= (1UL << (xN)))
#define	BIT_CLEAR(xData, xN)	((xData) &= ~(1UL << (xN)))
#define	BIT_TOGGLE(xData, xN)	((xData) ^= (1UL << (xN)))
#define	BIT_READ(xData, xN)	(((xData) >> (xN)) & 0x01)
#define	BIT_WRITE(xData, xN, xBitValue)                         \
        (xBitValue ? BIT_SET(xData, xN) : BIT_CLEAR(xData, xN))
#define	BIT(xN) (1UL << (xN))

#ifdef	__cplusplus
}
#endif
        
#endif	/* !GUARD_INIT_HPP */
