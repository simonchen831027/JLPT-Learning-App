# Phase 0 Closure

驗證日期：2026-09-27。Current Approved Spec：V2.3；依據 §2、§4–7、§21–25、§38.2、§38.10–11、§40、§42.1、§42.4 與根目錄 `AGENTS.md`。

**狀態：進行中，Phase 0 尚未 Complete；不得開始 Phase 1 implementation。**

## Scope 與歷史結果

本次驗證既有三平台 App Shell、啟動分層、SQLite migration framework、測試、SDK 鎖定與最小 CI。沒有新增教材、Quiz、Reset、Backend、Python Pipeline 或任何學習政策。正式 schema 維持 v1，只含 migration history；沒有新增 migration。

[2026-09-26 驗證紀錄](phase-0-validation.md) 屬歷史工作樹／來源副本結果，不作為本次工作樹、committed clean checkout 或 CI 通過的替代證據。

## Current working tree 驗證

| 檢查 | 結果 |
|---|---|
| `dart tool/check_sdk.dart` | 通過：Flutter 3.47.5／Dart 3.13.4 |
| `dotnet --version` | 10.0.401，符合 `global.json`；未建立 Backend，不代表 .NET build/test 通過 |
| `flutter pub get --enforce-lockfile` | 通過，未升級 dependencies |
| `dart format --output=none --set-exit-if-changed lib test integration_test tool` | 通過，20 個檔案、0 項變更 |
| `flutter analyze --no-pub` | 通過，No issues found |
| `flutter test --no-pub` | 14 個 tests 通過：11 個 unit/database tests、3 個 widget tests |
| `flutter build windows --release --no-pub` | 通過，實際完成本次 build |
| `flutter test integration_test/app_shell_test.dart -d windows --no-pub` | 通過，1 個原生 smoke test：SQLite 開啟、設定導覽、關閉及重開 |
| `flutter build apk --debug --no-pub` | 通過，Gradle task 耗時 1111.9 秒；產出本次 `app-debug.apk` |
| APK metadata | `aapt dump badging` 確認開發 package `com.example.jlpt_learning_app`、min SDK 24、target/compile SDK 36，包含 arm64-v8a／armeabi-v7a／x86_64 |
| Android smoke test | 未執行完成；本機無連線實機，軟體 AVD 未能開機，已停止重試 |
| `dotnet test`／`pytest` | 未執行，對應專案尚未建立 |

Migration tests 的缺表、降版及不一致 history 錯誤為預期的失敗 fixtures；最終 test suite exit code 為 0。Phase 0 前無既有產品 Vertical Slice，前階段回歸不適用；Shell 與 migration tests 作為後續回歸基線。

## Code review

已逐項核對 Spec、AGENTS.md、自訂 Dart 程式、全部測試、平台設定、workflow、依賴與待提交路徑：

- View 只透過 ViewModel／Use Case 啟動；平台與 SQLite 存取留在儲存層，constructor injection 分界一致。
- Loading／Empty／Error／重試已有 widget tests；空畫面沒有假教材或有效 Readiness 結論。
- Migration history 連續性與版本檢查、foreign keys、升級資料保留、跨版本失敗回滾與拒絕降版已有測試。另讀取已鎖定 `sqflite_common` 實作，確認 `onCreate`／`onUpgrade` 與 `user_version` 在同一 transaction 中。
- v2／v3／失敗 v4 僅為測試 fixture，不屬正式產品 schema；未提前固化 ID、時區、nullable 或學習政策。
- App 沒有 AI／Cloud 呼叫、Provider Secret 或錄音功能；Android main manifest 與 iOS plist 沒有新增麥克風要求。Debug/Profile 的 INTERNET 為 Flutter 開發用途。
- CI 三平台 jobs 均 `needs: checks`，formatter／analyzer／tests 失敗不會繼續原生 build；iOS 保留 unsigned build。
- Git diff whitespace 檢查通過。待提交路徑沒有 build、SDK cache、local_data、資料庫、簽署檔或 local.properties；常見憑證格式掃描未命中。此掃描不等同完整安全稽核。
- SDK／Gradle／dependency version 與來源維持原設定，未藉網路問題更換版本或 repository。

目前未發現需要修改產品 Requirement、Architecture／API Contract 或資料語意的問題。`AGENTS.md` 內「目前使用 main」與工作分支不同；實際使用的 `feature/phase-0-foundation` 符合 §21，依 Git 狀態回報，保留使用者原有治理文件內容。

**Human review 尚無完成紀錄。使用者授權本次 closure／commit，不等同已完成對最終 diff 的 Human review。**

## 工具與網路診斷

- 首次 SDK 檢查在沙箱子程序停滯，中止該次後在允許存取 SDK cache 的環境執行成功；不是 App test failure。
- 舊 Gradle 下載程序明確因連線逾時退出後，才以較長逾時續傳原有分段；沒有清除既有 cache。完整 9.3.1 binary distribution 已通過 Repository 指定的 SHA-256，並供本次 Android build 使用。
- 下載／build 無輸出時檢查程序、CPU、I/O、cache 與網路活動，未啟動重複 build。
- 本機已安裝 Android API 36 x86_64 system image，但沒有可用硬體加速驅動；專用 AVD 放在忽略的 `local_data/`，以 `-no-window -accel off -gpu software` 嘗試驗證，不更動 Windows 加速設定。
- 第一個 AVD 程序啟動後 95 個執行緒全為 Suspended，CPU／I/O／日誌停止變化；核對程序身分後結束。改由持續執行的父程序承載同一 AVD，程序仍以 exit code 1 退出，未取得可用裝置；沒有足夠證據確定第二次退出的底層原因，停止進一步重試。需可正常開機的硬體加速 AVD 或已授權 USB debugging 的實機才能補驗證。
- Android build 自動補齊既有 Gradle 設定需要的 SDK Platform 35／CMake 3.22.1；未變更專案宣告版本。出現 SDK XML 版本警告，但該次 build 最終成功，未將警告推定為失敗。

## Commit 與 committed clean checkout

尚未建立本次提交及其 clean-checkout 驗證結果。不得以既有 `.exe`、歷史 test 結果或 `local_data/phase0-clean-source` 取代。

## CI／iOS

未執行。本機為 Windows；Repository 尚未設定 Git remote，已向使用者索取目標 GitHub repository。沒有 workflow run ID／URL，不宣稱遠端成功或失敗。

## Phase 0 gate

| §38.2／DoD 項目 | 狀態 |
|---|---|
| 三平台 target、App Shell、migration framework、最小 CI 已建立 | 已確認工作樹內容 |
| SDK／依賴策略與本機步驟有文件 | 已確認；Python／uv 為策略，未執行其專案驗證 |
| 待決策項目登錄 | 已確認，後續政策仍按適用 Phase 決策 |
| 提交版本的乾淨 checkout 可重現建置 | 待驗證 |
| CI 基本工作實際可執行 | 待遠端驗證 |
| Android build／裝置 smoke、iOS build | 尚未全部完成 |
| Code review | 已執行，未發現產品／架構層級阻塞 |
| Human review | 待完成 |

以上未完成項目關閉前，Phase 0 維持 **Incomplete**。本次沒有觸發 Specification Decision；網路或裝置環境限制本身不產生 CHAT_HANDOFF。
