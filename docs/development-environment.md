# 開發環境與重現步驟

更新日期：2026-09-27。版本選定、工具可用、專案測試與裝置驗證分別記錄；工具檢查通過不代表階段閘門完成。最新結果見 [Phase 0 Closure](phase-0-closure.md)，2026-09-26 的歷史結果另行保留。

## 版本與本機盤點

| 工具 | 版本與狀態 |
|---|---|
| Flutter | 3.47.5 stable，已實際執行 `flutter --version` 確認；根目錄 `.flutter-version` 記錄 |
| Dart | Flutter 隨附 3.13.4，不獨立安裝 |
| .NET SDK | 10.0.401，已實際執行確認；`global.json` 精確鎖定且禁止 roll-forward |
| Python | 沿用選定 3.14.7，`.python-version` 記錄；本次未確認該解譯器已可執行 |
| uv | 選定 0.12.19；本次只制定策略，未安裝／執行 |
| Android | 2026-09-27 debug APK build 通過；API 36 x86_64 system image 已安裝。無連線實機與可用硬體加速，驗證專用軟體 AVD 未能開機，Android smoke test 未完成 |
| Windows | 首次加入 plugin 時遭 symlink 限制；後續讀到 Developer Mode 已啟用，locked restore、release build 與原生 smoke test 均通過 |
| iOS | 使用者選定 macOS GitHub Actions；Windows 不執行 iOS build |

2026-09-26 的 `py --list-paths` 解析至既有 Python 3.6 路徑並回報參數錯誤，不能將其視為 Python 3.14.7 可用證據；不修改既有 Python 安裝。實際驗證結果與更新狀態以 [Phase 0 Closure](phase-0-closure.md) 為準。

## 乾淨 checkout

安裝所選 Flutter 並將 `flutter`、`dart` 加入 PATH。首次下載依賴、Flutter artifacts、Android Gradle／SDK 元件需要網路；這不影響 App 執行時的離線設計。

Windows 需 Visual Studio Desktop development with C++ workload，以及 Windows Developer Mode（提供 plugin symlink 支援）。Android 需 Android Studio／SDK 與已接受 licenses。iOS 由 macOS CI 使用 Xcode 建置。

從根目錄執行：

```powershell
cd app
dart tool/check_sdk.dart
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze --no-pub
flutter test --no-pub
flutter build windows --release --no-pub
flutter build apk --debug --no-pub
```

各命令都應成功才繼續下一步。PowerShell 手動執行時請核對 exit code；不要用忽略失敗的腳本串接。SDK 不符應先回到版本決策，不自行升級或降版。

`flutter pub get --enforce-lockfile` 必須使用版控中的 `app/pubspec.lock`，CI 不自行升級依賴。依賴修改才使用一般 `flutter pub get` 更新 lockfile，並檢查 diff、formatter、analyzer、tests 及受影響平台 build。NuGet 專案開始時提交 `packages.lock.json` 並用 locked restore；目前尚無 .NET 專案。

## 啟動與原生 smoke test

```powershell
cd app
flutter run -d windows
flutter test integration_test/app_shell_test.dart -d windows --no-pub
flutter emulators
flutter devices
```

若無 AVD，先於 Android Studio Device Manager 建立虛擬裝置並啟動，或連接已開啟 USB debugging 的實體 Android。裝置出現後執行：

```powershell
flutter run -d <android-device-id>
flutter test integration_test/app_shell_test.dart -d <android-device-id> --no-pub
```

驗收：開啟後顯示 N5 空教材畫面；學習／複習／設定導覽可切換；重開後本機資料庫仍可開啟。integration test 使用與 App 相同的 Application Support 資料庫，僅驗證開啟／重開，不刪除既有資料。Phase 0 沒有教材或學習資料可供完整 Slice 回歸。

## iOS 與 CI

GitHub Actions workflow 的品質檢查通過後，才執行 Windows release、Android debug 與 iOS unsigned release 建置。iOS 命令只在 macOS 執行：

```sh
cd app
flutter pub get --enforce-lockfile
flutter build ios --release --no-codesign --no-pub
```

此編譯不代表完成裝置安裝、簽署或 App Store 發布。Flutter 模板目前保留開發 application/bundle ID；正式 ID、簽署與 iOS 原生依賴 lock（若所選整合方式產生）須在首次 macOS 驗證及發布前核對。Flutter 的 `pubspec.lock` 不等同原生依賴鎖定。

Repository 目前無 Git remote，workflow 尚未在 GitHub 執行。設定 GitHub remote 並經 Human review 推送後，需取得三平台 workflow 成功紀錄，才能關閉該項閘門。

## Python 依賴策略

採 uv 0.12.19 與單一 `python/uv.lock`，Windows／Ubuntu 用同一份 lockfile 執行 locked sync，Python 固定 3.14.7。首批套件加入時驗證兩平台，失敗先新增 Decision Record。詳見 [基礎建設決策](decisions/phase-0-foundation.md)；目前不建立 Pipeline，亦不聲稱已執行 pytest。

## Migration 與資料

資料庫位於平台 Application Support directory 的 `jlpt_learning.sqlite3`。目前 v1 只建立 migration history。未來新增 schema 時，附加連續版本 migration 與升級測試；不要改寫已發布 migration，不透過刪除資料庫解決升級失敗。

`onCreate`／`onUpgrade` 由 sqflite transaction 包裹；失敗保留前一版資料。降版與不一致 history 顯示安全的啟動錯誤，可重試，不清除資料。Content Data、User Learning State、Derived Analytics 在對應階段分開建模；Reset 需明確 scope 與 transaction，不屬於 Phase 0。

## Git

沿用 V2.3 的 `main`、`develop`、`feature/*`、`fix/*`。本次使用 `feature/phase-0-foundation`，保留既有實作與使用者治理文件。Closure 依使用者明確授權建立提交與驗證；Human review 前不將階段標示為完成。提交與 clean-checkout 結果見 [Phase 0 Closure](phase-0-closure.md)。

官方文件：[Android setup](https://docs.flutter.dev/platform-integration/android/setup)、[Windows setup](https://docs.flutter.dev/platform-integration/windows/setup)、[iOS deployment](https://docs.flutter.dev/deployment/ios)、[uv locked sync](https://docs.astral.sh/uv/concepts/projects/sync/)。
