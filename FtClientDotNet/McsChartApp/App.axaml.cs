namespace McsChartApp;

using System;
using System.Linq;
using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using Models;
using ViewModels;
using Views;

public partial class App : Application
{
    /// <summary>
    /// Main model
    /// </summary>
    private IMainModel? model;

    /// <summary>
    /// Main view model
    /// </summary>
    private MainWindowViewModel? viewModel;

    /// <inheritdoc />
    public override void Initialize()
    {
        AvaloniaXamlLoader.Load(this);
    }

    /// <inheritdoc />
    public override void OnFrameworkInitializationCompleted()
    {
        if (this.ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
        {
            desktop.ShutdownRequested += this.DesktopOnShutdownRequested;

            this.model = this.MakeModel();

            this.viewModel = new MainWindowViewModel
            {
                Model = this.model
            };

            desktop.MainWindow = new MainWindow
            {
                DataContext = this.viewModel
            };
        }

        base.OnFrameworkInitializationCompleted();
    }

    /// <summary>
    /// Makes model.
    /// </summary>
    /// <returns>Returns created model.</returns>
    private IMainModel MakeModel()
    {
        var isDummy = System.Environment.GetCommandLineArgs()
            .Any(x => string.Equals(x, "Dummy", StringComparison.OrdinalIgnoreCase));

        if (isDummy)
        {
            return new DummyMainModel();
        }

        return new MainModel();
    }

    /// <summary>
    /// Shutdown requested handler.
    /// </summary>
    /// <param name="sender">Sender object.</param>
    /// <param name="e">Event arguments.</param>
    private void DesktopOnShutdownRequested(object? sender, ShutdownRequestedEventArgs e)
    {
        if (sender is IClassicDesktopStyleApplicationLifetime desktop)
        {
            desktop.ShutdownRequested -= this.DesktopOnShutdownRequested;
        }

        this.viewModel?.Dispose();
        this.viewModel = null;

        this.model?.Dispose();
        this.model = null;
    }
}