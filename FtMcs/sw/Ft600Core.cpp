/**
 * @file Ft600Core.cpp
 * @brief FT600 core implementation
 */

#include "IoRw.hpp"
#include "IoMap.hpp"
#include "Ft600Core.hpp"

/////////////////////////////////////////////////////////////////////////////

Ft600Core::Ft600Core(uint32_t coreBaseAddr)
	: baseAddr_(coreBaseAddr)
{

}

Ft600Core::~Ft600Core()
{

}

uint32_t Ft600Core::readStatReg()
{
	const uint32_t rdWord = IO_READ(this->baseAddr_, RX_STAT_REG);

	return (rdWord);
}

uint32_t Ft600Core::readStat()
{
	const uint32_t rdWord = IO_READ(this->baseAddr_, RX_STAT_REG);

	return (this->readStatReg() >> 16);
}

int Ft600Core::rxValid()
{
	const uint32_t stat = this->readStat();
	const int valid = static_cast<int>(stat & 0x1);

	return (valid);
}

int Ft600Core::txFull()
{
	const uint32_t stat = this->readStat();
	const int full = static_cast<int>((stat >> 1) & 0x1);

	return (full);
}

void Ft600Core::popRxData()
{

	IO_WRITE(this->baseAddr_, RX_DATA_REG, static_cast<uint32_t>(0));
}

int32_t Ft600Core::rxData()
{
	const uint32_t rdWord = IO_READ(this->baseAddr_, RX_STAT_REG);
	const int valid = static_cast<int>((rdWord >> 16) & 0x1);

	if (!valid) {

		return (-1);

	} else {

		const uint32_t data = rdWord & 0xFFFF;

		this->popRxData();

		return (static_cast<int32_t>(data));
	}
}

void Ft600Core::txData(uint16_t data)
{

	while (this->txFull()) {

		// busy waiting
	}

	this->forceTxData(data);
}

void Ft600Core::forceTxData(uint16_t data)
{

	IO_WRITE(this->baseAddr_, TX_DATA_REG, static_cast<uint32_t>(data));
}
