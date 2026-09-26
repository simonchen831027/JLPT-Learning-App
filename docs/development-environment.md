# 開發環境盤點與版本決策

本文件記錄 Phase 0 環境盤點與已核准的 SDK/依賴版本決策。SDK 選定不代表已安裝；本次未安裝或更新任何工具。

## 目前環境（盤點日期：2026-09-26）

| 工具 | 已知狀態 |
|---|---|
| Git | 2.55.0.windows.3 |
| .NET SDK | 10.0.401（已安裝，與 repository `global.json` 精確相符） |
| ASP.NET Core Runtime | 10.0.12 |
| Flutter | 3.47.5 stable 已選定，尚未安裝 |
| Dart | Flutter 3.47.5 隨附 3.13.4；不獨立安裝，Flutter 尚未安裝故目前無 Dart 命令 |
| Python | 3.14.7 已選定，尚未安裝；`python`、`python3` 不可用 |
| Python launcher / pip | Windows `py` launcher 存在但找不到預設 Python；`pip`、`pip3` 不可用 |

Flutter/Dart/Python 尚無可用執行環境。平台 SDK 亦未完成盤點：Android 需要 Android Studio/SDK 工具鏈；Windows 桌面建置需要 Visual Studio 的 Desktop development with C++ workload；iOS 建置需要 macOS 與 Xcode。Repository 尚無 Flutter、.NET、Python 專案或依賴設定，因此目前沒有專案建置/測試命令可執行。

## 已核准的版本決策

- **Flutter / Dart：**Flutter 3.47.5 stable；使用其隨附 Dart 3.13.4，不獨立安裝 Dart。Flutter 精確版本記錄於本文件；未來 `pubspec.yaml` 的 SDK constraint 用於相容性限制，不能取代 Flutter SDK 精確版本記錄。
- **.NET：**SDK 10.0.401。根目錄 `global.json` 精確鎖版，`rollForward` 設為 `disable`。此檔只選取 .NET SDK，不表示已建立 .NET 專案。
- **Python：**Content Pipeline 選用 Python 3.14.7。加入實際 Python 套件時需驗證相容性；若不相容，須先新增 Decision Record 才能改用其他 Python 版本。

版本選定依據：Flutter 官方 [Windows SDK release index](https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json)（3.47.5 stable / Dart 3.13.4）、Microsoft [.NET 10 SDK download](https://dotnet.microsoft.com/en-us/download/dotnet/10.0)（10.0.401）、Python.org [downloads](https://www.python.org/downloads/)（3.14.7）。版本若需變更，應更新待決策紀錄及本文件，並保留理由與日期。

## 版本記錄與依賴鎖定

- Flutter/Dart：Flutter SDK 版本及隨附 Dart 版本以本文件記錄；應用程式 `pubspec.yaml` 記錄 SDK 相容範圍。
- .NET SDK：以根目錄 `global.json` 精確選取 10.0.401 並停用 roll-forward。
- Python：以本文件記錄已選定解譯器版本；Python 專案建立時在 `pyproject.toml` 宣告支援範圍，且不得將相容範圍誤當成精確 pin。
- Flutter App 的 `pubspec.lock` 納入 Git。
- NuGet 專案開始時提交 `packages.lock.json`，restore 採 locked mode。
- Python lockfile 格式及跨平台鎖定方式尚未決定；不得在此之前加入未核准的鎖定工具或流程。

## 平台建置

- Windows 11 可用於 Android 開發/建置；需依 Flutter 官方 Android setup 準備 Android Studio、Android SDK 與所需工具及 licenses。
- Windows 11 可建置 Flutter Windows 桌面版；需 Visual Studio（不同於 VS Code）及 Desktop development with C++ workload。
- Flutter iOS 建置需要 macOS 與 Xcode。自有 Mac 或 macOS CI runner 的選擇延後決策；在選定前，不宣稱 Windows 環境可建置 iOS。

官方平台文件：[Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup)、[Flutter Windows setup](https://docs.flutter.dev/platform-integration/windows/setup)、[Flutter iOS deployment](https://docs.flutter.dev/deployment/ios)。

## Git 分支策略

目前分支為 `main`。依主要規格 §21 記錄分支名稱 `main`、`develop`、`feature/*`、`fix/*`；目前沒有建立其他分支。本文件只記錄規格既有名稱，不增訂分支保護、release 分支、命名格式或額外工作流程。
