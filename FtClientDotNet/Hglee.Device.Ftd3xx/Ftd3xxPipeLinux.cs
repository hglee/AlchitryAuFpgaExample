namespace Hglee.Device.Ftd3xx;

using System.Runtime.InteropServices;

/// <summary>
/// FTD3xx pipe class for Linux
/// </summary>
/// <remarks>See native header for detail types (Types.h). Some examples,
/// <list type='bullet'>
/// <item>DWORD : unsigned int</item>
/// <item>ULONG : unsigned int</item>
/// <item>BOOL : unsigned int</item>
/// <item>BOOLEAN : unsigned char</item>
/// </list>
/// </remarks>
public class Ftd3xxPipeLinux : IFtd3xxPipe
{
    /// <summary>
    /// Sets streaming protocol transfer for specified pipes.
    /// <para>FT_SetStreamPipe(FT_HANDLE ftHandle, BOOL bAllWritePipes, BOOL bAllReadPipes, UCHAR ucPipeID, ULONG ulStreamSize)</para>
    /// </summary>
    /// <param name="ftHandle">Target handle</param>
    /// <param name="bAllWritePipes">Sets all write pipes.</param>
    /// <param name="bAllReadPipes">Sets all read pipes.</param>
    /// <param name="ucPipeId">Target pipe id.</param>
    /// <param name="ulStreamSize">Target stream size.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_SetStreamPipe(IntPtr ftHandle, uint bAllWritePipes, uint bAllReadPipes, byte ucPipeId, uint ulStreamSize);

    /// <summary>
    /// Configures the timeout value for a given endpoint.
    /// <para>FT_STATUS FT_SetPipeTimeout(FT_HANDLE ftHandle, UCHAR ucPipeID, DWORD dwTimeoutInMs)</para>
    /// </summary>
    /// <param name="ftHandle">Target handle.</param>
    /// <param name="ucPipeId">Target pipe id.</param>
    /// <param name="dwTimeoutInMs">Timeout in millisec.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_SetPipeTimeout(IntPtr ftHandle, byte ucPipeId, uint dwTimeoutInMs);

    /// <summary>
    /// Aborts all of the pending transfers for a pipe.
    /// <para>FT_STATUS FT_AbortPipe(FT_HANDLE ftHandle, UCHAR ucPipeID)</para>
    /// </summary>
    /// <param name="ftHandle">Target handle.</param>
    /// <param name="ucPipeId">Target pipe id.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_AbortPipe(IntPtr ftHandle, byte ucPipeId);

    /// <summary>
    /// Flushes target pipe.
    /// <para>FT_STATUS FT_FlushPipe(FT_HANDLE ftHandle, UCHAR ucPipeID)</para>
    /// </summary>
    /// <param name="ftHandle">Target handle.</param>
    /// <param name="ucPipeId">Target pipe id.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_FlushPipe(IntPtr ftHandle, byte ucPipeId);

    /// <summary>
    /// Clears streaming protocol transfer for specified pipes.
    /// <para>FT_STATUS FT_ClearStreamPipe(FT_HANDLE ftHandle, BOOL bAllWritePipes, BOOL bAllReadPipes, UCHAR ucPipeID)</para>
    /// </summary>
    /// <param name="ftHandle">Target handle.</param>
    /// <param name="bAllWritePipes">Sets all write pipes.</param>
    /// <param name="bAllReadPipes">Sets all read pipes.</param>
    /// <param name="ucPipeId">Target pipe id.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_ClearStreamPipe(IntPtr ftHandle, uint bAllWritePipes, uint bAllReadPipes, byte ucPipeId);

    /// <summary>
    /// Write data to pipe.
    /// <para>FT_STATUS FT_WritePipe(FT_HANDLE ftHandle, UCHAR ucPipeID, PUCHAR pucBuffer, ULONG ulBufferLength, PULONG pulBytesTransferred, DWORD dwTimeoutInMs)</para>
    /// </summary>
    /// <param name="ftHandle">Target handle.</param>
    /// <param name="ucPipeId">Target pipe id.</param>
    /// <param name="pucBuffer">Buffer to write.</param>
    /// <param name="ulBufferLength">Number of bytes to write.</param>
    /// <param name="pulBytesTransferred">Actual number of bytes written.</param>
    /// <param name="dwTimeoutInMs">Timeout in millisec.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_WritePipe(IntPtr ftHandle, byte ucPipeId, byte[] pucBuffer, uint ulBufferLength, out uint pulBytesTransferred, uint dwTimeoutInMs);

