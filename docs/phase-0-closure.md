# Phase 0 Closure

更新日期：2026-09-27。Current Approved Spec：`JLPT_Learning_App_Technical_Spec_V2.3.md`；相關章節為 §25、§38.1–2、§38.10–11、§40、§42.3–4。正式決策：Developer 提供的 `DEC-P0-001` 與 `DEC-P0-002`（本次對話；repository 尚無兩項決策的獨立檔案）。

**Phase 0 Gate Status：BLOCKED。Phase 1 must not start.**

## 範圍與 repository 核對

本次僅收尾 Phase 0：核對既有 App Shell、SQLite migration framework、SDK／依賴策略、三平台 target、最小 CI 與驗證證據。沒有修改 application、dependency、build configuration、CI workflow、migration 或 Current Approved Spec。Phase 0 正式 schema 仍為 v1，僅有 migration history。Phase 0 前沒有可執行的產品 Vertical Slice；§42.3 的前階段回歸於此階段不適用，Shell／migration tests 是後續回歸基線。原 `SESSION_HANDOFF` 未隨本次對話提供，repository 搜尋亦未找到獨立紀錄；以下正式狀態均重新向 Git、Spec、Decision Records 與 Developer 提供的 `CODEX_DECISION` 核對。

開始核對時 Git 分支為 `feature/phase-0-foundation`、HEAD 為 `79b9ff201dc071e7fcf5df070c1e73540aa7c42b`（`docs: align repository governance workflow`）、工作樹乾淨、`git remote -v` 無輸出。本文件更新後須以交付時的 `git status` 回報未提交文件修改。

`git diff --name-status 4d8f4359c710d1a90e27cc9b564fac4d3b6acb5e..79b9ff2` 只有 `M AGENTS.md`。進一步閱讀該 patch，內容為需求狀態、治理分工、`CODEX_DECISION`、驗證證據分類、Phase gate、Git 狀態與 session handoff 流程的同步；沒有 application implementation、dependency、build configuration 或 V2.3 Spec 變更。故 `DEC-P0-001` 接受的 `4d8f435` 結果仍適用於未變動的受測程式與設定；**不表示 `79b9ff2` 已重新完成 committed clean-checkout validation**。`DEC-P0-001` 與目前 `AGENTS.md` §7.1、§11.1、§12 不衝突。

## 已接受的 committed clean-checkout evidence

分類：**Developer manual validation + committed clean-checkout validation**。執行者：Developer。適用 commit：`4d8f4359c710d1a90e27cc9b564fac4d3b6acb5e`；Developer 說明在獨立 clean checkout 執行。Developer 執行日期、checkout 完整路徑與 command 工作目錄、平台／SDK 細節、逐項 exit code 與 log 位置未提供，均記為未知；以下 PASS 結果與接受範圍來自 `DEC-P0-001`，本次未重跑。

| Developer 執行的 command | `DEC-P0-001` 接受結果 | 覆蓋範圍 |
|---|---|---|
| `flutter pub get` | PASS；`pubspec.lock` 無變動 | 依賴 restore |
| `dart format --output=none --set-exit-if-changed .` | PASS；20 files, 0 changed | Dart 格式 |
| `flutter analyze` | PASS；No issues found | 靜態分析 |
| `flutter test` | PASS；14 tests passed | unit／widget／database |
| `flutter build windows --release` | PASS | Windows release build |
| `flutter build apk --debug` | PASS | Android APK build；不等於裝置 smoke |
| `flutter test integration_test/app_shell_test.dart -d windows` | PASS；1 integration test passed | Windows 原生 Shell／SQLite smoke |

驗證期間三個 `windows/flutter/generated_*` 檔曾顯示 modified；Developer 核對 `git diff`、`git diff --ignore-space-at-eol`、`git diff --numstat` 均無 patch，`git diff --exit-code` 為 0，index／working tree EOL 均為 LF，`core.autocrlf=true` 且沒有額外 `.gitattributes` 規則。`DEC-P0-001` 將其視為 Windows Git／Flutter generated-file working-tree／EOL normalization artifact，不是語意或依賴漂移。沒有因此修改正式設定。

## 本次裝置、CI 與 iOS 盤點

| Evidence 分類 | 執行者／環境／command | 結果與限制 |
|---|---|---|
| Current working-tree validation（只讀狀態核對） | Codex；2026-09-27；repository root；`git status --porcelain=v1 --branch`、`git rev-parse HEAD`、`git remote -v`、上述 `git diff --name-status` 及 `git diff ... -- AGENTS.md` | 命令 exit code 0；核對前工作樹乾淨、無 remote，delta 只有治理文件。這不是重新跑 App test／build。 |
| Android device／platform validation | Codex；2026-09-27；Windows Android SDK；`adb devices -l`（`C:\Users\User\AppData\Local\Android\Sdk\platform-tools\adb.exe`，在可存取 SDK 的環境） | 命令 exit code 0，`List of devices attached` 下無裝置。**Smoke test BLOCKED／未執行**；無 device ID、無 App 安裝／操作結果。沙箱內同命令曾因無權建立 `\.android` 而失敗，已由可存取 SDK 的環境重查。 |
| CI validation | `.github/workflows/flutter.yml` 定義 `checks`、`windows`、`android`、`ios` jobs；repository 無 remote | **BLOCKED／未執行**；沒有 GitHub Actions run ID、URL、job result。workflow 存在不等於 CI PASS。 |
| iOS device／platform validation | 既有正式方式為 `macos-26` GitHub Actions runner 執行 `flutter build ios --release --no-codesign --no-pub`；本機是 Windows | **BLOCKED／未執行**；沒有 macOS run、Xcode build 或 iOS device result。unsigned build 也不涵蓋簽署、安裝或發布。 |
| Historical validation | [2026-09-26 Phase 0 驗證紀錄](phase-0-validation.md)及本文件舊版的工作樹結果 | 僅證明當時版本／工作樹；本次未重跑，不能取代 `4d8f435` clean checkout、CI 或裝置證據。 |

