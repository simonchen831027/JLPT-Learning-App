# Phase 0 Closure

更新日期：2026-09-27。Current Approved Spec：`JLPT_Learning_App_Technical_Spec_V2.3.md`；相關章節為 §25、§38.1–2、§38.10–11、§40、§42.3–4。相關 Implementation Decisions：Developer 提供的 `DEC-P0-001`、`DEC-P0-002`、`DEC-P0-003`、`DEC-P0-004`、`DEC-P0-005`（本次對話；repository 尚無獨立決策檔案）。

**Phase 0 Gate Status：COMPLETE；四項 §38.2 gate 已有 evidence，Developer 依 `DEC-P0-005` 完成 §40 最終 Human Review（PASS）並正式接受 Phase 0 closure。Phase 1 尚未開始。**

## 範圍與 repository 核對

本次僅收尾 Phase 0：核對既有 App Shell、SQLite migration framework、SDK／依賴策略、三平台 target、最小 CI 與驗證證據。沒有修改 application、dependency、build configuration、CI workflow、migration 或 Current Approved Spec。Phase 0 正式 schema 仍為 v1，僅有 migration history。Phase 0 前沒有可執行的產品 Vertical Slice；§42.3 的前階段回歸於此階段不適用，Shell／migration tests 是後續回歸基線。原 `SESSION_HANDOFF` 未隨本次對話提供，repository 搜尋亦未找到獨立紀錄；以下正式狀態均重新向 Git、Spec、Decision Records 與 Developer 提供的 `CODEX_DECISION` 核對。

本次核對時 Git 分支為 `feature/phase-0-foundation`、HEAD 為 `14fc11aeb43dda11d16eb2f0147b513b36895cff`（`docs: add Codex review packet workflow`），upstream `origin/feature/phase-0-foundation` 為 `1ca4db06ed161ad511a9e56feba5a9cab3b0ff08`；工作樹已有本次文件同步前的兩份未提交 Phase 0 文件修改。`origin` 指向 `https://github.com/simonchen831027/JLPT-Learning-App.git`；`main` 未合併。本次未提交、推送或合併。

`git diff --name-status 4d8f4359c710d1a90e27cc9b564fac4d3b6acb5e..79b9ff2` 只有 `M AGENTS.md`。進一步閱讀該 patch，內容為需求狀態、治理分工、`CODEX_DECISION`、驗證證據分類、Phase gate、Git 狀態與 session handoff 流程的同步；沒有 application implementation、dependency、build configuration 或 V2.3 Spec 變更。故 `DEC-P0-001` 接受的 `4d8f435` 結果仍適用於當時未變動的受測內容；**不表示 `79b9ff2` 已重新完成 committed clean-checkout validation**。後續 `1ca4db0` 已修改 SDK 檢查工具並新增其測試，該新版由本文件所列 CI run 驗證；App Shell、依賴、平台與 Spec 未因這項工具修正而變更。`DEC-P0-001` 與目前 `AGENTS.md` §7.1、§11.1、§12 不衝突。

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

## 裝置、CI 與 iOS evidence 分類

| Evidence 分類 | 執行者／環境／command | 結果與限制 |
|---|---|---|
| Historical working-tree validation（先前狀態核對） | Codex；2026-09-27；repository root；`git status --porcelain=v1 --branch`、`git rev-parse HEAD`、`git remote -v`、上述 `git diff --name-status` 及 `git diff ... -- AGENTS.md` | 當時命令 exit code 0、HEAD 為 `79b9ff2`、工作樹乾淨且無 remote，delta 只有治理文件；**不代表目前仍無 remote**，也不是 App test／build。 |
| Android device／platform validation（先前盤點） | Codex；2026-09-27；Windows Android SDK；`adb devices -l`（`C:\Users\User\AppData\Local\Android\Sdk\platform-tools\adb.exe`，在可存取 SDK 的環境） | 命令 exit code 0，當時 `List of devices attached` 下無裝置。**Smoke test BLOCKED／未執行**；無 device ID、無 App 安裝／操作結果。本次未重查裝置清單。 |
| CI validation | GitHub Actions `Phase 0 Flutter`；2026-09-27；push run `36297736172`、attempt 1，`head_sha=1ca4db06ed161ad511a9e56feba5a9cab3b0ff08` | **PASS**；run completed／success，`checks`、`windows`、`android`、`ios` 均 success。run／job 細節見下節；本次未在本機重跑 CI commands。 |
| iOS platform／CI validation | 同一 run 的 `ios` job，workflow 指定 `macos-26`，執行 `flutter build ios --release --no-codesign --no-pub` | **CI build PASS**；不等於 iOS 裝置安裝、簽署或發布驗證。Windows 本機未執行 iOS build。 |
| Historical validation | [2026-09-26 Phase 0 驗證紀錄](phase-0-validation.md)及本文件舊版的工作樹結果 | 僅證明當時版本／工作樹；本次未重跑，不能取代 `4d8f435` clean checkout、CI 或裝置證據。 |

