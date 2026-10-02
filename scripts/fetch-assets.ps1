<#
.SYNOPSIS
  Downloads the Asala card artwork and generates the images used by the widget.
  下载阿萨拉牌图片并生成小组件使用的图片资源。

.DESCRIPTION
  The artwork is owned by Tencent and is NOT stored in this repository.
  图片版权归腾讯所有，不包含在本仓库中。
  Output / 输出:
    DeltaCard\Assets\Cards       color cards, rotated upright / 彩色牌面（已扶正）
    DeltaCard\Assets\CardsGray   90% grayscale cards / 90% 灰度牌面
    DeltaCard\Assets\*.png       app icons (card box) / 应用图标（牌盒）
    DeltaCard\GameBar\icon.png   widget icon / 小组件图标
#>
param(
    [float]$TiltDegrees = 24.4,   # measured lean of the source art / 原图实测倾角
    [string]$Root                 # target folder (project or unpacked package) / 目标目录（项目或已解包的安装包）
)

$ErrorActionPreference = 'Stop'
if ($Root) {
    $root = Resolve-Path $Root
    $src = Join-Path ([IO.Path]::GetTempPath()) 'DeltaCardSource'
}
else {
    $root = Join-Path $PSScriptRoot '..\DeltaCard' | Resolve-Path
    $src = Join-Path $root 'SourceImages'
}
$cards = Join-Path $root 'Assets\Cards'
$gray = Join-Path $root 'Assets\CardsGray'
$iconSrc = Join-Path $src 'icon'
New-Item -ItemType Directory -Force $src, $cards, $gray, $iconSrc, (Join-Path $root 'GameBar') | Out-Null

# Card names are built from code points so the script is encoding-independent.
$suits = @(
    ([string][char]0x7ea2 + [char]0x6843),   # hearts   红桃
    ([string][char]0x9ed1 + [char]0x6843),   # spades   黑桃
    ([string][char]0x6885 + [char]0x82b1),   # clubs    梅花
    ([string][char]0x65b9 + [char]0x7247)    # diamonds 方片
)
$ranks = 'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
$smallJoker = [string][char]0x5c0f + [char]0x738b   # 小王
$bigJoker = [string][char]0x5927 + [char]0x738b     # 大王

# Image ids: 1..52 ordered rank-major then suit (spade, heart, club, diamond); 53 small joker, 54 big joker; 55 box.
# 图片编号：1..52 按点数、再按 黑桃/红桃/梅花/方片 排列；53 小王；54 大王；55 牌盒。
$suitOrder = @(1, 0, 2, 3)   # file order in $suits -> id order
$map = @{}
for ($r = 0; $r -lt 13; $r++) {
    for ($s = 0; $s -lt 4; $s++) {
        $id = 1 + $r * 4 + $suitOrder[$s]
        $map[$id] = $suits[$s] + $ranks[$r]
    }
}
$map[53] = $smallJoker
$map[54] = $bigJoker

$baseUrl = 'https://playerhub.df.qq.com/playerhub/60004/object/152095000{0:D2}.png'

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;

public static class AssetGen
{
    const int Canvas = 280;

    static Rectangle AlphaBounds(Bitmap b, int threshold)
    {
        int minX = b.Width, minY = b.Height, maxX = 0, maxY = 0;
        for (int y = 0; y < b.Height; y++)
            for (int x = 0; x < b.Width; x++)
                if (b.GetPixel(x, y).A > threshold)
                {
                    if (x < minX) minX = x; if (x > maxX) maxX = x;
                    if (y < minY) minY = y; if (y > maxY) maxY = y;
                }
        return new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
    }

