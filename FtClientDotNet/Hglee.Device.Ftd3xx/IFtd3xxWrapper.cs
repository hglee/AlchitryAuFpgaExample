namespace Hglee.Device.Ftd3xx;

/// <summary>
/// <see cref="IFtd3xxWrapper"/> interface defines functionality for FTD3xx device.
/// </summary>
public interface IFtd3xxWrapper : IDisposable
{
    /// <summary>
    /// Gets opened flag.
    /// </summary>
    bool IsOpened { get; }

    /// <summary>
    /// Gets device list info node.
    /// </summary>
    /// <param name="timeout">Timeout on check.</param>
    /// <returns>Device list info node.</returns>
    IReadOnlyList<FT_DEVICE_LIST_INFO_NODE> GetDeviceInfoList(TimeSpan timeout);

    /// <summary>
    /// Prepare platform specific procedures.
    /// </summary>
    void Prepare();

    /// <summary>
    /// Initializes device for read.
    /// </summary>
    /// <param name="deviceIndex">Target device index.</param>
    void Open(uint deviceIndex);

    /// <summary>
    /// Makes IN pipe (read).
    /// </summary>
    /// <param name="pipeId">Target pipe ID. 0x82 ~ 0x85 for IN (read).</param>
    /// <returns>Returns pipe object.</returns>
    IFtd3xxPipe MakeInPipe(byte pipeId);

    /// <summary>
    /// Makes OUT pipe (write).
    /// </summary>
    /// <param name="pipeId">Target pipe ID. 0x02 ~ 0x05 for OUT (write).</param>
    /// <returns>Returns pipe object.</returns>
    IFtd3xxPipe MakeOutPipe(byte pipeId);

    /// <summary>
    /// Close device.
    /// </summary>
    void Close();
}