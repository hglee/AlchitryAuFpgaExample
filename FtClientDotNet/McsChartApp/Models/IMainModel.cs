namespace McsChartApp.Models;

using System;
using System.Collections.Generic;
using Hglee.Device.Ftd3xx;

/// <summary>
/// <see cref="IMainModel"/> interface defines functionality for  main model.
/// </summary>
public interface IMainModel : IDisposable
{
    /// <summary>
    /// Gets sample received notifier.
    /// </summary>
    IObservable<SampleData> SampleReceived { get; }

    /// <summary>
    /// Gets device list.
    /// </summary>
    /// <param name="timeout">Timeout on check.</param>
    /// <returns>Device list.</returns>
    IReadOnlyList<FT_DEVICE_LIST_INFO_NODE> GetDeviceList(TimeSpan timeout);

    /// <summary>
    /// Starts operation.
    /// </summary>
    /// <param name="deviceIndex">Target device index.</param>
    /// <param name="signalType">Target signal type</param>
    /// <param name="readPipeOption">Read pipe option.</param>
    /// <param name="writePipeOption">Write pipe option.</param>
    void Start(uint deviceIndex, SignalType signalType, PipeOption readPipeOption, PipeOption writePipeOption);

    /// <summary>
    /// Stops operations.
    /// </summary>
    void Stop();
}