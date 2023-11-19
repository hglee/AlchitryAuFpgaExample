namespace Hglee.Device.Ftd3xx;

using System;

/// <summary>
/// Statistics report class
/// </summary>
public sealed class StatisticsReport
{
    /// <summary>
    /// 1 second in microseconds
    /// </summary>
    private static readonly double OneSecondInUs = 1000 * 1000;

    /// <summary>
    /// Last report timestamp
    /// </summary>
    private DateTime lastReportTime;

    /// <summary>
    /// Total size
    /// </summary>
    private ulong totalSize;

    /// <summary>
    /// Initializes a new instance of the <see cref="StatisticsReport"/> class.
    /// </summary>
    public StatisticsReport()
    {
        this.Reset();
    }

    /// <summary>
    /// Reset state.
    /// </summary>
    public void Reset()
    {
        this.lastReportTime = DateTime.Now;
        this.totalSize = 0;
    }

    /// <summary>
    /// Add read/write size and print statistics.
    /// </summary>
    public void AddSize(ulong size)
    {
        this.totalSize += size;

        var now = DateTime.Now;
        var diffTime = now - this.lastReportTime;
        var totalUs = diffTime.TotalMilliseconds * 1000.0;

        if (totalUs > OneSecondInUs)
        {
            var megaBytesPerSecond = (double)this.totalSize / totalUs;

            Console.WriteLine($"{megaBytesPerSecond:0.00} (MB/s) - {this.totalSize} bytes in {totalUs:0.00} (us)");

            this.Reset();
        }
    }
}
