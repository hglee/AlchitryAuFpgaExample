namespace Hglee.Device.Ftd3xx;

using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

/// <summary>
/// Utility class
/// </summary>
public static class FtWrapperUtil
{
    /// <summary>
    /// Make wrapper instance by platform.
    /// </summary>
    /// <returns>Wrapper object.</returns>
    public static IFtd3xxWrapper MakeWrapper()
    {
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            return new Ftd3xxWrapperWindows();
        }

        if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
        {
            return new Ftd3xxWrapperLinux();
        }

        throw new FtException("Not supported platform", FtStatus.OtherError);
    }

    /// <summary>
    /// Converts rawStatus to <see cref="FtStatus"/>
    /// </summary>
    /// <param name="rawStatus">Raw status value.</param>
    /// <returns>Returns converted status.</returns>
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    public static FtStatus ToStatus(this uint rawStatus)
    {
        if (rawStatus > (uint)FtStatus.OtherError)
        {
            return FtStatus.OtherError;
        }

        return (FtStatus)rawStatus;
    }

    /// <summary>
    /// Validate read pipe ID.
    /// </summary>
    /// <param name="pipeId">Pipe id.</param>
    /// <returns>true for valid read pipe ID.</returns>
    public static bool IsValidReadPipeId(byte pipeId)
    {
        return pipeId >= 0x82 && pipeId <= 0x85;
    }

    /// <summary>
    /// Validate write pipe ID.
    /// </summary>
    /// <param name="pipeId">Pipe id.</param>
    /// <returns>true for valid write pipe ID.</returns>
    public static bool IsValidWritePipeId(byte pipeId)
    {
        return pipeId >= 0x02 && pipeId <= 0x05;
    }
}