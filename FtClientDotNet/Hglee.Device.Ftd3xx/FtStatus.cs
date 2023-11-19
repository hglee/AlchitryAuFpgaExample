namespace Hglee.Device.Ftd3xx;

/// <summary>
/// FT status codes
/// </summary>
public enum FtStatus
{
    Ok = 0,
    InvalidHandle = 1,
    DeviceNotFound = 2,
    DeviceNotOpened = 3,
    IoError = 4,
    InsufficientResources = 5,
    InvalidParameter = 6,
    InvalidBaudRate = 7,
    DeviceNotOpenedForErase = 8,
    DeviceNotOpenedForWrite = 9,
    FailedToWriteDevice = 10,
    EepromReadFailed = 11,
    EepromWriteFailed = 12,
    EepromEraseFailed = 13,
    EepromNotPresent = 14,
    EepromNotProgrammed = 15,
    InvalidArgs = 16,
    NotSupported = 17,
    NoMoreItems = 18,
    Timeout = 19,
    OperationAborted = 20,
    ReservedPipe = 21,
    InvalidControlRequestDirection = 22,
    InvalidControlRequestType = 23,
    IoPending = 24,
    IoIncomplete = 25,
    HandleEof = 26,
    Busy = 27,
    NoSystemResources = 28,
    DeviceListNotReady = 29,
    DeviceNotConnected = 30,
    IncorrectDevicePath = 31,
    OtherError = 32,
}