## GitHub Actions 實際執行證據

分類：**CI validation**；執行者：GitHub Actions。已由 Codex 於 2026-09-27 讀取 GitHub Actions run／jobs API 核對 [`Phase 0 Flutter` run 36297736172](https://github.com/simonchen831027/JLPT-Learning-App/actions/runs/36297736172)：`head_branch=feature/phase-0-foundation`、`head_sha=1ca4db06ed161ad511a9e56feba5a9cab3b0ff08`、event `push`、attempt 1、status `completed`、conclusion `success`。run 建立於 2026-09-27 05:37:26 UTC，更新於 05:44:00 UTC。這是 `DEC-P0-003` 修正提交並推送後的新執行，不是舊 run 的 re-run。

| Job／workflow runner | Job ID | 實際結果與覆蓋範圍 |
|---|---:|---|
| `checks`／`ubuntu-24.04` | [108559595451](https://github.com/simonchen831027/JLPT-Learning-App/actions/runs/36297736172/job/108559595451) | **PASS**；SDK check、locked restore、format、analyze、tests 的 step 均 success。 |
| `windows`／`windows-2025` | [108559793168](https://github.com/simonchen831027/JLPT-Learning-App/actions/runs/36297736172/job/108559793168) | **PASS**；SDK check、`flutter test --no-pub`、`flutter build windows --release --no-pub` 均 success。 |
| `android`／`ubuntu-24.04` | [108559793111](https://github.com/simonchen831027/JLPT-Learning-App/actions/runs/36297736172/job/108559793111) | **PASS**；SDK check、`flutter build apk --debug --no-pub` 均 success；不含 Android 裝置 smoke。 |
| `ios`／`macos-26` | [108559793136](https://github.com/simonchen831027/JLPT-Learning-App/actions/runs/36297736172/job/108559793136) | **PASS**；SDK check、`flutter build ios --release --no-codesign --no-pub` 均 success；不含裝置、簽署或發布。 |

Job runner 平台與完整命令依 commit 中的 `.github/workflows/flutter.yml`；各 step 的 success 由 jobs API 核對。GitHub hosted runner 的實際機器名稱、完整 console logs／產物本次未下載，故不擴張為裝置或發行驗證。

目前 HEAD `14fc11a` 晚於 CI commit `1ca4db0`；`git diff --name-status 1ca4db0..14fc11a` 只有 `M AGENTS.md`（Codex Review Packet 治理規則），沒有 application、test、dependency、build configuration、workflow 或 Current Approved Spec 變更。因此上述 CI 對未變動的受測技術內容仍適用；**這不是於 `14fc11a` 重新執行 CI 的證據**。

歷史 [run 36296055262](https://github.com/simonchen831027/JLPT-Learning-App/actions/runs/36296055262) 對應 `aefc809307c7a9f90bdd2f7159af610f86f8b4a8`、attempt 1，overall **failure**：`checks`、`android`、`ios` 成功，`windows` 的 `dart tool/check_sdk.dart` step 失敗，其後 Windows test／build 被跳過。Developer 依 `DEC-P0-003` 指出 Flutter bootstrap stdout 導致 JSON 解析失敗；`1ca4db0` 修正 parser 並新增 regression tests。成功的新 run 沒有改寫舊 run 的失敗事實。

先前 closure 文件（可由 `git show 79b9ff2:docs/phase-0-closure.md` 查閱）記錄了 2026-09-27 的 **historical current working-tree validation**：`dart tool/check_sdk.dart`、`flutter pub get --enforce-lockfile`、Dart format check、`flutter analyze --no-pub`、`flutter test --no-pub`（14 tests）、Windows release build、Windows integration test（1 test）、Android debug APK build 均通過；亦記錄了 migration、UI state、隱私與 CI workflow 的 code review。該次工作的準確 HEAD／工作樹差異與各項完整 log 未在原紀錄提供，因此不把它擴張為 committed clean checkout 證據；本次也未重跑。2026-09-26 的來源副本驗證同樣只作歷史參考。

最近一次裝置盤點沒有已授權 USB debugging 的 Android 實機，亦無正常可用的硬體加速 emulator。舊軟體 AVD 曾 offline／suspended／boot failure；沒有新診斷證據，本次未重複 kill／restart／adb recovery。若補做 smoke，Developer 最小操作是連接並授權 USB debugging 的實機，或啟動可正常開機的硬體加速 AVD。裝置列入 `adb devices -l` 後，於 `app/` 執行 `flutter devices`、`flutter run -d <android-device-id>` 與 `flutter test integration_test/app_shell_test.dart -d <android-device-id> --no-pub`，記錄裝置、commit、command、exit code、結果與 log；核對 N5 空教材畫面、學習／複習／設定導覽及重開後 SQLite 可用。

Android device smoke 仍需 Developer 連接並授權 USB debugging 實機，或啟動可用的硬體加速 AVD 後補驗證；依 `DEC-P0-002`，此為 additional Device / Platform validation，不是 V2.3 §38.2 mandatory gate。

## Phase 0 gate review

`DEC-P0-002` 確認 V2.3 §38.2 的四項完成閘門；§40 的 Human review 另為 closure 必要證據。Android device smoke 與 iOS macOS build 保留為待補平台驗證，**不是 §38.2 的 mandatory gate**。

| V2.3 §38.2 完成閘門 | 目前 evidence 與判定 |
|---|---|
| 乾淨 checkout 可重現 App Shell 建置 | **PASS**；`DEC-P0-001` 接受的 `4d8f435` Developer committed clean-checkout build／tests；此外 `1ca4db0` 的 CI checkout 與 Windows、Android、iOS build 均成功。兩類 evidence 分別記錄，不宣稱在 `1ca4db0` 重跑 Developer manual validation。 |
| 版本與本機開發步驟已記錄 | **已記錄**；`docs/decisions/phase-0-foundation.md`、`docs/development-environment.md`、SDK pin 與 lockfile 策略可查。Python／uv 專案尚未建立，未聲稱其 runtime validation。 |
| CI 基本工作可執行 | **PASS**；`1ca4db0` 的 `Phase 0 Flutter` run `36297736172` completed／success，四個 job 均 success；先前 `aefc809` failed run 已保留。 |
| 待決策項目已登錄 | **已登錄**；`docs/decisions/phase-0-open-decisions.md` 可查，後續 Phase 政策未提前實作。 |

§38.2 的準備項目另已核對：V2.3 是 Current Approved Spec，`feature/*` 分支符合 §21；Flutter 三平台 target、App Shell、SQLite migration framework 與最小 CI 均已提交。§40 的既有 Git diff／Codex review 已記錄；本次 CI evidence 與 closure diff 由 Codex 核對。Developer 依 `DEC-P0-005` 確認 **最終 Phase 0 Human Review：PASS**，並正式接受 Phase 0 closure；本次文件同步仍待 Developer Review，且尚未提交。

**非 mandatory gate 的平台驗證：** Android APK build 於 `4d8f435` 的 Developer validation 與 `1ca4db0` 的 CI 均 PASS；Android device smoke 仍 **BLOCKED／未執行**。iOS `macos-26` unsigned build 已有 **CI PASS**，但 iOS 裝置安裝、簽署與發布驗證 **未執行**。依 `DEC-P0-002`，Android device smoke 與 iOS macOS build 均不另增 §38.2 mandatory gate。

**Phase 0 Gate Status：COMPLETE。** §38.2 四項完成閘門均已有可追溯 evidence；§40 的最終 Human Review／Developer 正式接受已由 `DEC-P0-005` 確認為 **PASS**。目前沒有剩餘的 Phase 0 mandatory gate blocker。Android device smoke 仍未執行，iOS CI build 不涵蓋裝置安裝、簽署或發布；這些限制不因 Phase 0 完成而消失。Phase 1 尚未開始，本次僅同步 Phase 0 closure 文件，尚未提交，等待 Developer Review。本次沒有發現需要 Specification Decision 的產品／架構歧義，因此沒有新的 `CHAT_HANDOFF`。
