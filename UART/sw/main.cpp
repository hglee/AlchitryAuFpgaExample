/**
 * @file main.cpp
 * @brief main program entry
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

//#define	_DEBUG

#include "Init.hpp"
#include "GpoCore.hpp"

/////////////////////////////////////////////////////////////////////////////

static void timerCheck(GpoCore *led)
{

	for (int i = 0; i < 5; ++i) {

		led->write(0xffff);
		sleepMs(500);
		led->write(0x0000);
		sleepMs(500);
		debug("timer check - (loop #)/now :", i, now_ms());
	}
}

static void ledCheck(GpoCore *led, int n)
{

	for (int i = 0; i < n; ++i) {

		led->write(1, i);
		sleepMs(200);
		led->write(0, i);
		sleepMs(200);
	}
}

static void uartCheck()
{
	static int loop = 0;

	gUart.disp("uart test #");
	gUart.disp(loop);
	gUart.disp("\n\r");
	++loop;
}

// switch, led
static GpoCore led(GET_SLOT_ADDR(BRIDGE_BASE, S2_LED));

/////////////////////////////////////////////////////////////////////////////

int main()
{

	while (1) {

		timerCheck(&led);
		ledCheck(&led, 8);
		uartCheck();
	}
}
