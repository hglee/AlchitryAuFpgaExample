namespace Hglee.Device.Ftd3xx;

/// <summary>
/// <see cref="IFtd3xxWrapper"/> interface defines pipe functionality for FTD3xx device.
/// </summary>
public interface IFtd3xxPipe
{
    /// <summary>
    /// Gets pipe id.
    /// </summary>
    byte PipeId { get; }

    /// <summary>
    /// Gets or sets to ignores read or write timeout exception.
    /// <para>Sets to false to raise exception on timeout.</para>
    /// </summary>
    bool DoNotRaiseTimeoutException { get; set; }

    /// <summary>
    /// Gets disposed flag.
    /// <para>Setter only for internal use.</para>
    /// </summary>
    bool Disposed { get; set; }

    /// <summary>
    /// Sets stream pipe
    /// </summary>
    /// <param name="streamSize">Stream size in bytes.</param>
    void SetStreamPipe(uint streamSize);

    /// <summary>
    /// Sets timeout (ms)
    /// </summary>
    /// <param name="timeoutMs">Time in millisec.</param>
    void SetPipeTimeoutMs(uint timeoutMs);

    /// <summary>
    /// Aborts target pipe.
    /// </summary>
    void AbortPipe();

    /// <summary>
    /// Flushes target pipe.
    /// </summary>
    void FlushPipe();

    /// <summary>
    /// Clears target stream pipe.
    /// </summary>
    void ClearStreamPipe();

    /// <summary>
    /// Prepares target pipe.
    /// <para>Calls <see cref="SetStreamPipe"/>, <see cref="SetPipeTimeoutMs"/> internally.</para>
    /// </summary>
    /// <param name="streamSize">Stream size in bytes.</param>
    /// <param name="timeoutMs">Timeout in millisec.</param>
    void Prepare(uint streamSize, uint timeoutMs);

    /// <summary>
    /// Cleans target pipe.
    /// <para>Calls <see cref="AbortPipe"/>, <see cref="FlushPipe"/>, <see cref="ClearStreamPipe"/> internally.</para>
    /// </summary>
    void Clean();

    /// <summary>
    /// Reads from target pipe.
    /// </summary>
    /// <param name="buffer">Output buffer.</param>
    /// <returns>Returns transferred number of bytes.</returns>
    uint Read(byte[] buffer);

    /// <summary>
    /// Writes to target pipe.
    /// </summary>
    /// <param name="buffer">Input buffer.</param>
    /// <returns>Returns transferred number of bytes.</returns>
    uint Write(byte[] buffer);
}
