using Hglee.Device.Ftd3xx;

const uint deviceIndex = 0;
const byte pipeId = 0x02;
const uint streamSize = 32 * 1024;
const uint timeoutMs = 500;

using var wrapper = FtWrapperUtil.MakeWrapper();

var nodes = wrapper.GetDeviceInfoList(TimeSpan.FromMilliseconds(3000));
if (nodes.Count <= 0)
{
    Console.WriteLine("Cannot find device.");

    return;
}

Console.WriteLine($"Number of devices: {nodes.Count}");

foreach (var node in nodes)
{
    Console.WriteLine(node);
}

var buffer = new byte[streamSize];

// fill initial data
for (int i = 0; i < streamSize / 2; ++i)
{
    buffer[2 * i] = (byte) (i & 0xff);
    buffer[2 * i + 1] = (byte) ((i >> 8) & 0xff);
}

wrapper.Prepare();
wrapper.Open(deviceIndex);

var pipe = wrapper.MakeOutPipe(pipeId);
pipe.IgnoreTimeout = true;
pipe.Prepare(streamSize, timeoutMs);

var report = new StatisticsReport();

while (true)
{
    var writeSize = pipe.Write(buffer);

    report.AddSize(writeSize);
}
