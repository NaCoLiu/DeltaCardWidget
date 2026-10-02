using Microsoft.Gaming.XboxGameBar;
using Windows.ApplicationModel.Activation;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;

namespace DeltaCard
{
    sealed partial class App : Application
    {
        // 必须在小组件存活期间一直持有。
        private XboxGameBarWidget _widget;

        public App()
        {
            InitializeComponent();
        }

        protected override void OnLaunched(LaunchActivatedEventArgs e)
        {
            var frame = new Frame();
            Window.Current.Content = frame;
            frame.Navigate(typeof(MainPage));
            Window.Current.Activate();
        }

        protected override void OnActivated(IActivatedEventArgs args)
        {
            var widgetArgs = args as XboxGameBarWidgetActivatedEventArgs;
            if (widgetArgs == null || !widgetArgs.IsLaunchActivation) return;

            var frame = new Frame();
            Window.Current.Content = frame;
            _widget = new XboxGameBarWidget(widgetArgs, Window.Current.CoreWindow, frame);
            frame.Navigate(typeof(MainPage));
            Window.Current.Activate();
        }
    }
}
