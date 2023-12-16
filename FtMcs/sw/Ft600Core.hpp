#ifndef	GUARD_FT600_CORE_HPP
#define	GUARD_FT600_CORE_HPP

/**
 * @file Ft600Core.hpp
 * @brief FT600 core header
 */

#include <inttypes.h>

/////////////////////////////////////////////////////////////////////////////

class Ft600Core
{
	// register map
	enum {
		TX_DATA_REG = 1,
		RX_DATA_REG = 2,
		RX_STAT_REG = 3,
	};
public:
	Ft600Core(uint32_t coreBaseAddr);

	~Ft600Core();

	/**
	 * @brief Read statux register
	 *
	 * TxFull(1 bit) | RxValid(1 bit) | RxData(16bit)
	 */
	uint32_t readStatReg();

	/**
	 * @brief Read status.
	 *
	 * TxFull(1 bit) | RxValid(1 bit)
	 */
	uint32_t readStat();

	/**
	 * @brief Read RxValid bit
	 */
	int rxValid();

	/**
	 * @brief Read TxFull bit
	 */
	int txFull();

	/**
	 * @brief pop current RxData
	 */
	void popRxData();

	/**
	 * @brief Checks RxValid and returns RxData
	 *
	 * It will pop current RxData
	 *
	 * @return Returns RxData if RxValid. Returns -1 for invalid data.
	 */
	int32_t rxData();

	/**
	 * @brief Checks TxFull and push data
	 */
	void txData(uint16_t data);

	/**
	 * @brief Push data without check TxFull
	 */
	void forceTxData(uint16_t data);

private:
	uint32_t baseAddr_;
};

#endif	// !GUARD_FT600_CORE_HPP
