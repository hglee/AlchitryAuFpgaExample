namespace McsChartApp.ViewModels;

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Windows.Input;
using Avalonia.Threading;
using Models;
using MsBox.Avalonia;
using MsBox.Avalonia.Enums;
using OxyPlot;
using OxyPlot.Axes;
using OxyPlot.Series;
using ReactiveUI;

/// <summary>
/// Main view model.
/// </summary>
public class MainWindowViewModel : ViewModelBase, IDisposable
{
    /// <summary>
    /// Default chart update period (ms)
    /// </summary>
    private static readonly int DefaultChartUpdatePeriodMs = 33;

    /// <summary>
    /// Default refresh timeout (ms)
    /// </summary>
    private static readonly int DefaultRefreshTimeoutMs = 3000;

    /// <summary>
    /// Default read stream size (bytes)
    /// </summary>
    private static readonly int DefaultReadStreamSize = 32 * 1024;

    /// <summary>
    /// Default read pipe ID
    /// </summary>
    private static readonly int DefaultReadPipeId = 0x82;

    /// <summary>
    /// Default read timeout (ms)
    /// </summary>
    private static readonly int DefaultReadTimeoutMs = 500;

    /// <summary>
    /// Default write command size (bytes)
    /// </summary>
    private static readonly int DefaultWriteCommandSize = 2;

    /// <summary>
    /// Default write pipe ID
    /// </summary>
    private static readonly int DefaultWritePipeId = 0x02;

    /// <summary>
    /// Default write timeout (ms)
    /// </summary>
    private static readonly int DefaultWriteTimeoutMs = 500;

    /// <summary>
    /// Lock for <see cref="sampleBuffer"/>
    /// </summary>
    private readonly object sampleBufferLock;

    /// <summary>
    /// Buffer to store sample data
    /// </summary>
    private readonly List<SampleData> sampleBuffer;

    /// <summary>
    /// Chart update timer
    /// </summary>
    private readonly DispatcherTimer chartUpdateTimer;

    /// <summary>
    /// <see cref="Model"/> backfield.
    /// </summary>
    private IMainModel? model;

    /// <summary>
    /// Model sample received subscription
    /// </summary>
    private IDisposable? modelSubscription;

    /// <summary>
    /// <see cref="RefreshTimeoutMs"/> backfield.
    /// </summary>
    private int refreshTimeoutMs;

    /// <summary>
    /// <see cref="SelectedDeviceItem"/> backfield.
    /// </summary>
    private object? selectedDeviceItem;

    /// <summary>
    /// <see cref="SignalTypeIndex"/> backfield.
    /// </summary>
    private int signalTypeIndex;

    /// <summary>
    /// <see cref="Started"/> backfield.
    /// </summary>
    private bool started;

    /// <summary>
    /// Initializes a new instance of the <see cref="MainWindowViewModel"/> class.
    /// </summary>
    public MainWindowViewModel()
    {
        this.sampleBufferLock = new object();
        this.sampleBuffer = new List<SampleData>();

        this.chartUpdateTimer = new DispatcherTimer
        {
            Interval = TimeSpan.FromMilliseconds(DefaultChartUpdatePeriodMs)
        };
        this.chartUpdateTimer.Tick += this.ChartUpdateTimerOnTick;

        this.PlotModel = new PlotModel();
        this.PlotModel.Axes.Add(new LinearAxis { Position = AxisPosition.Left, Minimum = -1.0, Maximum = 1.0 });
        this.PlotModel.Series.Add(new LineSeries { LineStyle = LineStyle.Solid });

        this.DeviceList = new ObservableCollection<DeviceInfo>();
        this.RefreshTimeoutMs = DefaultRefreshTimeoutMs;
        this.ReadPipeOption = new PipeOption
        {
            StreamSize = DefaultReadStreamSize,
            PipeId = DefaultReadPipeId,
            TimeoutMs = DefaultReadTimeoutMs,
        };
        this.WritePipeOption = new PipeOption
        {
            StreamSize = DefaultWriteCommandSize,
            PipeId = DefaultWritePipeId,
            TimeoutMs = DefaultWriteTimeoutMs
        };

        var notStartedObservable = this.WhenAnyValue(x => x.Started, v => !v);
        var startedObservable = this.WhenAnyValue(x => x.Started);

        this.RefreshDeviceListCommand = ReactiveCommand.Create(this.RefreshDeviceList, notStartedObservable);
        this.StartCommand = ReactiveCommand.Create(this.Start, notStartedObservable);
        this.StopCommand = ReactiveCommand.Create(this.Stop, startedObservable);

        this.RaisePropertyChanged("PlotModel");
    }

