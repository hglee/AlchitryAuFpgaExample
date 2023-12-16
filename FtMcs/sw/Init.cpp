/**
 * @file Init.cpp
 * @brief Common definition implementation
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#include "Init.hpp"

/////////////////////////////////////////////////////////////////////////////

static TimerCore mySysTimer(GET_SLOT_ADDR(BRIDGE_BASE, TIMER_SLOT));

UartCore gUart(GET_SLOT_ADDR(BRIDGE_BASE, UART_SLOT));

unsigned long nowUs()
{

	return (static_cast<unsigned long>(mySysTimer.readTime()));
}

unsigned long nowMs()
{

	return (static_cast<unsigned long>(mySysTimer.readTime() / 1000));
}

void sleepUs(unsigned long int t)
{

	mySysTimer.sleepUs(static_cast<uint64_t>(t));
}

void sleepMs(unsigned long int t)
{

	mySysTimer.sleepUs(static_cast<uint64_t>(1000 * t));
}

void debugOn(const char *str, int n1, int n2)
{

	gUart.disp("debug: ");
	gUart.disp(str);
	gUart.disp(n1);
	gUart.disp("(0x");
	gUart.disp(n1, 16);
	gUart.disp(") / ");
	gUart.disp(n2);
	gUart.disp("(0x");
	gUart.disp(n2, 16);
	gUart.disp(") \n\r");
}

void debugOff()
{

}
