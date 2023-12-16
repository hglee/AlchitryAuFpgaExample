namespace McsChartApp.Models;

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reactive.Subjects;
using System.Threading;
using System.Threading.Tasks;
using Hglee.Device.Ftd3xx;

/// <summary>
/// Main model.
/// </summary>
public class MainModel : IMainModel
{
    /// <summary>
    /// Default read task wait (ms)
    /// </summary>
    private static readonly int DefaultReadTaskWaitMs = 1000;

    /// <summary>
    /// Device wrapper
    /// </summary>
    private readonly IFtd3xxWrapper wrapper;

    /// <summary>
    /// Sample received subject.
    /// </summary>
    private readonly Subject<SampleData> sampleReceived;

    /// <summary>
    /// Read pipe
    /// </summary>
    private IFtd3xxPipe? readPipe;

    /// <summary>
    /// Write pipe
    /// </summary>
    private IFtd3xxPipe? writePipe;

    /// <summary>
    /// Read task cancel token
    /// </summary>
    private CancellationTokenSource? readTaskCts;

    /// <summary>
    /// Read task handle
    /// </summary>
    private Task? readTask;

    /// <summary>
    /// Initializes a new instance of the <see cref="MainModel"/> class.
    /// </summary>
    public MainModel()
    {
        this.wrapper = FtWrapperUtil.MakeWrapper();
        this.wrapper.Prepare();

        this.sampleReceived = new Subject<SampleData>();

        this.ReadPipeOption = new PipeOption();
    }

    /// <inheritdoc />
    public IObservable<SampleData> SampleReceived => this.sampleReceived;

    /// <summary>
    /// Gets or sets read signal type.
    /// </summary>
    private SignalType ReadSignalType { get; set; }

    /// <summary>
    /// Gets or sets read pipe option.
    /// </summary>
    private PipeOption ReadPipeOption { get; set; }

    /// <inheritdoc />
    public void Dispose()
    {
        this.Stop();

        this.writePipe = null;
        this.readPipe = null;

        this.wrapper.Dispose();

        this.sampleReceived.Dispose();
    }

    /// <inheritdoc />
    public IReadOnlyList<FT_DEVICE_LIST_INFO_NODE> GetDeviceList(TimeSpan timeout)
    {
        return this.wrapper.GetDeviceInfoList(timeout);
    }

    /// <inheritdoc />
    public void Start(uint deviceIndex, SignalType signalType, PipeOption readPipeOption, PipeOption writePipeOption)
    {
        this.wrapper.Open(deviceIndex);

        try
        {
            this.readPipe = this.wrapper.MakeInPipe((byte) readPipeOption.PipeId);
            this.readPipe.DoNotRaiseTimeoutException = true;
            this.readPipe.Prepare((uint) readPipeOption.StreamSize, (uint) readPipeOption.TimeoutMs);

            this.writePipe = this.wrapper.MakeOutPipe((byte) writePipeOption.PipeId);
            this.writePipe.DoNotRaiseTimeoutException = false;
            this.writePipe.Prepare((uint) writePipeOption.StreamSize, (uint) writePipeOption.TimeoutMs);

            this.ReadSignalType = signalType;
            this.ReadPipeOption = readPipeOption;

            this.SendStartCommand();

            this.StartReadTask();
        }
        catch (Exception)
        {
            this.Stop();

            throw;
        }
    }

    /// <inheritdoc />
    public void Stop()
    {
        this.StopReadTask();
        this.TrySendStopCommand();

        this.readPipe = null;
        this.writePipe = null;

        this.wrapper.Close();
    }

    /// <summary>
    /// Send start command
    /// </summary>
    private void SendStartCommand()
    {
        if (this.writePipe == null)
        {
            throw new ApplicationException("Write pipe did not initialized.");
        }

        // Command format
        //  - byte0 : 0x01 for start, 0x00 for stop
        //  - byte1 : signal type
        var cmd = new byte[2];
        cmd[0] = 0x01;
        cmd[1] = (byte) this.ReadSignalType;

        var writeSize = this.writePipe.Write(cmd);
        if (writeSize != cmd.Length)
        {
            Trace.TraceWarning($"Start command did not sent correctly: {writeSize} bytes");
        }
    }

