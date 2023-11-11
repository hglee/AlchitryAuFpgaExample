/**
 * @file StatisticsReport.hpp
 * @brief Statistics report implementation
 */

#include <chrono>
#include <iostream>
#include <iomanip>
#include "StatisticsReport.hpp"

using namespace std;

/////////////////////////////////////////////////////////////////////////////

BEGIN_NAMESPACE;

static constexpr int64_t oneSecondInUs = 1000 * 1000;

StatisticsReport::StatisticsReport()
	: lastReportTime_(chrono::high_resolution_clock::now()),
	  totalSize_(0)
{

}

void StatisticsReport::reset()
{

	this->lastReportTime_ = chrono::high_resolution_clock::now();
	this->totalSize_ = 0;
}

void StatisticsReport::addSize(uint64_t size)
{

	this->totalSize_ += size;

	const auto now = chrono::high_resolution_clock::now();
	const auto diffTime = now - this->lastReportTime_;
	const auto diffTimeUs =
	    chrono::duration_cast<chrono::microseconds>(diffTime).count();

	if (diffTimeUs > oneSecondInUs) {

		const auto megaBytesPerSecond =
		    static_cast<double>(this->totalSize_) / diffTimeUs;

		cout << fixed << setprecision(2) << megaBytesPerSecond
		     << " (MB/s) - "
		     << this->totalSize_ << " bytes in "
		     << diffTimeUs << " (us)\n";

		this->reset();
	}
}

END_NAMESPACE;
