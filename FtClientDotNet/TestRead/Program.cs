using Hglee.Device.Ftd3xx;

const uint deviceIndex = 0;
const byte pipeId = 0x82;
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

wrapper.Prepare();
wrapper.Open(deviceIndex);

var pipe = wrapper.MakeInPipe(pipeId);
pipe.DoNotRaiseTimeoutException = true;
pipe.Prepare(streamSize, timeoutMs);

var report = new StatisticsReport();

while (true)
{
    var readSize = pipe.Read(buffer);

    report.AddSize(readSize);
}