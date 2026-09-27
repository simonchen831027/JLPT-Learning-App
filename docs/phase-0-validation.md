# Phase 0 交付與驗證紀錄

歷史驗證日期：2026-09-26。以下保留當時工作樹與來源副本的結果，不代表後續提交版本已通過驗證。最新收尾狀態見 [Phase 0 Closure](phase-0-closure.md)。範圍限定 V2.3 §38.2；**實作已提供，Phase 0 閘門尚未全部關閉**。

## 交付範圍與變更層

| 範圍 | 檔案／層 |
|---|---|
| 三平台工程與依賴 | `app/android/`、`app/ios/`、`app/windows/`、`app/pubspec.yaml`、`app/pubspec.lock`、`.flutter-version` |
| App Shell | `app/lib/app/`、`app/lib/main.dart`；繁體中文、Material 3、手機／桌面適應式導覽 |
| Feature 分層 | `app/lib/features/home/`；View → ViewModel → Use Case → Repository，載入／空資料／安全錯誤／重試 |
| 本機 Service 與 migration | `app/lib/core/database/`；SQLite 初始化、history 驗證、連續升級、transaction rollback、拒絕降版 |
| 測試 | `app/test/`、`app/integration_test/`；unit、widget、SQLite、原生 smoke test |
| SDK 與 CI | `app/tool/check_sdk.dart`、`.github/workflows/flutter.yml`、`.python-version`；品質檢查成功才啟動三平台建置 |
| 文件／Decision Record | 根目錄與 App README、開發文件、Phase 0 基礎建設決策與待決策登錄 |
| 忽略規則 | 保留既有 `.gitignore`，補上 SQLite sidecars／簽署檔忽略及 `.flutter-version` 例外 |

`AGENTS.md` 的既存修改保留，未由本次改寫。Backend、Python Pipeline、教材、Quiz、Reset 與 Readiness 尚未建立，不列為本次完成項目。

## Migration 升級方式

全新資料庫：由 schema 0 升級至 v1，只建立 `schema_migrations(version, name)`。正常重開不重跑已套用 migration。

未來 schema：在 `appMigrations` 附加下一連續版本；`onUpgrade` 於 sqflite transaction 中執行所有待升級 SQL，成功後才保留新 history／`user_version`。失敗回滾、降版拒絕；不以刪庫或重建空資料庫處理。Content、User State、Derived Analytics 仍保留規格要求的責任分界，正式模型延至對應 Phase。

測試使用 v2／v3／失敗 v4 fixtures 驗證資料保留與跨版本回滾，fixtures 不屬於正式產品 schema。

## 實際檢查

| 命令／檢查 | 結果 |
|---|---|
| `flutter --version`、`dotnet --version` | Flutter 3.47.5／Dart 3.13.4、.NET SDK 10.0.401 符合 |
| `dart tool/check_sdk.dart` | 通過 Flutter／Dart 精確版本檢查 |
| `flutter devices`、`flutter emulators` | Windows／Chrome／Edge 可見；無 Android、無 AVD |
| `flutter pub get --enforce-lockfile` | 通過；首次一般 restore 遭 symlink 限制，Developer Mode 啟用後重跑成功 |
| `dart format --output=none --set-exit-if-changed lib test integration_test tool` | 20 個 Dart 檔，0 項格式變更 |
| `flutter analyze --no-pub` | 通過，No issues found |
| `flutter test --no-pub` | 14 個測試全通過：migration、儲存初始化、Use Case／Repository／ViewModel、手機／桌面 UI 與重試 |
| `flutter build windows --release --no-pub` | 本機成功建置 `jlpt_learning_app.exe` |
| 乾淨來源副本 locked restore + Windows release build | 通過；由 Git tracked + untracked non-ignored 來源複製 114 個檔案，不帶 `.dart_tool`／build／本機設定 |
| 副本 `flutter test integration_test/app_shell_test.dart -d windows --no-pub` | 1 個原生 smoke test 通過；實際 plugin 開啟 SQLite、導覽、關閉並重開 |
| Android debug APK build | 驗證中；首次 Gradle 下載停滯已中止，另行核對官方檔案後重試 |
| Workflow YAML／Android manifest／iOS plist 解析 | 通過；三個原生 build jobs 均依賴 checks |
| Git diff／Codex 自我 review | 已檢查自訂程式、平台設定、依賴、workflow、migration 與保留既有變更；修正 SDK pin 被忽略及 Windows 字元編碼問題 |
| 隱私／權限 | App 無 Provider Secret、AI／Cloud 網路呼叫或錄音；Release manifest 未請求麥克風／網路，Debug／Profile 保留 Flutter 開發用 INTERNET；錯誤 UI 不顯示原始 SQL 或路徑 |
| iOS build／GitHub Actions 執行 | 未執行；Windows 主機無 Xcode，repository 無 remote；workflow 已提供，待遠端驗證 |
| Android 裝置 smoke test | 未執行；尚無 AVD 或 Android 實機 |
| `dotnet test`／`pytest` | 未執行；未建立對應專案 |
| Human review | 待完成 |

Migration 測試刻意製造缺表、降版與 history 不一致，因此 sqflite 會印出測試 fixture 的預期錯誤；最終測試結果為通過。正式 App 沒有新增原始 exception／敏感資料 logging。

乾淨來源副本驗證使用同一台已準備 SDK／依賴快取的主機，能確認未依賴來源目錄的本機產物；**不等同已提交版本的全新 Git checkout 或遠端 CI 成功**。副本與下載快取位於忽略的 `local_data/`，不納入交付。

## 既有 Slice 回歸、限制與待決策

Phase 0 前沒有可執行 Vertical Slice，因此前階段回歸不適用；本次建立的 Shell／migration／原生 smoke test 是後續階段的基線。

待補驗證：正式 commit 的乾淨 checkout、GitHub Actions 三平台成功紀錄、Android 裝置操作、iOS 編譯與 Human review。正式 application/bundle ID、簽署、Phase 1 Entity ID／時區／nullable，以及後續 Knowledge／Readiness 等政策仍需按登錄表決策。Python／uv 已選策略，未安裝或執行，也未宣稱套件相容。

## Git 狀態

分支：`feature/phase-0-foundation`。未新增 commit、未推送；repository 沒有 remote。本次程式與文件為未提交變更，保留原有 `AGENTS.md` 修改與 `.gitignore` 內容。請先完成 Human review，再依既有 Conventional Commit 流程提交。
