/**
 * @file Ftd3xxWrapper.hpp
 * @brief FTD3xx wrapper implementation
 */

#include <iostream>
#include <chrono>
#include <thread>
#include <vector>
#include <cstring>
#include "Ftd3xxException.hpp"
#include "Ftd3xxWrapper.hpp"

using namespace std;

/////////////////////////////////////////////////////////////////////////////

BEGIN_NAMESPACE;

Ftd3xxWrapper::Ftd3xxWrapper(ULONG index, UCHAR pipeId)
	: handle_(nullptr), pipeId_(pipeId), timeoutMs_(1000)
{

	if (!this->validPipeId()) {

		throw Ftd3xxException("Invalid pipeId");
	}

	const auto status = FT_Create(reinterpret_cast<PVOID>(index),
	    FT_OPEN_BY_INDEX, &this->handle_);

	if (status != FT_OK) {

		throw Ftd3xxException("Cannot create handle", status);
	}

	if (!this->handle_) {

		throw runtime_error("Handle did not opened");
	}
}

Ftd3xxWrapper::~Ftd3xxWrapper()
{

	if (this->handle_) {

		(void)FT_AbortPipe(this->handle_, this->pipeId_);
		(void)FT_FlushPipe(this->handle_, this->pipeId_);
		(void)FT_ClearStreamPipe(this->handle_, 0, 0, this->pipeId_);

		(void)FT_Close(this->handle_);
		this->handle_ = nullptr;
	}
}

void Ftd3xxWrapper::setStreamPipe(ULONG streamSize)
{

	const auto status = FT_SetStreamPipe(this->handle_, 0, 0,
	    this->pipeId_, streamSize);

	if (status != FT_OK) {

		throw Ftd3xxException("Error on set stream pipe", status);
	}
}

void Ftd3xxWrapper::setPipeTimeout(DWORD timeoutMs)
{

	const auto status = FT_SetPipeTimeout(this->handle_, this->pipeId_,
	    timeoutMs);

	if (status != FT_OK) {

		throw Ftd3xxException("Error on set pipe timeout", status);
	}

	this->timeoutMs_ = timeoutMs;
}

void Ftd3xxWrapper::abortPipe()
{

	const auto status = FT_AbortPipe(this->handle_, this->pipeId_);

	if (status != FT_OK) {

		throw Ftd3xxException("Error on abort pipe", status);
	}
}

void Ftd3xxWrapper::flushPipe()
{

	const auto status = FT_FlushPipe(this->handle_, this->pipeId_);

	if (status != FT_OK) {

		throw Ftd3xxException("Error on flush pipe", status);
	}
}

void Ftd3xxWrapper::clearStreamPipe()
{

	const auto status = FT_ClearStreamPipe(this->handle_, 0, 0,
	    this->pipeId_);

	if (status != FT_OK) {

		throw Ftd3xxException("Error on clear stream pipe", status);
	}
}

void Ftd3xxWrapper::preparePipe(ULONG streamSize, DWORD timeoutMs)
{

	this->setStreamPipe(streamSize);

	this->setPipeTimeout(timeoutMs);
}

void Ftd3xxWrapper::cleanPipe()
{

	// try to run all operations
	const auto abortStatus = FT_AbortPipe(this->handle_, this->pipeId_);

	const auto flushStatus = FT_FlushPipe(this->handle_, this->pipeId_);

	const auto clearStatus = FT_ClearStreamPipe(this->handle_, 0, 0,
	    this->pipeId_);

	if (abortStatus != FT_OK) {

		throw Ftd3xxException("Error on abort pipe", abortStatus);
	}

	if (flushStatus != FT_OK) {

		throw Ftd3xxException("Error on flush pipe", flushStatus);
	}

	if (clearStatus != FT_OK) {

		throw Ftd3xxException("Error on clear stream pipe",
		    clearStatus);
	}
}

ULONG Ftd3xxWrapper::readPipe(span<uint8_t> buffer)
{
	ULONG readSize = 0;

#ifdef	_WIN32

	const auto status = FT_ReadPipe(this->handle_, this->pipeId_,
	    buffer.data(), buffer.size(), &readSize, nullptr);

#else	// !_WIN32

	const auto status = FT_ReadPipe(this->handle_, this->pipeId_,
	    buffer.data(), buffer.size(), &readSize, this->timeoutMs_);

#endif	// _WIN32

	if (status != FT_OK) {

		throw Ftd3xxException("Error on read pipe", status);
	}

	return (readSize);
}

