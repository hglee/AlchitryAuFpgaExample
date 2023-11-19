namespace Hglee.Device.Ftd3xx;

using System.Runtime.InteropServices;

/// <summary>
/// Device list info node
/// </summary>
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
public struct FT_DEVICE_LIST_INFO_NODE
{
    public uint Flags;
    public uint Type;
    public uint ID;
    public uint LocId;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 16)]
    public string SerialNumber;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
    public string Description;
    public IntPtr ftHandle;

    /// <inheritdoc />
    public override string ToString()
    {
        return $"Flags: {this.Flags:X}, Type: {this.Type:X}, ID: {this.ID:X}, SerialNumber: {this.SerialNumber}, Description: {this.Description}";
    }
}
