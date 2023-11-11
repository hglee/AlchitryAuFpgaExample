#ifndef	GUARD_STATISTICS_REPORT_HPP
#define	GUARD_STATISTICS_REPORT_HPP

/**
 * @file StatisticsReport.hpp
 * @brief Statistics report header
 */

#include <chrono>
#include <cstdint>
#include "Common.hpp"

BEGIN_NAMESPACE;

/**
 * @brief Transfer rate statistics report
 */
class StatisticsReport final
{
public:
	/**
	 * @brief Constructor
	 */
	StatisticsReport();

	/**
	 * @brief Reset state
	 */
	void reset();

	/**
	 * @brief Add transfer size
	 */
	void addSize(uint64_t size);

private:
	/**
	 * @brief Last report time
	 */
	std::chrono::high_resolution_clock::time_point lastReportTime_;

	/**
	 * @brief Total transfer size
	 */
	uint64_t totalSize_;
};

END_NAMESPACE;

#endif	// !GUARD_STATISTICS_REPORT_HPP
