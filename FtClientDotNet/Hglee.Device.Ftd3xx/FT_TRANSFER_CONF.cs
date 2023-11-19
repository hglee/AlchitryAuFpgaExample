namespace Hglee.Device.Ftd3xx;

using System.Runtime.InteropServices;

/// <summary>
/// Transfer config. Only for Linux, macOS
/// </summary>
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
internal struct FT_TRANSFER_CONF
{
    public ushort wStructSize;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst = 2)]
    public FT_PIPE_TRANSFER_CONF[] pipe;
    public uint fStopReadingOnURBUnderrun;
    public uint fBitBangMode;
    public uint fKeepDeviceSideBufferAfterReopen;
}
