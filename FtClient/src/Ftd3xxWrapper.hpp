#ifndef	GUARD_FTD3XX_WRAPPER_HPP
#define	GUARD_FTD3XX_WRAPPER_HPP

/**
 * @file Ftd3xxWrapper.hpp
 * @brief FTD3xx wrapper header
 */

#include <span>
#include <cstdint>
#include <string>
#include <ftd3xx.h>
#include "Common.hpp"

BEGIN_NAMESPACE;

/**
 * @brief Wrapper class for FTD3xx
 */
class Ftd3xxWrapper final
{
public:
	/**
	 * @brief Constructor
	 *
	 * Create by device index
	 *
	 * @param index Target device index
	 * @param pipeId Target pipe ID. 0x02 ~ 0x05 for OUT, 0x82 ~ 0x85 for IN.
	 */
	Ftd3xxWrapper(ULONG index, UCHAR pipeId);

	/**
	 * @brief Destructor
	 */
	~Ftd3xxWrapper();

	Ftd3xxWrapper(const Ftd3xxWrapper&) = delete;
	Ftd3xxWrapper& operator=(const Ftd3xxWrapper&) = delete;
	Ftd3xxWrapper(Ftd3xxWrapper&&) = delete;
	Ftd3xxWrapper& operator=(Ftd3xxWrapper&&) = delete;

	/**
	 * @brief Gets pipe id validity
	 */
	bool validPipeId() const {

		return ((this->pipeId_ >= 0x02 && this->pipeId_ <= 0x05) ||
		    (this->pipeId_ >= 0x82 && this->pipeId_ <= 0x85));
	}

	/**
	 * @brief Set stream pipe
	 */
	void setStreamPipe(ULONG streamSize);

	/**
	 * @brief Set pipe timeout
	 */
	void setPipeTimeout(DWORD timeoutMs);

	/**
	 * @brief Abort target pipe
	 */
	void abortPipe();

	/**
	 * @brief Flush target pipe
	 */
	void flushPipe();

	/**
	 * @brief Clear target stream pipe
	 */
	void clearStreamPipe();

	/**
	 * @brief Prepare pipe.
	 *
	 * Calls setStreamPipe, setPipeTimeout internally.
	 */
	void preparePipe(ULONG streamSize, DWORD timeoutMs);

	/**
	 * @brief Clean pipe.
	 *
	 * Calls abortPipe, flushPipe, clearStreamPipe internally.
	 */
	void cleanPipe();

	/**
	 * @brief Read from pipe
	 * @param buffer [out] buffer
	 * @return Returns transferred bytes.
	 */
	ULONG readPipe(std::span<uint8_t> buffer);

	/**
	 * @brief Write to pipe
	 * @param buffer buffer
	 * @return Returns transferred bytes.
	 */
	ULONG writePipe(std::span<const uint8_t> buffer);

private:
	/**
	 * @brief device handle
	 */
	FT_HANDLE handle_;

	/**
	 * @brief pipe ID
	 */
	UCHAR pipeId_;

	/**
	 * @brief timeout (ms)
	 *
	 * Used in Linux
	 */
	DWORD timeoutMs_;
};

/**
 * @brief Update FT3xx device list
 */
void updateDeviceList();

/**
 * @brief Set transfer parameter to fNonThreadSafeTransfer
 */
void turnOffThreadSafe();

/**
 * @brief Converts status value to string.
 */
std::string statusToString(FT_STATUS status);

END_NAMESPACE;

#endif	// !GUARD_FTD3XX_WRAPPER_HPP