    // Resize to 180px wide, rotate upright, crop to a common rectangle, write color + 90% gray.
    public static string Cards(string srcDir, string colorDir, string grayDir, float tilt)
    {
        var rotated = new Dictionary<string, Bitmap>();
        int minX = Canvas, minY = Canvas, maxX = 0, maxY = 0;
        foreach (var f in Directory.GetFiles(srcDir, "*.png"))
        {
            using (var img = new Bitmap(f))
            {
                var bmp = new Bitmap(Canvas, Canvas, PixelFormat.Format32bppArgb);
                using (var g = Graphics.FromImage(bmp))
                {
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = SmoothingMode.HighQuality;
                    float scale = 180f / img.Width;
                    g.TranslateTransform(Canvas / 2f, Canvas / 2f);
                    g.RotateTransform(-tilt);
                    g.DrawImage(img, -img.Width * scale / 2f, -img.Height * scale / 2f, img.Width * scale, img.Height * scale);
                }
                rotated[Path.GetFileName(f)] = bmp;
                var r = AlphaBounds(bmp, 8);
                minX = Math.Min(minX, r.Left); minY = Math.Min(minY, r.Top);
                maxX = Math.Max(maxX, r.Right - 1); maxY = Math.Max(maxY, r.Bottom - 1);
            }
        }
        var rect = new Rectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
        foreach (var kv in rotated)
        {
            using (var color = kv.Value.Clone(rect, PixelFormat.Format32bppArgb))
            using (var gray = new Bitmap(rect.Width, rect.Height, PixelFormat.Format32bppArgb))
            {
                for (int y = 0; y < rect.Height; y++)
                    for (int x = 0; x < rect.Width; x++)
                    {
                        var c = color.GetPixel(x, y);
                        double l = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B;
                        Func<int, int> mix = v => (int)Math.Round(l * 0.9 + v * 0.1);
                        gray.SetPixel(x, y, Color.FromArgb(c.A, mix(c.R), mix(c.G), mix(c.B)));
                    }
                color.Save(Path.Combine(colorDir, kv.Key), ImageFormat.Png);
                gray.Save(Path.Combine(grayDir, kv.Key), ImageFormat.Png);
            }
            kv.Value.Dispose();
        }
        return rect.Width + "x" + rect.Height;
    }

    static void SaveIcon(Bitmap box, string path, int w, int h, double fill)
    {
        using (var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb))
        using (var g = Graphics.FromImage(bmp))
        {
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.SmoothingMode = SmoothingMode.HighQuality;
            double s = Math.Min(w * fill / box.Width, h * fill / box.Height);
            int dw = (int)Math.Round(box.Width * s), dh = (int)Math.Round(box.Height * s);
            g.DrawImage(box, (w - dw) / 2, (h - dh) / 2, dw, dh);
            bmp.Save(path, ImageFormat.Png);
        }
    }

    public static void Icons(string boxFile, string root)
    {
        using (var raw = new Bitmap(boxFile))
        using (var box = raw.Clone(AlphaBounds(raw, 16), PixelFormat.Format32bppArgb))
        {
            SaveIcon(box, Path.Combine(root, "Assets", "StoreLogo.png"), 50, 50, 0.92);
            SaveIcon(box, Path.Combine(root, "Assets", "Square44x44Logo.png"), 44, 44, 0.92);
            SaveIcon(box, Path.Combine(root, "Assets", "Square150x150Logo.png"), 150, 150, 0.85);
            SaveIcon(box, Path.Combine(root, "Assets", "SplashScreen.png"), 620, 300, 0.8);
            SaveIcon(box, Path.Combine(root, "GameBar", "icon.png"), 100, 100, 0.9);
        }
    }
}
'@

foreach ($id in $map.Keys) {
    Invoke-WebRequest ($baseUrl -f $id) -OutFile (Join-Path $src ($map[$id] + '.png')) -UseBasicParsing
}
Invoke-WebRequest ($baseUrl -f 55) -OutFile (Join-Path $iconSrc 'box.png') -UseBasicParsing

$size = [AssetGen]::Cards($src, $cards, $gray, $TiltDegrees)
[AssetGen]::Icons((Join-Path $iconSrc 'box.png'), [string]$root)
Write-Host "Done. Card size $size / 完成，牌面尺寸 $size"


