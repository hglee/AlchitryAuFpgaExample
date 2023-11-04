#ifndef	GUARD_TIMER_CORE_HPP
#define	GUARD_TIMER_CORE_HPP

/**
 * @file TimerCore.hpp
 * @brief Timer header
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#include <inttypes.h>

/////////////////////////////////////////////////////////////////////////////

class TimerCore
{
	// register map
	enum {
		COUNTER_LOWER_REG = 0, // lower 32 bits of counter
		COUNTER_UPPER_REG = 1, // upper 16 bits of counter
		CTRL_REG = 2, // control register
	};

	// masks
	enum {
		GO_FIELD = 0x00000001, // bit 0 of ctrl_reg: enable
		CLR_FIELD = 0x00000002, // bit 1 of ctrl_reg: clear
	};
public:
	TimerCore(uint32_t coreBaseAddr);

	~TimerCore();

	void pause();

	void go();

	void clear();

	uint64_t readTick();

	uint64_t readTime();

	void sleepUs(uint64_t us);

private:
	uint32_t baseAddr_;
	uint32_t ctrl_;
};

#endif	// !GUARD_TIMER_CORE_HPP
