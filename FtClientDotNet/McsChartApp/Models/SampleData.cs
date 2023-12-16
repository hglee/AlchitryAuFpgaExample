namespace McsChartApp.Models;

using System;

/// <summary>
/// Converted sample data
/// </summary>
public sealed class SampleData
{
    /// <summary>
    /// Initializes a new instance of the <see cref="SampleData"/> class.
    /// </summary>
    /// <param name="timeStamp">Read time stamp.</param>
    /// <param name="samples">Converted sample data.</param>
    public SampleData(DateTime timeStamp, double[] samples)
    {
        if (samples == null)
        {
            throw new ArgumentNullException(nameof(samples));
        }

        this.TimeStamp = timeStamp;
        this.Samples = samples;
    }

    /// <summary>
    /// Gets read time stamp.
    /// </summary>
    public DateTime TimeStamp { get; }

    /// <summary>
    /// Gets converted sample data.
    /// </summary>
    public double[] Samples { get; }
}