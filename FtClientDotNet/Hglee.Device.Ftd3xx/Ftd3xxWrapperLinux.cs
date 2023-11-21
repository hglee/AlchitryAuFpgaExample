namespace Hglee.Device.Ftd3xx;

using System.Runtime.InteropServices;

/// <summary>
/// FTD3xx wrapper class for Linux
/// </summary>
/// <remarks>See native header for detail types (Types.h). Some examples,
/// <list type='bullet'>
/// <item>DWORD : unsigned int</item>
/// <item>ULONG : unsigned int</item>
/// <item>BOOL : unsigned int</item>
/// <item>BOOLEAN : unsigned char</item>
/// </list>
/// </remarks>
public class Ftd3xxWrapperLinux : IFtd3xxWrapper
{
    /// <summary>
    /// Builds a device information list and returns the number of D3XX devices connected to the system.
    /// <para>FT_STATUS FT_CreateDeviceInfoList(LPDWORD lpdwNumDevs)</para>
    /// </summary>
    /// <param name="lpdwNumDevs">Pointer to unsigned long to store the number of devices connected</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_CreateDeviceInfoList(out uint lpdwNumDevs);

    /// <summary>
    /// Returns a device information list and the number of D3XX devices in the list.
    /// <para>FT_STATUS FT_GetDeviceInfoList(FT_DEVICE_LIST_INFO_NODE *ptDest, LPDWORD lpdwNumDevs)</para>
    /// </summary>
    /// <param name="ptDest">Pointer to an array of FT_DEVICE_LIST_INFO_NODE structures</param>
    /// <param name="lpdwNumDevs">Pointer to unsigned long to store the number of devices connected.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_GetDeviceInfoList([Out] FT_DEVICE_LIST_INFO_NODE[] ptDest, out uint lpdwNumDevs);

    /// <summary>
    /// Sets transfer parameters for each FIFO channel.
    /// <para>FT_STATUS FT_SetTransferParams(FT_TRANSFER_CONF *pConf, DWORD dwFifoID)</para>
    /// </summary>
    /// <param name="pConf">Transfer config.</param>
    /// <param name="dwFifoID">FIFO interface ID (0 ~ 3)</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_SetTransferParams(ref FT_TRANSFER_CONF pConf, uint dwFifoID);

    /// <summary>
    /// Open the device and return a handle which will be used for subsequent accesses.
    /// <para>FT_STATUS FT_Create(PVOID pvArg, DWORD dwFlags, FT_HANDLE *pftHandle)</para>
    /// </summary>
    /// <param name="pvArg">Pointer to argument.</param>
    /// <param name="dwFlags"></param>
    /// <param name="ftHandle">Pointer to handle.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_Create(IntPtr pvArg, uint dwFlags, ref IntPtr ftHandle);

    /// <summary>
    /// Close an open device.
    /// <para>FT_STATUS FT_Close(FT_HANDLE ftHandle)</para>
    /// </summary>
    /// <param name="ftHandle">Target handle.</param>
    /// <returns>FT_STATUS code</returns>
    [DllImport("libftd3xx.so")]
    private static extern uint FT_Close(IntPtr ftHandle);

    /// <summary>
    /// Opened pipe list.
    /// </summary>
    private readonly List<IFtd3xxPipe> pipes;

    /// <summary>
    /// Disposed flag
    /// </summary>
    private bool disposed;

    /// <summary>
    /// Device handle
    /// </summary>
    private IntPtr handle;

    /// <summary>
    /// Initializes a new instance of the <see cref="Ftd3xxWrapperLinux"/> class.
    /// </summary>
    public Ftd3xxWrapperLinux()
    {
        this.pipes = new List<IFtd3xxPipe>();
        this.handle = IntPtr.Zero;
    }

    /// <summary>
    /// Finalizer
    /// </summary>
    ~Ftd3xxWrapperLinux()
    {
        this.Dispose(false);
    }

    /// <inheritdoc />
    public bool IsOpened => this.handle != IntPtr.Zero;

    /// <inheritdoc />
    public IReadOnlyList<FT_DEVICE_LIST_INFO_NODE> GetDeviceInfoList(TimeSpan timeout)
    {
        var endTime = DateTime.Now + timeout;
        uint numberOfDevices;

        while (true)
        {
            var status = FT_CreateDeviceInfoList(out numberOfDevices).ToStatus();
            if (status == FtStatus.Ok)
            {
                break;
            }

            if (DateTime.Now > endTime)
            {
                numberOfDevices = 0;

                break;
            }

            Thread.Sleep(1);
        }

        if (numberOfDevices == 0)
        {
            return Array.Empty<FT_DEVICE_LIST_INFO_NODE>();
        }

        var nodes = new FT_DEVICE_LIST_INFO_NODE[numberOfDevices];

        var nodeStatus = FT_GetDeviceInfoList(nodes, out numberOfDevices).ToStatus();
        if (nodeStatus != FtStatus.Ok)
        {
            throw new FtException("Cannot get device info list", nodeStatus);
        }

        return nodes;
    }

