#ifndef	GUARD_UART_CORE_HPP
#define	GUARD_UART_CORE_HPP

/**
 * @file UartCore.hpp
 * @brief UART core header
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#include "IoRw.hpp"
#include "IoMap.hpp"

class UartCore
{
	/* register map */
	enum {
		RD_DATA_REG = 0,
		DVSR_REG = 1,
		WR_DATA_REG = 2,
		RM_RD_DATA_REG = 3
	};

	/* masks */
	enum {
		TX_FULL_FIELD = 0x00000200,
		RX_EMPT_FIELD = 0x00000100,
		RX_DATA_FIELD = 0x000000ff,
	};
public:
	/* methods */
	UartCore(uint32_t coreBaseAddr);

	~UartCore();

	// basic I/O access
	void setBaudRate(int baud);

	int rxFifoEmpty();

	int txFifoFull();

	void txByte(uint8_t byte);

	int rxByte();

	// display methods
	void disp(char ch) {

		this->txByte(ch);
	}

	void disp(const char *str) {

		this->dispStr(str);
	}

	void disp(int n, int base, int len);

	void disp(int n, int base) {

		this->disp(n, base, 0);
	}

	void disp(int n) {

		this->disp(n, 10, 0);
	}

	void disp(double f, int digit);

	void disp(double f) {

		this->disp(f, 3);
	}

private:
	uint32_t baseAddr_;

	int baudRate_;

	void dispStr(const char *str);
};

#endif	// !GUARD_UART_CORE_HPP
