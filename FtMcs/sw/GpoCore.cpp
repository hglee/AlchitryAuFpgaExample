/**
 * @file GpoCore.cpp
 * @brief GPO core implementation
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#include "Init.hpp"
#include "IoRw.hpp"
#include "GpoCore.hpp"

/////////////////////////////////////////////////////////////////////////////

GpoCore::GpoCore(uint32_t coreBaseAddr)
	: baseAddr_(coreBaseAddr),
	  wrData_(0)
{

}

GpoCore::~GpoCore()
{

}

void GpoCore::write(uint32_t data)
{

	this->wrData_ = data;

	IO_WRITE(this->baseAddr_, DATA_REG, this->wrData_);
}

void GpoCore::write(int bitValue, int bitPos)
{

	BIT_WRITE(this->wrData_, bitPos, bitValue);

	IO_WRITE(this->baseAddr_, DATA_REG, this->wrData_);
}
