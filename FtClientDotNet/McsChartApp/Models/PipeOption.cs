namespace McsChartApp.Models;

using ReactiveUI;

/// <summary>
/// Pipe option
/// </summary>
public sealed class PipeOption : ReactiveObject
{
    /// <summary>
    /// <see cref="StreamSize"/> backfield.
    /// </summary>
    private int streamSize;

    /// <summary>
    /// <see cref="PipeId"/> backfield.
    /// </summary>
    private int pipeId;

    /// <summary>
    /// <see cref="TimeoutMs"/> backfield.
    /// </summary>
    private int timeoutMs;

    /// <summary>
    /// Gets or sets stream size.
    /// </summary>
    public int StreamSize
    {
        get => this.streamSize;
        set
        {
            if (value > 0)
            {
                this.RaiseAndSetIfChanged(ref this.streamSize, value);
            }
        }
    }

    /// <summary>
    /// Gets or sets pipe id.
    /// </summary>
    public int PipeId
    {
        get => this.pipeId;
        set => this.RaiseAndSetIfChanged(ref this.pipeId, value);
    }

    /// <summary>
    /// Gets or sets timeout (ms).
    /// </summary>
    public int TimeoutMs
    {
        get => this.timeoutMs;
        set
        {
            if (value > 0)
            {
                this.RaiseAndSetIfChanged(ref this.timeoutMs, value);
            }
        }
    }
}