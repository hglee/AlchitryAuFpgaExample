namespace McsChartApp.ViewModels;

/// <summary>
/// Device information.
/// </summary>
public sealed class DeviceInfo
{
    /// <summary>
    /// Initializes a new instance of the <see cref="DeviceInfo"/> class.
    /// </summary>
    /// <param name="index">Device index</param>
    /// <param name="serialNumber">Device serial number.</param>
    /// <param name="description">Device description.</param>
    public DeviceInfo(int index, string? serialNumber, string? description)
    {
        this.Index = index;
        this.SerialNumber = serialNumber ?? string.Empty;
        this.Description = description ?? string.Empty;
    }

    /// <summary>
    /// Gets device index.
    /// </summary>
    public int Index { get; }

    /// <summary>
    /// Gets device serial number.
    /// </summary>
    public string SerialNumber { get; }

    /// <summary>
    /// Gets device description.
    /// </summary>
    public string Description { get; }
}