    /// <summary>
    /// Target model.
    /// </summary>
    public IMainModel? Model
    {
        get => this.model;
        set
        {
            this.modelSubscription?.Dispose();
            this.modelSubscription = null;

            this.model = value;

            if (this.model != null)
            {
                this.modelSubscription = this.model.SampleReceived.Subscribe(x =>
                {
                    lock (this.sampleBufferLock)
                    {
                        this.sampleBuffer.Add(x);
                    }
                });
            }
        }
    }

    /// <summary>
    /// Plot model
    /// </summary>
    public PlotModel PlotModel { get; }

    /// <summary>
    /// Gets device information list.
    /// </summary>
    public ObservableCollection<DeviceInfo> DeviceList { get; }

    /// <summary>
    /// Gets or sets timeout on refresh (ms).
    /// </summary>
    public int RefreshTimeoutMs
    {
        get => this.refreshTimeoutMs;
        set
        {
            if (value > 0)
            {
                this.RaiseAndSetIfChanged(ref this.refreshTimeoutMs, value);
            }
        }
    }

    /// <summary>
    /// Gets or sets selected device item.
    /// </summary>
    public object? SelectedDeviceItem
    {
        get => this.selectedDeviceItem;
        set => this.RaiseAndSetIfChanged(ref this.selectedDeviceItem, value);
    }

    /// <summary>
    /// Gets read pipe option.
    /// </summary>
    public PipeOption ReadPipeOption { get; }

    /// <summary>
    /// Gets write pipe option.
    /// </summary>
    public PipeOption WritePipeOption { get; }

    /// <summary>
    /// Gets or sets signal type.
    /// </summary>
    public int SignalTypeIndex
    {
        get => this.signalTypeIndex;
        set => this.RaiseAndSetIfChanged(ref this.signalTypeIndex, value);
    }

    /// <summary>
    /// Gets operation is started.
    /// </summary>
    public bool Started
    {
        get => this.started;
        set => this.RaiseAndSetIfChanged(ref this.started, value);
    }

    /// <summary>
    /// Gets refresh device list command.
    /// </summary>
    public ICommand RefreshDeviceListCommand { get; }

    /// <summary>
    /// Gets start command.
    /// </summary>
    public ICommand StartCommand { get; }

    /// <summary>
    /// Gets stop command.
    /// </summary>
    public ICommand StopCommand { get; }

    /// <inheritdoc />
    public void Dispose()
    {
        this.modelSubscription?.Dispose();
        this.modelSubscription = null;

        this.chartUpdateTimer.Stop();
        this.chartUpdateTimer.Tick -= this.ChartUpdateTimerOnTick;
    }

    /// <summary>
    /// Refresh device info items.
    /// </summary>
    private async void RefreshDeviceList()
    {
        if (this.Model == null)
        {
            await MessageBoxManager.GetMessageBoxStandard("Warning", "Model did not initialized.", icon: Icon.Warning).ShowAsync();

            return;
        }

        if (this.RefreshTimeoutMs <= 0)
        {
            await MessageBoxManager.GetMessageBoxStandard("Warning", $"Invalid refresh timeout: {this.RefreshTimeoutMs}", icon: Icon.Warning).ShowAsync();

            return;
        }

        this.DeviceList.Clear();

        try
        {
            var nodes = this.Model.GetDeviceList(TimeSpan.FromMilliseconds(this.RefreshTimeoutMs));

            for (int i = 0; i < nodes.Count; ++i)
            {
                this.DeviceList.Add(new DeviceInfo(i, nodes[i].SerialNumber, nodes[i].Description));
            }

            if (this.DeviceList.Count <= 0)
            {
                await MessageBoxManager.GetMessageBoxStandard("Info", "Cannot find device", icon: Icon.Info).ShowAsync();
            }
        }
        catch (Exception ex)
        {
            Trace.TraceWarning($"Error on refresh device list: {ex.Message}");

            await MessageBoxManager.GetMessageBoxStandard("Warning", $"Error on refresh: {ex.Message}", icon: Icon.Warning).ShowAsync();
        }
    }

