# DeltaCardWidget

**English** | [简体中文](#简体中文)

An Xbox Game Bar widget for tracking your **Asala card** collection (54 cards) in *Delta Force* — click a card to mark it as collected.

## Features

- 54 cards: 4 suits × 13 ranks plus the Small and Big Joker, laid out 4 per row (Heart, Spade, Club, Diamond).
- Click a card to toggle it. Collected cards are shown in color; missing cards are 90% grayscale.
- Progress counter (`n/54`) and a Reset button.
- Progress is saved locally.
- Chinese and English UI, chosen by the Windows display language.
- Uses the [Maple Mono](https://github.com/subframe7536/maple-font) font.

## How it works

A Game Bar widget is a UWP XAML app. The app declares a `microsoft.gameBarUIExtension` in `Package.appxmanifest`, and Game Bar activates it through the `ms-gamebarwidget` protocol. See the [Xbox Game Bar SDK](https://learn.microsoft.com/gaming/game-bar/) and the [official samples](https://github.com/microsoft/XboxGameBarSamples).

## Requirements

- Windows 10 1903 (build 18362) or later, with Xbox Game Bar installed
- Visual Studio 2022 with the **Universal Windows Platform development** workload
- Windows SDK 10.0.26100 (or adjust `TargetPlatformVersion` in `DeltaCard.csproj`)
- Developer Mode turned on (Settings → Privacy & security → For developers)
- PowerShell 5.1 or later, and Internet access for the first asset download

## Build and install

```powershell
# 1. Download the artwork and generate images (not stored in this repo)
.\scripts\fetch-assets.ps1

# 2. Build, unpack and register the widget
.\scripts\install.ps1
```

Then press `Win+G`, open the widget menu and pick **Delta Force Card Collector**.

If `MSBuild.exe` is not in the default Visual Studio 2022 Community location, pass it with `-MSBuild`.

## Project layout

| Path | Description |
| --- | --- |
| `DeltaCard/App.xaml.cs` | Game Bar widget activation |
| `DeltaCard/MainPage.xaml(.cs)` | Card grid, progress and persistence |
| `DeltaCard/Package.appxmanifest` | Widget declaration, window size, Game Bar interfaces |
| `DeltaCard/Strings/` | App name and description (en-US, zh-CN) |
| `DeltaCard/Assets/Fonts/` | Subset of Maple Mono CN (OFL license included) |
| `scripts/fetch-assets.ps1` | Downloads artwork, rotates it upright and creates gray versions and app icons |
| `scripts/install.ps1` | Build and register |

## Notes

- The Game Bar SDK package is pinned to `7.2.240903001` to match the official sample.
- The card artwork and icons belong to Tencent / *Delta Force* and are not included in this repository. `fetch-assets.ps1` downloads them for personal use only.
- This is an unofficial fan project and is not affiliated with Tencent or Microsoft.
- Maple Mono is licensed under the SIL Open Font License 1.1 (see `DeltaCard/Assets/Fonts/Maple-LICENSE.txt`).

---

## 简体中文

**三角洲行动卡牌收集工具**：一个 Xbox Game Bar 小组件，用来记录《三角洲行动》**阿萨拉牌**（共 54 张）的收集进度，点击卡牌即可标记为已收集。

### 功能

- 54 张牌：4 个花色 × 13 个点数，加上小王、大王；每行 4 张（红桃、黑桃、梅花、方片）。
- 点击卡牌切换状态，已收集显示彩色，未收集显示 90% 灰度。
- 显示进度（`n/54`），带“重置”按钮。
- 进度保存在本地。
- 中英文界面，跟随 Windows 显示语言。
- 使用 [Maple Mono](https://github.com/subframe7536/maple-font) 字体。

### 原理

Game Bar 小组件本质上是 UWP XAML 应用：在 `Package.appxmanifest` 中声明 `microsoft.gameBarUIExtension`，Game Bar 通过 `ms-gamebarwidget` 协议激活应用。参见 [Xbox Game Bar SDK](https://learn.microsoft.com/gaming/game-bar/) 和[官方示例](https://github.com/microsoft/XboxGameBarSamples)。

### 环境要求

- Windows 10 1903（18362）及以上，已安装 Xbox Game Bar
- Visual Studio 2022，并安装“通用 Windows 平台开发”工作负载
- Windows SDK 10.0.26100（或修改 `DeltaCard.csproj` 里的 `TargetPlatformVersion`）
- 开启开发人员模式（设置 → 隐私和安全性 → 开发者选项）
- PowerShell 5.1 及以上，首次下载素材需要联网

### 构建与安装

```powershell
# 1. 下载图片并生成资源（仓库中不包含图片）
.\scripts\fetch-assets.ps1

# 2. 构建、解包并注册小组件
.\scripts\install.ps1
```

然后按 `Win+G`，在小组件菜单里选择“三角洲行动卡牌收集工具”。

如果 `MSBuild.exe` 不在 VS 2022 Community 的默认路径，用 `-MSBuild` 参数指定。

### 目录说明

| 路径 | 说明 |
| --- | --- |
| `DeltaCard/App.xaml.cs` | Game Bar 小组件激活 |
| `DeltaCard/MainPage.xaml(.cs)` | 卡牌网格、进度与保存 |
| `DeltaCard/Package.appxmanifest` | 小组件声明、窗口大小、Game Bar 接口 |
| `DeltaCard/Strings/` | 应用名称与描述（en-US、zh-CN） |
| `DeltaCard/Assets/Fonts/` | Maple Mono CN 子集（含 OFL 许可证） |
| `scripts/fetch-assets.ps1` | 下载图片、扶正、生成灰度图和应用图标 |
| `scripts/install.ps1` | 构建并注册 |

### 说明

- Game Bar SDK 固定为 `7.2.240903001`，与官方示例一致。
- 卡牌图片和图标版权归腾讯及《三角洲行动》所有，本仓库不包含；`fetch-assets.ps1` 仅供个人使用下载。
- 本项目为非官方的粉丝作品，与腾讯、微软无关。
- Maple Mono 使用 SIL Open Font License 1.1 许可（见 `DeltaCard/Assets/Fonts/Maple-LICENSE.txt`）。
