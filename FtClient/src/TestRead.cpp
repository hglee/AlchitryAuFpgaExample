/**
 * @file TestRead.cpp
 * @brief FTD3xx read test program.
 */

#include <iostream>
#include <iomanip>
#include <csignal>
#include <atomic>
#include <vector>
#include <chrono>
#include "Ftd3xxException.hpp"
#include "Ftd3xxWrapper.hpp"
#include "StatisticsReport.hpp"

using namespace std;
using namespace hglee::ftdi;

/////////////////////////////////////////////////////////////////////////////

static constexpr ULONG deviceIndex = 0;
static constexpr UCHAR pipeId = 0x82;
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

	StatisticsReport report;

	while (!breakRun.load()) {

		const auto readSize = device.readPipe({ buffer.data(),
			    buffer.size() });

		report.addSize(readSize);
	}

	cout << "End" << endl;
}

/////////////////////////////////////////////////////////////////////////////

int
main()
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
