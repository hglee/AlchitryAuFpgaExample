namespace Hglee.Device.Ftd3xx;

using System.Runtime.Serialization;

/// <summary>
/// Exception type in for FT3xx
/// </summary>
[Serializable]
public sealed class FtException : Exception
{
    /// <summary>
    /// Initializes a new instance of the <see cref="FtException"/> class.
    /// </summary>
    public FtException()
    {
        this.Status = FtStatus.OtherError;
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="FtException"/> class.
    /// </summary>
    /// <param name="message">Error message.</param>
    /// <param name="status">Related status.</param>
    public FtException(string message, FtStatus status)
        : base(message)
    {
        this.Status = status;
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="FtException"/> class.
    /// </summary>
    /// <param name="message">Error message.</param>
    /// <param name="status">Related status.</param>
    /// <param name="innerException">Inner exception</param>
    public FtException(string message, FtStatus status, Exception innerException)
        : base(message, innerException)
    {
        this.Status = status;
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="FtException"/> class.
    /// </summary>
    /// <param name="info">Serialization info.</param>
    /// <param name="context">Streaming context.</param>
    private FtException(SerializationInfo info, StreamingContext context)
        : base(info, context)
    {
        this.Status = FtStatus.OtherError;
    }

    /// <summary>
    /// Gets related status.
    /// </summary>
    public FtStatus Status { get; }
}
