/**
 * @file main.cpp
 * @brief main program entry
 */

//#define	_DEBUG

#include "Init.hpp"
#include "GpoCore.hpp"
#include "Ft600Core.hpp"

/////////////////////////////////////////////////////////////////////////////

extern const uint16_t gSinTableStep;
extern const uint16_t gSinTable[];

enum {
	LED_POWER = 0,
	LED_STARTED = 1,
	LED_TX = 2,
	LED_LINEAR = 3,
	NUM_OF_BURST_INSERT = 4
};

static void ftService(Ft600Core *ft, GpoCore *led)
{
	static int isStarted = 0;
	static int isLinear = 0;
	static uint16_t linearCount = 0;
	static uint16_t sineCount = 0;

	const uint32_t stat = ft->readStatReg();
	const int valid = static_cast<int>((stat >> 16) & 0x1);
	const int full = static_cast<int>((stat >> 17) & 0x1);

	if (valid) {

#ifdef	_DEBUG
		static int readCount = 0;

		gUart.disp(readCount);
		++readCount;

		gUart.disp(" FT stat: ");
		gUart.disp(static_cast<int>(stat), 16);
		gUart.disp("\n\r");
#endif	// _DEBUG

		const int32_t rxData = stat & 0xFFFF;

		ft->popRxData();

		// beaware byte order
		isStarted = (rxData & 0xff) != 0;
		isLinear = ((rxData >> 8) & 0xff) == 0;

#ifdef	_DEBUG
		gUart.disp("FT rx: ");
		gUart.disp(static_cast<int>(rxData), 16);
		gUart.disp("\n\r");
#endif	// _DEBUG
	}

	if (isStarted) {

		if (!full) {

			// just burst insert
			if (isLinear) {

				for (int i = 0; i < NUM_OF_BURST_INSERT; ++i) {

					ft->forceTxData(linearCount);
					++linearCount;

					ft->forceTxData(linearCount);
					++linearCount;

					ft->forceTxData(linearCount);
					++linearCount;

					ft->forceTxData(linearCount);
					++linearCount;
				}

				led->write(1, LED_LINEAR);

			} else {

				for (int i = 0; i < NUM_OF_BURST_INSERT; ++i) {

					ft->forceTxData(gSinTable[sineCount]);

					++sineCount;

					if (sineCount >= gSinTableStep) {

						sineCount = 0;
					}
				}

				led->write(0, LED_LINEAR);
			}

			led->write(1, LED_TX);

		} else {

			led->write(0, LED_TX);
		}

		led->write(1, LED_STARTED);

	} else {

		led->write(0, LED_TX);
		led->write(0, LED_STARTED);
	}
}

// switch, led
static GpoCore led(GET_SLOT_ADDR(BRIDGE_BASE, S2_LED));
static Ft600Core ft(GET_SLOT_ADDR(BRIDGE_BASE, S3_FT));

/////////////////////////////////////////////////////////////////////////////

int main()
{

	led.write(1, LED_POWER);

	while (1) {

		ftService(&ft, &led);
	}
}
