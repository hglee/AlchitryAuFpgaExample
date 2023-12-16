/**
 * @file UartCore.cpp
 * @brief UART core implementation
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#include "UartCore.hpp"

/////////////////////////////////////////////////////////////////////////////

UartCore::UartCore(uint32_t coreBaseAddr)
	: baseAddr_(coreBaseAddr)
{

	this->setBaudRate(9600);
}

UartCore::~UartCore()
{

}

void UartCore::setBaudRate(int baud)
{
	const uint32_t dvsr = (SYS_CLK_FREQ * 1000000 / 16 / baud) - 1;

	IO_WRITE(this->baseAddr_, DVSR_REG, dvsr);

	this->baudRate_ = baud;
}

int UartCore::rxFifoEmpty()
{
	const uint32_t rdWord = IO_READ(this->baseAddr_, RD_DATA_REG);
	const int empty = static_cast<int>(rdWord & RX_EMPT_FIELD) >> 8;

	return (empty);
}

int UartCore::txFifoFull()
{
	const uint32_t rdWord = IO_READ(this->baseAddr_, RD_DATA_REG);
	const int full = static_cast<int>(rdWord & TX_FULL_FIELD) >> 9;

	return (full);
}

void UartCore::txByte(uint8_t byte)
{
	while (this->txFifoFull()) {

		// busy waiting
	}

	IO_WRITE(this->baseAddr_, WR_DATA_REG, static_cast<uint32_t>(byte));
}

int UartCore::rxByte()
{

	if (this->rxFifoEmpty()) {

		return (-1);

	} else {

		const uint32_t data =
                    IO_READ(this->baseAddr_, RD_DATA_REG) & RX_DATA_FIELD;

		IO_WRITE(this->baseAddr_, RM_RD_DATA_REG, 0);

		return (static_cast<int>(data));
	}
}

void UartCore::dispStr(const char *str)
{

	while (static_cast<uint8_t>(*str)) {
		this->txByte(*str);
		++str;
	}
}

void UartCore::disp(int n, int base, int len)
{
	char buf[33]; // 32 bit #
	char *str, ch, sign;
	int rem, i;
	unsigned int un;

	/* error check */
	if (base != 2 && base != 8 && base != 16) {

		base = 10;
	}

	if (len > 32) { // error check

		len = 32;
	}

	/* handle neg decimal # */
	if (base == 10 && n < 0) {

		un = (unsigned)-n;
		sign = '-';

	} else {

		un = (unsigned)n; // interpreted as unsigned for hex/bin conversion
		sign = ' ';
	}

	/* convert # to string */
	str = &buf[33];
	*str = '\0';
	i = 0;
	do {
		--str;
		rem = un % base;
		un = un / base;
		if (rem < 10) {

			ch = (char) rem + '0';

		} else {

			ch = (char) rem - 10 + 'a';
		}
		*str = ch;
		++i;
	} while (un);

	/* attach - sign for neg decimal # */
	if (sign == '-') {

		--str;
		*str = sign;
		i++;
	}

	/* pad with blank */
	while (i < len) {
		--str;
		*str = ' ';
		++i;
	}

	dispStr(str);
}

void UartCore::disp(double f, int digit)
{
	double fa, frac;
	int n, i, i_part;

	// obtain absolute value of f
	fa = f;
	if (f < 0.0) {
		fa = -f;
		dispStr("-");
	}

	// dispaly integer portion
	i_part = (int)fa;
	disp(i_part);
	dispStr(".");

	// dispaly fraction part
	frac = fa - (double) i_part;
	for (n = 0; n < digit; ++n) {
		frac = frac * 10.0;
		i = (int)frac;
		disp(i);
		frac = frac - i;
	}
}