    /// <summary>
    /// Start operation.
    /// </summary>
    private async void Start()
    {
        if (this.Model == null)
        {
            await MessageBoxManager.GetMessageBoxStandard("Warning", "Model did not initialized.", icon: Icon.Warning).ShowAsync();

            return;
        }

        if (this.Started)
        {
            await MessageBoxManager.GetMessageBoxStandard("Warning", "Operation already started.", icon: Icon.Warning).ShowAsync();

            return;
        }

        this.ClearPlotModel();
        this.ClearSampleBuffer();

        var deviceItem = this.SelectedDeviceItem as DeviceInfo;
        var signalType = (SignalType) this.SignalTypeIndex;

        if (deviceItem == null)
        {
            await MessageBoxManager.GetMessageBoxStandard("Warning", "Device not selected.", icon: Icon.Warning).ShowAsync();

            return;
        }

        try
        {
            this.Model.Start((uint) deviceItem.Index, signalType, this.ReadPipeOption, this.WritePipeOption);

            this.chartUpdateTimer.Start();

            this.Started = true;
        }
        catch (Exception ex)
        {
            Trace.TraceWarning($"Error on start model: {ex.Message}");

            await MessageBoxManager.GetMessageBoxStandard("Warning", $"Error on start: {ex.Message}", icon: Icon.Warning).ShowAsync();
        }
    }

    /// <summary>
    /// Stop operation.
    /// </summary>
    private async void Stop()
    {
        if (this.Model == null)
        {
            await MessageBoxManager.GetMessageBoxStandard("Warning", $"Model did not initialized.", icon: Icon.Warning).ShowAsync();

            return;
        }

        if (!this.Started)
        {
            await MessageBoxManager.GetMessageBoxStandard("Warning", "Operation did not started.", icon: Icon.Warning).ShowAsync();

            return;
        }

        try
        {
            this.chartUpdateTimer.Stop();

            this.Model.Stop();
        }
        catch (AggregateException ex)
        {
            var builder = new StringBuilder();

            ex.Handle(x =>
            {
                if (!(x is OperationCanceledException))
                {
                    builder.AppendLine(x.Message);
                }

                return true;
            });

            if (builder.Length > 0)
            {
                Trace.TraceWarning($"Error on stop model (inner): {builder}");

                await MessageBoxManager.GetMessageBoxStandard("Warning", $"Error on stop: {builder}", icon: Icon.Warning)
                    .ShowAsync();
            }
        }
        catch (Exception ex)
        {
            Trace.TraceWarning($"Error on stop model: {ex.Message}");

            await MessageBoxManager.GetMessageBoxStandard("Warning", $"Error on stop: {ex.Message}", icon: Icon.Warning)
                .ShowAsync();
        }
        finally
        {
            this.Started = false;
        }
    }

    /// <summary>
    /// Clear plot model.
    /// </summary>
    private void ClearPlotModel()
    {
        ((LineSeries)this.PlotModel.Series[0]).Points.Clear();

        this.PlotModel.DefaultXAxis.Reset();
        this.PlotModel.DefaultXAxis.Maximum = 65536;

        this.PlotModel.Axes[0].Reset();

        this.PlotModel.InvalidatePlot(true);

        var signalType = (SignalType) this.SignalTypeIndex;

        if (signalType == SignalType.Sine)
        {
            // source range: 256
            this.PlotModel.DefaultXAxis.Maximum = 1024;
        }
    }

    /// <summary>
    /// Clears sample buffer
    /// </summary>
    private void ClearSampleBuffer()
    {
        lock (this.sampleBufferLock)
        {
            this.sampleBuffer.Clear();
        }
    }

    /// <summary>
    /// Chart update timer tick handler.
    /// </summary>
    /// <param name="sender">Sender object.</param>
    /// <param name="e">Event arguments.</param>
    private void ChartUpdateTimerOnTick(object? sender, EventArgs e)
    {
        var series = (LineSeries)this.PlotModel.Series[0];

        series.Points.Clear();

        List<SampleData> localBuffer;

        lock (this.sampleBufferLock)
        {
            localBuffer = this.sampleBuffer.ToList();

            this.sampleBuffer.Clear();
        }

        long index = 0;

        foreach (var data in localBuffer)
        {
            foreach (var sample in data.Samples)
            {
                series.Points.Add(new DataPoint(index++, sample));
            }
        }

        this.RaisePropertyChanged("PlotModel");

        this.PlotModel.InvalidatePlot(true);
    }
}