    /// <summary>
    /// Read data from pipe.
    /// <para>FT_STATUS FT_ReadPipe(FT_HANDLE ftHandle, UCHAR ucPipeID, PUCHAR pucBuffer, ULONG ulBufferLength, PULONG pulBytesTransferred, DWORD dwTimeoutInMs)</para>
    /// </summary>
    /// <param name="ftHandle">Target handle.</param>
    /// <param name="ucPipeId">Target pipe id.</param>
    /// <param name="pucBuffer">Buffer for read.</param>
    /// <param name="ulBufferLength">Number of bytes to read.</param>
    /// <param name="pulBytesTransferred">Actual number of bytes read.</param>
    /// <param name="dwTimeoutInMs">Timeout in millisec.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_ReadPipe(IntPtr ftHandle, byte ucPipeId, [Out] byte[] pucBuffer, uint ulBufferLength, out uint pulBytesTransferred, uint dwTimeoutInMs);

    /// <summary>
    /// Device handle
    /// </summary>
    private readonly IntPtr handle;

    /// <summary>
    /// Read pipe flag
    /// </summary>
    private readonly bool isReadPipe;

    /// <summary>
    /// Timeout (ms)
    /// </summary>
    private uint timeoutMillisec;

    /// <summary>
    /// Initializes a new instance of the <see cref="Ftd3xxPipeLinux"/> class.
    /// </summary>
    /// <param name="handle">Device handle.</param>
    /// <param name="pipeId">Target pipe id.</param>
    /// <param name="isReadPipe">Read pipe flag.</param>
    internal Ftd3xxPipeLinux(IntPtr handle, byte pipeId, bool isReadPipe)
    {
        if (handle == IntPtr.Zero)
        {
            throw new ArgumentException("Invalid device handle.", nameof(handle));
        }

        if (isReadPipe)
        {
            if (!FtWrapperUtil.IsValidReadPipeId(pipeId))
            {
                throw new ArgumentOutOfRangeException(nameof(pipeId));
            }
        }
        else
        {
            if (!FtWrapperUtil.IsValidWritePipeId(pipeId))
            {
                throw new ArgumentOutOfRangeException(nameof(pipeId));
            }
        }

        this.handle = handle;
        this.isReadPipe = isReadPipe;
        this.timeoutMillisec = 1000;

        this.PipeId = pipeId;
        this.DoNotRaiseTimeoutException = false;
    }

    /// <inheritdoc />
    public byte PipeId { get; }

    /// <inheritdoc />
    public bool DoNotRaiseTimeoutException { get; set; }

    /// <inheritdoc />
    public bool Disposed { get; set; }

    /// <inheritdoc />
    public void SetStreamPipe(uint streamSize)
    {
        if (this.Disposed)
        {
            throw new ObjectDisposedException("handle");
        }

        var status = FT_SetStreamPipe(this.handle, 0, 0, this.PipeId, streamSize).ToStatus();
        if (status != FtStatus.Ok)
        {
            throw new FtException($"Error on SetStreamPipe: {status}", status);
        }
    }

    /// <inheritdoc />
    public void SetPipeTimeoutMs(uint timeoutMs)
    {
        if (this.Disposed)
        {
            throw new ObjectDisposedException("handle");
        }

        var status = FT_SetPipeTimeout(this.handle, this.PipeId, timeoutMs).ToStatus();
        if (status != FtStatus.Ok)
        {
            throw new FtException($"Error on SetPipeTimeout: {status}", status);
        }

        this.timeoutMillisec = timeoutMs;
    }

    /// <inheritdoc />
    public void AbortPipe()
    {
        if (this.Disposed)
        {
            throw new ObjectDisposedException("handle");
        }

        var status = FT_AbortPipe(this.handle, this.PipeId).ToStatus();
        if (status != FtStatus.Ok)
        {
            throw new FtException($"Error on AbortPipe: {status}", status);
        }
    }

