using System;
using System.Collections.Generic;
using System.Linq;
using Windows.Storage;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Imaging;

namespace DeltaCard
{
    public sealed partial class MainPage : Page
    {
        private const string StoreKey = "CollectedNames";
        private const string ImageUrlFormat = "ms-appx:///Assets/Cards/{0}.png";
        private const string GrayImageUrlFormat = "ms-appx:///Assets/CardsGray/{0}.png";
        private readonly List<Card> _cards = new List<Card>();

        private sealed class Card
        {
            public string Name;
            public StackPanel View;
            public Image Image;
            public TextBlock Label;
            public BitmapImage Color;
            public BitmapImage Gray;
            public bool Collected;
        }

        public MainPage()
        {
            InitializeComponent();
            TitleText.Text = IsChinese ? "卡牌收集" : "Card Collection";
            ResetButton.Content = IsChinese ? "重置" : "Reset";
            BuildCards();
            Load();
            ResetButton.Click += (s, e) =>
            {
                foreach (var c in _cards) SetCollected(c, false);
                Save();
                UpdateProgress();
            };
        }

        private static bool IsChinese =>
            Windows.Globalization.ApplicationLanguages.Languages.Count > 0 &&
            Windows.Globalization.ApplicationLanguages.Languages[0].StartsWith("zh", StringComparison.OrdinalIgnoreCase);

        private void BuildCards()
        {
            // 每行 4 张：同一点数的 红桃、黑桃、梅花、方片，最后是小王、大王。
            // 文件名和保存用中文名（语言无关），显示文字按系统语言。
            var suits = new[] { "红桃", "黑桃", "梅花", "方片" };
            var suitsEn = new[] { "Heart", "Spade", "Club", "Diamond" };
            var ranks = new[] { "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" };
            var names = new List<string>();
            var displays = new List<string>();
            foreach (var rank in ranks)
                for (int k = 0; k < 4; k++)
                {
                    names.Add(suits[k] + rank);
                    displays.Add(IsChinese ? suits[k] + rank : suitsEn[k] + " " + rank);
                }
            names.Add("小王");
            displays.Add(IsChinese ? "小王" : "Small Joker");
            names.Add("大王");
            displays.Add(IsChinese ? "大王" : "Big Joker");

            for (int index = 0; index < names.Count; index++)
            {
                var name = names[index];
                var colorImage = new BitmapImage(new Uri(string.Format(ImageUrlFormat, name))) { DecodePixelWidth = 132 };
                var grayImage = new BitmapImage(new Uri(string.Format(GrayImageUrlFormat, name))) { DecodePixelWidth = 132 };
                var image = new Image
                {
                    Width = 54,
                    Height = 92,
                    Stretch = Stretch.Uniform,
                    Source = grayImage
                };

                var view = new StackPanel
                {
                    Width = 64,
                    Margin = new Thickness(0, 5, 0, 5),
                    Background = new SolidColorBrush(Windows.UI.Colors.Transparent)
                };
                var label = new TextBlock
                {
                    Text = displays[index],
                    FontSize = 12,
                    TextWrapping = TextWrapping.Wrap,
                    FontFamily = new FontFamily("ms-appx:///Assets/Fonts/MapleMono-CN-Regular.ttf#Maple Mono CN"),
                    TextAlignment = TextAlignment.Center,
                    HorizontalAlignment = HorizontalAlignment.Center
                };
                view.Children.Add(image);
                view.Children.Add(label);

                var card = new Card { Name = name, View = view, Image = image, Label = label, Color = colorImage, Gray = grayImage };
                SetCollected(card, false);
                view.Tag = card;
                view.Tapped += OnCardTapped;
                _cards.Add(card);
                CardGrid.Items.Add(view);
            }
        }

        private void OnCardTapped(object sender, TappedRoutedEventArgs e)
        {
            var card = (Card)((StackPanel)sender).Tag;
            SetCollected(card, !card.Collected);
            Save();
            UpdateProgress();
        }

        private static void SetCollected(Card card, bool collected)
        {
            card.Collected = collected;
            card.Image.Source = collected ? card.Color : card.Gray;
            card.Label.Foreground = new SolidColorBrush(collected
                ? Windows.UI.Colors.White
                : Windows.UI.Color.FromArgb(255, 150, 150, 150));
        }

        private void UpdateProgress()
        {
            ProgressText.Text = _cards.Count(c => c.Collected) + "/" + _cards.Count;
        }

        private void Save()
        {
            ApplicationData.Current.LocalSettings.Values[StoreKey] =
                string.Join(",", _cards.Where(c => c.Collected).Select(c => c.Name));
        }

        private void Load()
        {
            var s = ApplicationData.Current.LocalSettings.Values[StoreKey] as string;
            if (!string.IsNullOrEmpty(s))
            {
                var collected = new HashSet<string>(s.Split(','));
                foreach (var c in _cards) SetCollected(c, collected.Contains(c.Name));
            }
            UpdateProgress();
        }
    }
}
