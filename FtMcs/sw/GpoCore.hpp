#ifndef	GUARD_GPO_CORE_HPP
#define	GUARD_GPO_CORE_HPP

/**
 * @file GpoCore.hpp
 * @brief GPO core header
 *
 * Origin from FPGA Prototyping by SystemVerilog Examples - Pong P. Chu
 */

#include <inttypes.h>

/////////////////////////////////////////////////////////////////////////////

class GpoCore
{
	// register map
	enum {
		DATA_REG = 0 // data register
	};
public:
	GpoCore(uint32_t coreBaseAddr);

	~GpoCore();

	void write(uint32_t data);

	void write(int bitValue, int bitPos);

private:
	uint32_t baseAddr_;
	uint32_t wrData_;
};

#endif	/* !GUARD_GPO_CORE_HPP */
