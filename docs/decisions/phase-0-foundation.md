# Phase 0 基礎建設決策

- 日期：2026-09-26
- 版本：`phase0-foundation-v1`
- 依據：V2.3 §2、§4–7、§25、§38.2、§38.10、§42.1。
- 授權：使用者要求接續 Phase 0，並選擇 iOS 採 macOS CI、本次評估選定 Python 鎖定策略。以下工程實作選擇供本次 Human review。

## 專案與平台

Flutter App 位於 `app/`，建立 Windows、Android、iOS targets；Web 不在 MVP。使用 Flutter 3.47.5 官方模板產生平台工程，保留 `.metadata`。正式 application/bundle ID 與簽署憑證尚未決定，先保留 `com.example` 開發識別；發布前必須另作決策。Android 僅建置 debug APK，iOS CI 執行未簽署編譯，不部署商店。

App Shell 使用 Flutter 內建 `ChangeNotifier`、constructor injection、Material 3 與繁體中文 localizations，避免為 Phase 0 引入額外狀態管理或 routing framework。窄畫面採 `NavigationBar`，寬度 720 logical pixels 以上採 `NavigationRail`；此為可調整 UI layout 常數，不是學習政策。

Android 保留模板選用的 Gradle 9.3.1，改用不含原始碼／文件的 binary distribution 以減少首次下載量；wrapper 記錄官方 SHA-256 checksum 與下載 timeout，SDK／Gradle 版本不變。Checksum 來源：[Gradle 官方檔案](https://services.gradle.org/distributions/gradle-9.3.1-bin.zip.sha256)。

本機 Flutter 產生的 wrapper JAR manifest 為 2.10，因此改為納入 Git 的官方 9.3.1 wrapper JAR 與啟動腳本，讓 checksum／timeout 設定有對應實作。JAR 已比對[官方 wrapper checksum](https://services.gradle.org/distributions/gradle-9.3.1-wrapper.jar.sha256)，值另存 `gradle-wrapper.jar.sha256`，Android CI 於執行 wrapper 前核對；腳本來自 [Gradle v9.3.1](https://github.com/gradle/gradle/tree/v9.3.1)，保留 Apache-2.0 標頭。`.gitattributes` 固定腳本換行，CI 另設定 POSIX 執行權限。

依賴方向：View → ViewModel → InitializeApp → StartupRepository → LocalStore → SQLite。Shell 僅負責啟動、本機儲存就緒及空狀態；不提供假課程、假進度或 Readiness 結論。

## SQLite 與 migration

Android／iOS 使用 `sqflite`；Windows 與資料庫測試使用 `sqflite_common_ffi`。兩者共用相同 SQL migration 與 Repository abstraction。[套件文件](https://pub.dev/packages/sqflite)及 [FFI 文件](https://pub.dev/packages/sqflite_common_ffi)說明平台支援與 transaction；實際解析版本記錄於 `app/pubspec.lock`。

資料庫位於 `path_provider` 的 Application Support directory，檔名 `jlpt_learning.sqlite3`。Phase 0 的 v1 只建立 `schema_migrations(version, name)`，不建立教材、使用者狀態或衍生分析表；三類資料的實際 schema 與 Reset scope 於對應 Phase 實作。

- Migration 從 1 開始連續遞增；已發布 SQL 不可修改，只可附加新版本。
- SQLite `user_version` 是 schema 版本，與未來 `contentVersion`、Assessment／scoring／policy 版本分離。
- `onCreate`、`onUpgrade` 使用 sqflite 已提供的 transaction；整個升級失敗時回滾 DDL、資料、history、`user_version`。
- 每次開啟啟用 foreign keys、檢查 migration history；不接受降版或不一致 history，不自動刪除／重建資料庫。
- v1 → v2／v3 的升級、資料保留、失敗回滾使用測試專用 fixtures；這些不是正式 Phase 1 schema。
- Migration history 沒有時間／使用者 ID，避免提前固化產品時間與 identity 政策。實際 ID、時區、nullable 規則保持待決策。

## SDK、CI 與依賴鎖定

Flutter 精確版本以根目錄 `.flutter-version` 記錄；`app/tool/check_sdk.dart` 核對 Flutter 與隨附 Dart，CI 也執行此檢查。`pubspec.yaml` 僅表達相容範圍，`pubspec.lock` 固定實際依賴；乾淨 checkout 與 CI 使用 `flutter pub get --enforce-lockfile`。

GitHub Actions 使用 Ubuntu 執行 formatter/analyzer/tests，成功後才建置 Windows、Android、iOS。Windows 也重跑資料庫及 widget tests。Runner 指定 `ubuntu-24.04`、`windows-2025`、`macos-26`；runner image 仍可能更新，首次遠端執行需確認可用工具版本。iOS 採 macOS CI 是使用者本次選定，不需要本機 Mac；簽署與裝置執行仍待發布前處理。[Flutter Action 文件](https://github.com/subosito/flutter-action)及 [runner 清單](https://github.com/actions/runner-images)為建置參考。

## Python 鎖定策略

選用 uv **0.12.19**，Python 沿用 **3.14.7**，以根目錄 `.python-version` 固定解譯器。此決策只訂策略；本次不建立 Content Pipeline、不安裝工具、不產生沒有依賴的假 lockfile。

Python 專案出現時：

1. 在 `python/pyproject.toml` 宣告 Python 相容範圍與直接依賴；uv 工具版本固定為本決策版本，變更需更新紀錄。
2. 使用 `uv lock --python 3.14.7` 產生並提交 `python/uv.lock`，採單一跨平台 lockfile，保留平台 markers。
3. Windows 開發與 Ubuntu CI 使用相同檔案，執行 `uv lock --check`、`uv sync --locked --python 3.14.7`；測試以 `uv run --locked pytest` 執行。鎖定失效直接失敗，不在 CI 自動更新。
4. 首次加入套件時，在 Windows 與 Ubuntu 驗證安裝和測試；若存在平台 wheel／Python 3.14 相容問題，先新增 Decision Record，不自行降版。Python 若新增其他執行平台，同步擴充驗證矩陣。
5. 依賴升級需明確產生 lockfile diff，再執行兩平台測試。NuGet 仍沿用既有 `packages.lock.json` + locked restore 策略。

依據：[uv 0.12.19 release](https://github.com/astral-sh/uv/releases/tag/0.12.19)、[跨平台 lockfile](https://docs.astral.sh/uv/concepts/projects/layout/)、[locked sync](https://docs.astral.sh/uv/concepts/projects/sync/)。選定工具不代表已驗證未來套件的相容性。
