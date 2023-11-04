/**
 * @file TimerCore.cpp
 * @brief Timer implementation
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#include "IoMap.hpp"
#include "IoRw.hpp"
#include "TimerCore.hpp"

/////////////////////////////////////////////////////////////////////////////

TimerCore::TimerCore(uint32_t coreBaseAddr)
	: baseAddr_(coreBaseAddr),
	  ctrl_(0)
{

	this->clear();

	this->ctrl_ = 0x01;

	// enable
	IO_WRITE(this->baseAddr_, CTRL_REG, this->ctrl_);
}

TimerCore::~TimerCore()
{

}

void TimerCore::pause()
{
	// reset enable bit to 0
	this->ctrl_ = this->ctrl_ & ~GO_FIELD;

	IO_WRITE(this->baseAddr_, CTRL_REG, this->ctrl_);
}

void TimerCore::go()
{
	// set enable bit to 1
	this->ctrl_ = this->ctrl_ | GO_FIELD;

	IO_WRITE(this->baseAddr_, CTRL_REG, this->ctrl_);
}

void TimerCore::clear()
{
	// write clear_bit to generate a 1-clock pulse
	// clear bit does not affect ctrl
	const uint32_t wdata = this->ctrl_ | CLR_FIELD;

	IO_WRITE(this->baseAddr_, CTRL_REG, wdata);
}

uint64_t TimerCore::readTick()
{
	const uint64_t lower =
	    static_cast<uint64_t>(IO_READ(this->baseAddr_, COUNTER_LOWER_REG));
	const uint64_t upper =
	    static_cast<uint64_t>(IO_READ(this->baseAddr_, COUNTER_UPPER_REG));

	return ((upper << 32) | lower);
}

uint64_t TimerCore::readTime()
{
	// elapsed time in microseconds (SYS_FREQ in MHz)
	return (this->readTick() / SYS_CLK_FREQ);
}

void TimerCore::sleepUs(uint64_t us)
{
	const uint64_t startTime = this->readTime();

	uint64_t now;

	// busy waiting
	do {
		now = this->readTime();
	} while ((now - startTime) < us);
}