先前 closure 文件（可由 `git show 79b9ff2:docs/phase-0-closure.md` 查閱）記錄了 2026-09-27 的 **historical current working-tree validation**：`dart tool/check_sdk.dart`、`flutter pub get --enforce-lockfile`、Dart format check、`flutter analyze --no-pub`、`flutter test --no-pub`（14 tests）、Windows release build、Windows integration test（1 test）、Android debug APK build 均通過；亦記錄了 migration、UI state、隱私與 CI workflow 的 code review。該次工作的準確 HEAD／工作樹差異與各項完整 log 未在原紀錄提供，因此不把它擴張為 committed clean checkout 證據；本次也未重跑。2026-09-26 的來源副本驗證同樣只作歷史參考。

目前無已授權 USB debugging 的 Android 實機，亦無正常可用的硬體加速 emulator。舊軟體 AVD 曾 offline／suspended／boot failure；沒有新診斷證據，未重複 kill／restart／adb recovery。Developer 最小操作：連接並授權 USB debugging 的實機，或啟動可正常開機的硬體加速 AVD。裝置列入 `adb devices -l` 後，於 `app/` 執行 `flutter devices`、`flutter run -d <android-device-id>` 與 `flutter test integration_test/app_shell_test.dart -d <android-device-id> --no-pub`，記錄裝置、commit、command、exit code、結果與 log；核對 N5 空教材畫面、學習／複習／設定導覽及重開後 SQLite 可用。

GitHub Actions 需 Developer 提供正式 GitHub repository URL 與設定 remote／推送／執行 Actions 的授權。取得後先核對 remote 指向，推送待 review 的分支，取得基本 workflow 的實際 run evidence 並判讀各 job 結果；若須 GitHub 登入或 Actions permission，仍需 Developer 處理。iOS 依既定 `macos-26` job 補驗證；Windows 本機結果不能替代。

## Phase 0 gate review

`DEC-P0-002` 確認 V2.3 §38.2 的四項完成閘門；§40 的 Human review 另為 closure 必要證據。Android device smoke 與 iOS macOS build 保留為待補平台驗證，**不是 §38.2 的 mandatory gate**。

| V2.3 §38.2 完成閘門 | 目前 evidence 與判定 |
|---|---|
| 乾淨 checkout 可重現 App Shell 建置 | **PASS，適用 `4d8f435`**；`DEC-P0-001` 接受的 Developer committed clean-checkout build／tests。治理 delta 未改受測內容，沒有聲稱於 `79b9ff2` 重跑。 |
| 版本與本機開發步驟已記錄 | **已記錄**；`docs/decisions/phase-0-foundation.md`、`docs/development-environment.md`、SDK pin 與 lockfile 策略可查。Python／uv 專案尚未建立，未聲稱其 runtime validation。 |
| CI 基本工作可執行 | **BLOCKED／尚無實際執行證據**；workflow 已建立，但 repository 無 remote，也沒有 GitHub Actions run／job result。 |
| 待決策項目已登錄 | **已登錄**；`docs/decisions/phase-0-open-decisions.md` 可查，後續 Phase 政策未提前實作。 |

§38.2 的準備項目另已核對：V2.3 是 Current Approved Spec，`feature/*` 分支符合 §21；Flutter 三平台 target、App Shell、SQLite migration framework 與最小 CI 均已在 `4d8f435` 提交，`79b9ff2` 僅變更 `AGENTS.md`。§40 的 Git diff／Codex review 已執行；Developer 已 review 治理 commit，但最終 Phase 0 closure 的 Human review／批准尚無紀錄，仍待完成。

**非 mandatory gate 的待補驗證：** Android APK build 已於 `4d8f435` 通過，Android device smoke 仍 **BLOCKED／未執行**；iOS macOS build 仍 **BLOCKED／未執行**。兩者都是已知限制，缺少結果不得宣稱平台驗證 PASS，也不單獨使 §38.2 gate 失敗。

**Gate Status：BLOCKED。** §38.2 的 CI 基本工作缺實際執行證據，§40 的最終 Human review 尚待完成。Phase 1 must not start. 本次沒有發現需要 Specification Decision 的產品／架構歧義，因此沒有新的 `CHAT_HANDOFF`。
