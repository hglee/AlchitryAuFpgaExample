namespace Hglee.Device.Ftd3xx;

using System.Runtime.InteropServices;

/// <summary>
/// Pipe transfer config. Only for Linux, macOS
/// </summary>
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
internal struct FT_PIPE_TRANSFER_CONF
{
    public uint fPipeNotUsed;
    public uint fNonThreadSafeTransfer;
    public uint bURBCount;
    public ushort wURBBufferCount;
    public uint dwURBBufferSize;
    public uint dwStreamingSize;
}
