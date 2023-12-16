namespace McsChartApp.Models;

using System;
using System.Collections.Generic;
using System.Reactive.Subjects;
using System.Threading.Tasks;
using System.Threading;
using Hglee.Device.Ftd3xx;
using System.Diagnostics;

/// <summary>
/// Dummy main model
/// </summary>
public class DummyMainModel : IMainModel
{
    /// <summary>
    /// Default read task wait (ms)
    /// </summary>
    private static readonly int DefaultReadTaskWaitMs = 1000;

    /// <summary>
    /// Default sample generation delay (ms)
    /// </summary>
    private static readonly int DefaultGenerateDelayMs = 5;

    /// <summary>
    /// Sample received subject.
    /// </summary>
    private readonly Subject<SampleData> sampleReceived;

    /// <summary>
    /// Read task cancel token
    /// </summary>
    private CancellationTokenSource? readTaskCts;

    /// <summary>
    /// Read task handle
    /// </summary>
    private Task? readTask;

    /// <summary>
    /// Initializes a new instance of the <see cref="DummyMainModel"/> class.
    /// </summary>
    public DummyMainModel()
    {
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

        this.sampleReceived.Dispose();
    }

    /// <inheritdoc />
    public IReadOnlyList<FT_DEVICE_LIST_INFO_NODE> GetDeviceList(TimeSpan timeout)
    {
        return new[]
        {
            new FT_DEVICE_LIST_INFO_NODE { SerialNumber = "DUMMY_0001", Description = "Dummy Device" }
        };
    }

    /// <inheritdoc />
    public void Start(uint deviceIndex, SignalType signalType, PipeOption readPipeOption, PipeOption writePipeOption)
    {
        this.ReadSignalType = signalType;
        this.ReadPipeOption = readPipeOption;

        this.StartReadTask();
    }

    /// <inheritdoc />
    public void Stop()
    {
        this.StopReadTask();
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

        var token = this.readTaskCts.Token;

        while (!token.IsCancellationRequested)
        {
            token.ThrowIfCancellationRequested();

            try
            {
                this.GenerateSamples();

                Task.Delay(DefaultGenerateDelayMs, token).Wait(token);
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
    /// Generate dummy samples
    /// </summary>
    private void GenerateSamples()
    {
        var timeStamp = DateTime.UtcNow;
        var sampleSize = this.ReadPipeOption.StreamSize / 2;
        var result = new double[sampleSize];

        for (int i = 0; i < sampleSize; ++i)
        {
            if (this.ReadSignalType == SignalType.Linear)
            {
                result[i] = i / 32767.0;
            }
            else
            {
                result[i] = Math.Sin(2.0 * Math.PI * i / sampleSize);
            }
        }

        this.sampleReceived.OnNext(new SampleData(timeStamp, result));
    }
}