    /// <inheritdoc />
    public void Prepare()
    {
        // Turn off thread safe
        var conf = new FT_TRANSFER_CONF();
        conf.wStructSize = (ushort) Marshal.SizeOf(conf);
        conf.pipe = new FT_PIPE_TRANSFER_CONF[2];
        conf.pipe[0].fNonThreadSafeTransfer = 1;
        conf.pipe[1].fNonThreadSafeTransfer = 1;

        for (uint i = 0; i < 4; ++i)
        {
            // ignore return code
            FT_SetTransferParams(ref conf, i);
        }
    }

    /// <inheritdoc />
    public void Open(uint deviceIndex)
    {
        if (this.IsOpened)
        {
            throw new FtException("Device already opened.", FtStatus.OtherError);
        }

        // open by index (0x10)
        var status = FT_Create(new IntPtr((int)deviceIndex), 0x10, ref this.handle).ToStatus();
        if (status != FtStatus.Ok)
        {
            throw new FtException("Cannot create device handle", status);
        }

        if (this.handle == IntPtr.Zero)
        {
            throw new FtException("Handle did not opened", FtStatus.OtherError);
        }
    }

    /// <inheritdoc />
    public IFtd3xxPipe MakeInPipe(byte pipeId)
    {
        if (!FtWrapperUtil.IsValidReadPipeId(pipeId))
        {
            throw new ArgumentOutOfRangeException(nameof(pipeId));
        }

        if (!this.IsOpened)
        {
            throw new FtException("Device not opened.", FtStatus.OtherError);
        }

        foreach (var pipe in this.pipes)
        {
            if (pipe.PipeId == pipeId)
            {
                return pipe;
            }
        }

        var newPipe = new Ftd3xxPipeLinux(this.handle, pipeId, true);

        this.pipes.Add(newPipe);

        return newPipe;
    }

    /// <inheritdoc />
    public IFtd3xxPipe MakeOutPipe(byte pipeId)
    {
        if (!FtWrapperUtil.IsValidWritePipeId(pipeId))
        {
            throw new ArgumentOutOfRangeException(nameof(pipeId));
        }

        if (!this.IsOpened)
        {
            throw new FtException("Device not opened.", FtStatus.OtherError);
        }

        foreach (var pipe in this.pipes)
        {
            if (pipe.PipeId == pipeId)
            {
                return pipe;
            }
        }

        var newPipe = new Ftd3xxPipeLinux(this.handle, pipeId, false);

        this.pipes.Add(newPipe);

        return newPipe;
    }

    /// <inheritdoc />
    public void Close()
    {
        this.CloseImpl(true);
    }

    /// <inheritdoc />
    public void Dispose()
    {
        this.Dispose(true);

        GC.SuppressFinalize(this);
    }

    /// <summary>
    /// Dispose pattern.
    /// </summary>
    /// <param name="disposing">Dispose managed resource.</param>
    protected virtual void Dispose(bool disposing)
    {
        if (this.disposed)
        {
            return;
        }

        if (disposing)
        {
            this.CloseImpl(false);
        }
        else
        {
            if (this.handle != IntPtr.Zero)
            {
                FT_Close(this.handle);

                this.handle = IntPtr.Zero;
            }
        }

        this.disposed = true;
    }

    /// <summary>
    /// Close device
    /// </summary>
    /// <param name="raiseException">Raise exception on error</param>
    private void CloseImpl(bool raiseException)
    {
        if (!this.IsOpened)
        {
            return;
        }

        var exceptions = new List<Exception>();

        foreach (var pipe in this.pipes)
        {
            try
            {
                pipe.Clean();
            }
            catch (Exception ex)
            {
                exceptions.Add(ex);
            }
            finally
            {
                pipe.Disposed = true;
            }
        }

        this.pipes.Clear();

        var status = FT_Close(this.handle).ToStatus();
        if (status != FtStatus.Ok)
        {
            exceptions.Add(new FtException("Error on close device handle", status));
        }

        this.handle = IntPtr.Zero;

        if (raiseException && exceptions.Count > 0)
        {
            throw new AggregateException(exceptions);
        }
    }
}