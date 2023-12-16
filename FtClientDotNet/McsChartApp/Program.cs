using Avalonia;
using Avalonia.Media;
using Avalonia.ReactiveUI;
using System;

namespace McsChartApp;

sealed class Program
{
    // Initialization code. Don't use any Avalonia, third-party APIs or any
    // SynchronizationContext-reliant code before AppMain is called: things aren't initialized
    // yet and stuff might break.
    [STAThread]
    public static void Main(string[] args) => BuildAvaloniaApp()
        .StartWithClassicDesktopLifetime(args);

    // Avalonia configuration, don't remove; also used by visual designer.
    public static AppBuilder BuildAvaloniaApp()
    {
        if (OperatingSystem.IsLinux())
        {
            // In Avalonia 11, there are bug with font with non english culture in Linux: 'Default font family name can't be null or empty'
            // To avoid this, set default font family.
            var options = new FontManagerOptions
            {
                DefaultFamilyName = "Noto Mono"
            };

            return AppBuilder.Configure<App>()
                .UsePlatformDetect()
                .WithInterFont()
                .LogToTrace()
                .UseReactiveUI()
                .With(options);
        }

        return AppBuilder.Configure<App>()
            .UsePlatformDetect()
            .WithInterFont()
            .LogToTrace()
            .UseReactiveUI();
    } 
}
