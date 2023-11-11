#ifndef	GUARD_FTD3XX_EXCEPTION_HPP
#define	GUARD_FTD3XX_EXCEPTION_HPP

/**
 * @file Ftd3xxException.hpp
 * @brief FTD3xx exception header
 */

#include <stdexcept>
#include <ftd3xx.h>
#include "Common.hpp"

BEGIN_NAMESPACE;

/**
 * @brief Exception class for FTD3xx
 */
class Ftd3xxException final : public std::runtime_error
{
public:
	/**
	 * @brief Constructor
	 */
	explicit Ftd3xxException(const char *what)
		: std::runtime_error(what), status_(FT_OTHER_ERROR)
	{

	}

	/**
	 * @brief Constructor
	 */
	Ftd3xxException(const char *what, FT_STATUS status)
		: std::runtime_error(what), status_(status)
	{

	}

	/**
	 * @brief Gets status value
	 */
	FT_STATUS status() const {

		return (this->status_);
	}

private:
	FT_STATUS status_;
};

END_NAMESPACE;

#endif	// !GUARD_FTD3XX_EXCEPTION_HPP
