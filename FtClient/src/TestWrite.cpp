/**
 * @file TestWrite.cpp
 * @brief FTD3xx write test program.
 */

#include <iostream>
#include <csignal>
#include <atomic>
#include <vector>
#include <ftd3xx.h>
#include "Ftd3xxException.hpp"
#include "Ftd3xxWrapper.hpp"
#include "StatisticsReport.hpp"

using namespace std;
using namespace hglee::ftdi;

/////////////////////////////////////////////////////////////////////////////

static constexpr ULONG deviceIndex = 0;
static constexpr UCHAR pipeId = 0x02;
static constexpr ULONG streamSize = 32 * 1024;
static constexpr DWORD timeoutMs = 500;

static atomic<bool> breakRun;

static void signalHandler(int signum)
{

	if (signum == SIGINT) {

		breakRun.store(true);
	}
}

static void registerSignalHandler()
{

	breakRun.store(false);

	signal(SIGINT, signalHandler);
}

static void run()
{
	updateDeviceList();

	turnOffThreadSafe();

	Ftd3xxWrapper device { deviceIndex, pipeId };

	device.preparePipe(streamSize, timeoutMs);

	vector<uint8_t> buffer(streamSize);

	// fill initial data
	for (ULONG i = 0; i < streamSize / 2; ++i) {

		buffer[2 * i] = static_cast<uint8_t>(i & 0xff);
		buffer[2 * i + 1] = static_cast<uint8_t>((i >> 8) & 0xff);
	}

	StatisticsReport report;

	while (!breakRun.load()) {

		const auto writeSize = device.writePipe({ buffer.data(),
			    buffer.size() });

		report.addSize(writeSize);
	}

	cout << "End" << endl;
}

/////////////////////////////////////////////////////////////////////////////

int
main(void)
{

	registerSignalHandler();

	try {

		run();

	} catch (Ftd3xxException &ex) {

		cerr << "Error on running: "
		     << ex.what()
		     << ", status: " << ex.status()
		     << ", " << statusToString(ex.status())
		     << endl;

	} catch (exception &ex) {

		cerr << "Error on running: " << ex.what() << endl;
	}

	return (0);
}