    /// <inheritdoc />
    public void FlushPipe()
    {
        if (this.Disposed)
        {
            throw new ObjectDisposedException("handle");
        }

        var status = FT_FlushPipe(this.handle, this.PipeId).ToStatus();
        if (status != FtStatus.Ok)
        {
            throw new FtException($"Error on FlushPipe: {status}", status);
        }
    }

    /// <inheritdoc />
    public void ClearStreamPipe()
    {
        if (this.Disposed)
        {
            throw new ObjectDisposedException("handle");
        }

        var status = FT_ClearStreamPipe(this.handle, 0, 0, this.PipeId).ToStatus();
        if (status != FtStatus.Ok)
        {
            throw new FtException($"Error on ClearStreamPipe: {status}", status);
        }
    }

    /// <inheritdoc />
    public void Prepare(uint streamSize, uint timeoutMs)
    {
        this.SetStreamPipe(streamSize);

        this.SetPipeTimeoutMs(timeoutMs);
    }

    /// <inheritdoc />
    public void Clean()
    {
        if (this.Disposed)
        {
            throw new ObjectDisposedException("handle");
        }

        var exceptions = new List<Exception>();

        var status = FT_AbortPipe(this.handle, this.PipeId).ToStatus();
        if (status != FtStatus.Ok)
        {
            exceptions.Add(new FtException($"Error on AbortPipe: {status}", status));
        }

        status = FT_FlushPipe(this.handle, this.PipeId).ToStatus();
        if (status != FtStatus.Ok)
        {
            exceptions.Add(new FtException($"Error on FlushPipe: {status}", status));
        }

        status = FT_ClearStreamPipe(this.handle, 0, 0, this.PipeId).ToStatus();
        if (status != FtStatus.Ok)
        {
            exceptions.Add(new FtException($"Error on ClearStreamPipe: {status}", status));
        }

        if (exceptions.Count > 0)
        {
            throw new AggregateException(exceptions);
        }
    }

    /// <inheritdoc />
    public uint Read(byte[] buffer)
    {
        if (buffer == null)
        {
            throw new ArgumentNullException(nameof(buffer));
        }

        if (buffer.Length <= 0)
        {
            throw new ArgumentException("Invalid buffer", nameof(buffer));
        }

        if (!this.isReadPipe)
        {
            throw new FtException("Pipe is not IN pipe", FtStatus.OtherError);
        }

        if (this.Disposed)
        {
            throw new ObjectDisposedException("handle");
        }

        uint length = (uint)buffer.Length;
        uint readSize;
        var status = FT_ReadPipe(this.handle, this.PipeId, buffer, length, out readSize, this.timeoutMillisec).ToStatus();
        if (status == FtStatus.Timeout)
        {
            if (!this.DoNotRaiseTimeoutException)
            {
                throw new FtException("Timeout on ReadPipe", status);
            }

            return 0;
        }

        if (status != FtStatus.Ok)
        {
            throw new FtException($"Error on ReadPipe: {status}", status);
        }

        return readSize;
    }

    /// <inheritdoc />
    public uint Write(byte[] buffer)
    {
        if (buffer == null)
        {
            throw new ArgumentNullException(nameof(buffer));
        }

        if (this.isReadPipe)
        {
            throw new FtException("Pipe is not OUT pipe", FtStatus.OtherError);
        }

        if (buffer.Length <= 0)
        {
            return 0;
        }

        if (this.Disposed)
        {
            throw new ObjectDisposedException("handle");
        }

        uint length = (uint)buffer.Length;
        uint writeSize;
        var status = FT_WritePipe(this.handle, this.PipeId, buffer, length, out writeSize, this.timeoutMillisec).ToStatus();
        if (status == FtStatus.Timeout)
        {
            if (!this.DoNotRaiseTimeoutException)
            {
                throw new FtException("Timeout on WritePipe", status);
            }

            return 0;
        }

        if (status != FtStatus.Ok)
        {
            throw new FtException($"Error on WritePipe: {status}", status);
        }

        return writeSize;
    }
}