    /// <summary>
    /// Send stop command
    /// </summary>
    private void TrySendStopCommand()
    {
        if (this.writePipe == null)
        {
            return;
        }

        var cmd = new byte[2];
        cmd[0] = 0x00;
        cmd[1] = 0x00;

        try
        {
            var writeSize = this.writePipe.Write(cmd);
            if (writeSize != cmd.Length)
            {
                Trace.TraceWarning($"Stop command did not sent correctly: {writeSize} bytes");
            }
        }
        catch (Exception ex)
        {
            Trace.TraceWarning($"Error on send stop command: {ex.Message}");
        }
    }

    /// <summary>
    /// Start read task
    /// </summary>
    private void StartReadTask()
    {
        this.StopReadTask();

        this.readTaskCts = new CancellationTokenSource();
        this.readTask = Task.Factory.StartNew(this.ReadTaskEntry, this.readTaskCts.Token,
            TaskCreationOptions.LongRunning, TaskScheduler.Default);
    }

    /// <summary>
    /// Stop read task
    /// </summary>
    private void StopReadTask()
    {
        this.readTaskCts?.Cancel();

        if (this.readTask != null)
        {
            try
            {
                this.readTask.Wait(DefaultReadTaskWaitMs);
            }
            catch (AggregateException ex)
            {
                ex.Handle(x =>
                {
                    if (!(x is OperationCanceledException))
                    {
                        Trace.TraceWarning($"Error on wait read task (inner): {ex.Message}");
                    }

                    return true;
                });
            }
            catch (Exception ex)
            {
                Trace.TraceWarning($"Error on wait read task: {ex.Message}");
            }

            this.readTask.Dispose();
            this.readTask = null;
        }

        this.readTaskCts?.Dispose();
        this.readTaskCts = null;
    }

    /// <summary>
    /// Read task entry point
    /// </summary>
    private void ReadTaskEntry()
    {
        if (this.readTaskCts == null)
        {
            throw new ApplicationException("Read task cancel token did not initialized.");
        }

        if (this.readPipe == null)
        {
            throw new ApplicationException("Read pipe did not initialized.");
        }

        var token = this.readTaskCts.Token;
        var buffer = new byte[this.ReadPipeOption.StreamSize];

        while (!token.IsCancellationRequested)
        {
            token.ThrowIfCancellationRequested();

            try
            {
                var readSize = this.readPipe.Read(buffer);
                if (readSize == 0)
                {
                    // timeout
                    Thread.Sleep(1);

                    continue;
                }

                this.ConvertRawSamples(buffer, readSize);
            }
            catch (OperationCanceledException)
            {
                throw;
            }
            catch (Exception ex)
            {
                Trace.TraceWarning($"Error on read pipe: {ex.Message}");
            }
        }
    }

    /// <summary>
    /// Convert received raw samples.
    /// </summary>
    /// <param name="buffer">Sample buffer.</param>
    /// <param name="size">Read size.</param>
    private void ConvertRawSamples(byte[] buffer, uint size)
    {
        var timeStamp = DateTime.UtcNow;
        var sampleSize = size / 2;
        var result = new double[sampleSize];

        // 2 byte format
        for (int i = 0; i < sampleSize; ++i)
        {
            var b1 = buffer[i * 2];
            var b2 = buffer[i * 2 + 1];

            // be aware byte order
            var data = (uint)b2 << 8 | b1;

            if (this.ReadSignalType == SignalType.Linear)
            {
                // normalize to 1.0
                result[i] = data / 65535.0;
            }
            else
            {
                if ((data & 0x8000) != 0)
                {
                    // negative
                    var sample = (data & 0x7fff) / -32767.0;

                    result[i] = sample;
                }
                else
                {
                    var sample = data / 32767.0;

                    result[i] = sample;
                }
            }
        }

        this.sampleReceived.OnNext(new SampleData(timeStamp, result));
    }
}