ULONG Ftd3xxWrapper::writePipe(span<const uint8_t> buffer)
{
	ULONG writeSize = 0;

#ifdef	_WIN32

	const auto status = FT_WritePipe(this->handle_, this->pipeId_,
	    const_cast<PUCHAR>(buffer.data()), buffer.size(), &writeSize,
	    nullptr);

#else	// !_WIN32

	const auto status = FT_WritePipe(this->handle_, this->pipeId_,
	    const_cast<PUCHAR>(buffer.data()), buffer.size(), &writeSize,
	    this->timeoutMs_);

#endif	// _WIN32

	if (status != FT_OK) {

		throw Ftd3xxException("Error on write pipe", status);
	}

	return (writeSize);
}

void updateDeviceList()
{
	const auto endTime =
	    chrono::steady_clock::now() +
	    chrono::milliseconds(3000);

	DWORD count = 0;

	for (;;) {

		if (FT_CreateDeviceInfoList(&count) == FT_OK) {

			break;
		}

		if (chrono::steady_clock::now() > endTime) {

			break;
		}

		this_thread::sleep_for(chrono::milliseconds(1));
	}

	cout << "Number of devices: " << count << "\n";

	if (count == 0) {

		throw runtime_error("Cannot find device");
	}

	vector<FT_DEVICE_LIST_INFO_NODE> nodes { count };

	const auto status = FT_GetDeviceInfoList(nodes.data(), &count);
	if (status != FT_OK) {

		throw Ftd3xxException("Cannot get device info list", status);
	}
}

void turnOffThreadSafe()
{
#ifndef	_WIN32
	FT_TRANSFER_CONF conf;

	memset(&conf, 0, sizeof(FT_TRANSFER_CONF));
	conf.wStructSize = sizeof(FT_TRANSFER_CONF);
	conf.pipe[FT_PIPE_DIR_IN].fNonThreadSafeTransfer = true;
	conf.pipe[FT_PIPE_DIR_OUT].fNonThreadSafeTransfer = true;

	for (DWORD i = 0; i < 4; i++) {

		FT_SetTransferParams(&conf, i);
	}
#endif	// !_WIN32
}

string statusToString(FT_STATUS status)
{

	switch (status) {
	case FT_OK:
		return { "OK" };

	case FT_INVALID_HANDLE:
		return { "Invalid handle" };

	case FT_DEVICE_NOT_FOUND:
		return { "Device not found" };

	case FT_DEVICE_NOT_OPENED:
		return { "Device not opened" };

	case FT_IO_ERROR:
		return { "IO Error" };

	case FT_INSUFFICIENT_RESOURCES:
		return { "Insufficient resources" };

	case FT_INVALID_PARAMETER:
		return { "Invalid parameter" };

	case FT_INVALID_BAUD_RATE:
		return { "Invalid baud rate" };

	case FT_DEVICE_NOT_OPENED_FOR_ERASE:
		return { "Device not opened for erase" };

	case FT_DEVICE_NOT_OPENED_FOR_WRITE:
		return { "Device not opened for write" };

	case FT_FAILED_TO_WRITE_DEVICE:
		return { "Failed to write device" };

	case FT_EEPROM_READ_FAILED:
		return { "EEPROM read failed" };

	case FT_EEPROM_WRITE_FAILED:
		return { "EEPROM write failed" };

	case FT_EEPROM_ERASE_FAILED:
		return { "EEPROM erase failed" };

	case FT_EEPROM_NOT_PRESENT:
		return { "EEPROM not present" };

	case FT_EEPROM_NOT_PROGRAMMED:
		return { "EEPROM not programmed" };

	case FT_INVALID_ARGS:
		return { "Invalid args" };

	case FT_NOT_SUPPORTED:
		return { "Not supported" };

	case FT_NO_MORE_ITEMS:
		return { "No more items" };

	case FT_TIMEOUT:
		return { "Timeout" };

	case FT_OPERATION_ABORTED:
		return { "Operation aborted" };

	case FT_RESERVED_PIPE:
		return { "Reserved pipe" };

	case FT_INVALID_CONTROL_REQUEST_DIRECTION:
		return { "Invalid control request direction" };

	case FT_INVALID_CONTROL_REQUEST_TYPE:
		return { "Invalid control request type" };

	case FT_IO_PENDING:
		return { "IO pending" };

	case FT_IO_INCOMPLETE:
		return { "IO incomplete" };

	case FT_HANDLE_EOF:
		return { "Handle EOF" };

	case FT_BUSY:
		return { "Busy" };

	case FT_NO_SYSTEM_RESOURCES:
		return { "No system resources" };

	case FT_DEVICE_LIST_NOT_READY:
		return { "Device list not ready" };

	case FT_DEVICE_NOT_CONNECTED:
		return { "Device not connected" };

	case FT_INCORRECT_DEVICE_PATH:
		return { "Incorrect device path" };

	case FT_OTHER_ERROR:
		return { "Other error" };

	default:
		return { "Unknown error" };
	}
}

END_NAMESPACE;
