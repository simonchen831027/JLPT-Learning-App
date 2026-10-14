# DEC-P1-S1-W1V-VG01-REVIEW-04 — VG-01 指定頁首可見證據限定接受

- Source Candidate Version：V0.1。
- Decision ID：DEC-P1-S1-W1V-VG01-REVIEW-04。
- Decision Approval：**APPROVED**。
- Developer Approval Date：2026-10-14 00:55（Asia/Taipei）。
- Approved Decision Type：Implementation / Validation Evidence Acceptance。
- Source Candidate Approval：**APPROVED WITH LIMITATIONS**。
- Document State：**APPROVED DECISION RECORD**。
- Repository Integration Evidence：以包含本文件的 Git commit 與遠端 branch 實際證據判定。
- Spec Change Required：**No**。
- Related CHAT_HANDOFF：None。
- 準備 Task：P1-S1-W1V-VG01-REVIEW04-GOVERNANCE-INTEGRATION-CANDIDATE-01。
- Repository Integration Task：P1-S1-W1V-REVIEW04-REPOSITORY-INTEGRATION-01。
- Repository path：`docs/decisions/dec-p1-s1-w1v-vg01-review-04.md`。

## Source Decision / approval identity

本紀錄忠實整理 Developer 本次提供之已核准 REVIEW-04；批准來自 Developer，
不是 02 的文件檢查或 05 自行宣告。直接來源：
`C:/Users/User/.codex/attachments/083d2656-bb3a-4019-ac04-e2bcbdd4212a/貼上的文字.txt`，
SHA-256 `035C0DC7A3820965592246EFC28B43319B5AA574E15A719BFEA48D092F72B082`，§3～§7。

本次直接 Review input 是 V0.3 Developer Handoff、Execution Report、Evidence Manifest、
Visual QA 及其原始證據。核准的 Evidence Manifest：
`local_data/ui-ux-review/s1-w1-visual/vg01-targeted-capture-01/VG01_TARGETED_EVIDENCE_MANIFEST_V0.3.json`，
SHA-256 `255497504E89B7A847637E266AA04763C9444DA5B54E0A4358C7584F26C2B72B`；
02 已重新計算一致。路徑以 repository root 為基準；local-only 證據未因被引用而升格正式文件。

## Context

Current Approved Spec 是 V2.16，CR-0013 APPLIED。§6.1 UI/UX gate、§7.4.1 global
Furigana preference、§24.9 testing、§40 DoD、§42.3 regression 及 DEC-P1-002 均維持。
S1 UI/UX V0.2 為核准的 bounded task-specific input，非 Global Design System approval。

原 Capture 有 108 PNG / 531 Manifest Entries。獨立審查指出 Lesson / Practice 的指定
頁首提示可見證據不足，VG-01 當時仍 OPEN；不等於已證實 production defect。
後續 V0.3 各新增一次 Lesson 與 Practice Native capture。本次 REVIEW-04 只接受其
列明的執行／收證／審圖與限定結案，不改產品要求或其他驗收門檻。

## Decision

### Native execution / evidence acceptance

Developer 接受當次受測 dirty working tree 上：

- Lesson Native Run 1 次、17 張原始 PNG；Practice Native Run 1 次、16 張原始 PNG；新增共 33 張。
- 兩次正常 Finish、Child Exit 0、Byte Pumps Completed；Driver-owned Temporary SQLite Fixture Cleanup。
- Native 額度 2/2 已用，剩餘 0；Automatic Native Retry 0；Source／Driver／Harness／Helper Correction 0。
- Fresh G0-A／G0-B／G0-C PASS；Lesson 完成後、Practice 前再確認程序互斥。
- 33/33 PNG 檔案完整性及 SHA-256；Command／ACK／Request／Page／Pending State identity。
- PID／HWND 關聯、Scroll／Capture／下一 Command 時序；Practice Session／Question／Selection Model identity。
- Source／Git Index／Dirty Tree／Historical Evidence Preservation。

曾有 Foreground Capture Guard Refusal；不得描述為全程零失敗。
這些是 **05 當次 Windows local working-tree evidence**，不是 Committed Clean-checkout
Validation，也不是 02 本次親自重新執行 Native 的結果。

### Visual review acceptance

三種範圍分開記錄：

| 證據 | 範圍／執行者 |
|---|---|
| 檔案與時序核對 | 33/33 |
| 原始 PNG SELF-REVIEW | 33/33；05 UI/UX Work |
| 獨立限定視覺複核 | 16/33；01 Reviewer |

01 的 16 張為 Lesson `002、006、007、008、009、010、016、017`，
Practice `002、007、011、012、013、014、015、016`。
精確檔案／hash 對應 V0.3 manifest 與 capture audit（PNG 前綴是 Command N，ACK 為 N+1）。

16/33 複核的接受依本次 Developer 明確核准文字；不把 05 原 V0.3 SELF-REVIEW
追溯改名為 Independent Visual Review，不宣稱 01 審過全部 33 張。
02 本次只檢查文件／來源 identity／一致性，沒有新增獨立視覺驗收。

### VG-01 formal disposition（已核准之決策內容）

| Finding | Approved Disposition | 限定接受內容與 V0.3 對應原圖 |
|---|---|---|
| VG-01-L01 | CLOSED — LIMITED VISIBLE EVIDENCE SCOPE | Lesson OFF Recovery 與 Failed Set 後 Old-OFF Recovery 的完整頁首；L007、L017 |
| VG-01-P01 | CLOSED — LIMITED VISIBLE EVIDENCE SCOPE | Practice ON Recovery 與 Failed Set 後 Old-ON Recovery 的完整頁首；P012、P016 |
| VG-01-P02 | CLOSED — LIMITED VISIBLE EVIDENCE SCOPE | Practice Saving Pending、Failed Set Error／Retry 指定完整頁首；P013、P014 |
| VG-01-LP03 | CLOSED — LIMITED VISIBLE EVIDENCE SCOPE | Lesson／Practice Cold、Confirmed、Failed Set Readback Pending，及 Lesson Confirmed OFF Refresh／Failure；L002、006、008、009、010、016；P002、007、011、015 |

L / P 表示 V0.3 raw root 中 Lesson / Practice 目錄。
原 `WV-X/014-lesson.png`（原稱 WV-X/014）Mounted-consumer Confirmed ON 子項的限定接受仍保留；
僅該 visible text/layout，不擴張為 initiator、focus 或 announcement 驗證。

**Closure boundary**：CLOSED 只表示本次指定頁首可見證據缺口完成限定驗收。
不代表 Full W1、Full W1-V Fidelity、S1、Phase 1、全 Accessibility Gate、
全 Production Implementation 通過，亦不代表 Repository Integration 已授權。
不得將 CLOSED — LIMITED 簡寫成無條件 PASS / COMPLETE。

## Reason

指定頁首原先缺少完整可見證據；V0.3 提供對應狀態的完整原圖與時間／identity chain，
Developer 接受 05 SELF-REVIEW 與 01 指定 16 張獨立限定複核，足以處置列明缺口。
此為既有 requirement 下的 evidence acceptance；不創造新的 requirement、不降低其他 gates。

## Accepted validation / provenance

受測 HEAD：`eb931484255a4b175cca0f7579107c42684c501d`；
branch：`feature/phase-1-core-offline-learning`；
當時 12 modified + 9 untracked，17-file S1 candidate hashes 位於 G0_IDENTITY.json。
不能只用 HEAD 識別 dirty candidate。

| 來源 | 可追溯位置／identity | 範圍 |
|---|---|---|
| Original capture | `local_data/codex-review/p1-settings-furigana-s1-w1-visual/launcher-recovery-02/t1-observer-04/`；EVIDENCE_MANIFEST.json SHA-256 `DB09D271F4DD737BB8F43C3583E1EB8C5B1F76FBB3558C7C01E30FD8015B85F9` | 108 PNG／531 entries；歷史 capture / review |
| Original independent review | `local_data/ui-ux-review/s1-w1-visual/independent-review-01/` | 原 108 PNG review；不得與新增 16/33 混算 |
| V0.3 review | `local_data/ui-ux-review/s1-w1-visual/vg01-targeted-capture-01/` | Handoff、Execution Report、Evidence Manifest、SELF-REVIEW Visual QA |
| V0.3 raw | `local_data/codex-review/p1-settings-furigana-s1-w1-visual/vg01-targeted-capture-01/v03-20261014/` | command / ACK、PNG / sidecar、G0～G4、cleanup、incident、audit |
| Raw Manifest V0.3 | RAW_EVIDENCE_MANIFEST_V0.3.json；SHA-256 `2DBDB07114EF1A81E87D7D80E6E8A12CD26A1FB148B29C1CC4425A83AB8EE446` | 169 entries；不含 manifest 自身 |
| S1 UI/UX V0.2 | `local_data/ui-ux-review/P1_SETTINGS_FURIGANA_S1_UIUX_HANDOFF_V0.2_DRAFT.md`；SHA-256 `3059C9D058A5D40914B42091D4975DB440188CB0D5BA980F4ADF424915358843` | 已核准 bounded input；原檔歷史 DRAFT 題頭不代表本次升格 Global Policy |

Native command 的完整 launcher representation 在 Lesson / Practice 的 stream-start.json。
Execution Report 記錄 Flutter observation-driver command，OBS_PAGE 分別 lesson / practice；
兩次 completion 在各自 SESSION_COMPLETION.json，exitCode=0、pumpsCompleted=true、tempExists=false，
cleanup 為 driver teardown，不是 02 本次操作 SQLite。

G0_IDENTITY.json、G0_HOST_PROCESS.json、G0_GATE.json 記錄 fresh gates；
G2_HOST_PROCESS.json／G2_FINAL_GATE.json 記錄 Practice 前再次互斥；
CAPTURE_AUDIT_V0.3.json 記錄 33 張關聯與時序；
G3_PRESERVATION.json／G4_FINAL_PRESERVATION.json 記錄 source/index/dirty/history 保全。
全部保留原始檔，不改寫其當時的 Review-pending 狀態。

Remote Git／CI 僅證明其指定 committed revision。02 當次查到同 SHA 的 Flutter CI
run 38111539082 completed / success，**不覆蓋 dirty candidate**；不將其列為 V0.3 Native
或 Full Suite／CI on Dirty Candidate PASS。02 的 hash / 文件一致性檢查亦不替代 runtime gates。

## Incident handling

### I01 — Foreground Capture Guard Refusal

Lesson Command 008 Capture 前有一次前景視窗保護拒絕，未產生合格 PNG。
Developer 接受 guard 正常阻止非前景擷取；同一 Native Run／PID／HWND、
同一 Pending State 下恢復並取得有效原圖，沒有新增 Native launch、修改 Helper
或自動重送 Command。這不計為額外 Native retry，也不表示沒有 Capture Failure。

限制：拒絕當下精確時間未保存；Reviewer 未獨立取得拒絕全過程原始工具紀錄；
OPERATOR_INCIDENTS.json 含事後整理。該 incident report 不是原始工具 log 的替代品。
成功收證時間以 Lesson/008-refresh.png.json 為準。

### I02 — Git untracked comparison

Lesson 後首次比對使用不同 untracked 顯示口徑，LESSON_PRESERVATION.json 留下
statusMatch=false；hash/index/HEAD 一致。後續使用與 G0 相同的
`--untracked-files=all`，LESSON_PRESERVATION_VERIFIED.json 為相符，
G2_FINAL_GATE.json 記錄在 Practice Native Launch 前完成確認。
接受為比較口徑差異；不是 Git 內容曾被修復或清理。首次失敗與重核理由均保留。

## Constraints / remaining validation gates

| Criterion／Gate | 保留狀態 |
|---|---|
| Q01／Q02／Q06 | 原限定 PASS 保留，非全面重驗 |
| Q03／Q04 | PASS — LIMITED VISIBLE SCOPE |
| Q05 | PARTIAL |
| Q07 | NOT VERIFIED |
| W1-V Full Fidelity | NOT COMPLETE |
| W2 Responsive | NOT VERIFIED／未完成 |
| W3 Accessibility／Screen Reader | NOT VERIFIED／未完成 |
| P01 Preference Persistence | NOT VERIFIED／未完成 |
| Mobile Android／iOS | NOT VERIFIED／未完成 |
| K03／Sound | 未完成或 Out of Scope；未提升為 PASS |
| Correct Answer Branch | NOT VERIFIED |
| Continuous Reflow | NOT VERIFIED |
| OS Keyboard／Focus | NOT VERIFIED |
| Semantics／Announcements | NOT VERIFIED |
| Selection／Copy | NOT VERIFIED |
| Responsive／Text Scaling Matrix | NOT VERIFIED |
| Full Suite／CI on Dirty Candidate | NOT RUN |
| NV-R05 Repository Integration | NOT AUTHORIZED |

Controlled Fake Preference 不構成正式 persisted AppSetting 的驗證。
原 Native Viewport 約 1266.286 × 683.429 logical px，DPR 1.75；只限該收證範圍，
不是其他 responsive 尺寸或 150／200% Text Scaling 驗證。
靜態 PNG 不能代替 OS focus、screen reader、semantics、連續 reflow 或 selection/copy。
Practice model focusRevision / selection identity 不等於 OS focus／announcement 證據。

本 Decision 不增加 Native budget；不重開已用完的 2/2，也不授權 retry、source correction、
production integration 或 NV-R05。Full suite、analyzer、build、device、CI rerun、
Vertical Slice regression 均非 02 本次工作；本次 NOT RUN。
既有 Phase gates、產品／架構／API／DB／migration／Content／Design Policy 與驗收門檻不變。

## Related decisions / integration status / Developer review boundary

Related：DEC-P1-002；CR-0013 APPLIED；V2.16 §6.1／§7.4.1／§24.9／§40／§42.3；
DEC-P1-S1-W1V-INDEPENDENT-REVIEW-01、
DEC-P1-S1-W1V-VG01-CAPTURE-01、
DEC-P1-S1-W1V-VG01-EVIDENCE-ROOT-02、
DEC-P1-S1-W1V-VG01-HOST-EXECUTOR-03。

前置四項以本 Task 及先前 05 執行授權附件共同核對：
`C:/Users/User/.codex/attachments/1c7428d4-15ab-47a9-b3bf-8d95b7c3d5a0/貼上的文字.txt`，
SHA-256 `6C8A1A87E38E3BE777FE6AAAD81B75B11236C2B6587AAECA7EFF763D258A74B6`。
此組批准適用當次 capture，不能當成 02 新 Native 執行授權。
02 候選準備時，在 docs/decisions/ 未找到這四項或 REVIEW-04 的 tracked record；本次僅整合 REVIEW-04，不補建其他 records。

REVIEW-04 原始批准文字由本次 Developer 任務提供；在已讀來源中未找到另一份獨立匯出的
01 對新增 16 張 Review 全過程紀錄。16/33 的接受以 Developer 此次明確批准為依據，
不冒稱 02 重現 01 審圖。Raw Manifest 所列檔案可存取並核對 hash；Incident I01
原始工具過程的可取得限制仍保留。忽略目錄不會隨 commit 自動傳到遠端。

本紀錄依 P1-S1-W1V-REVIEW04-REPOSITORY-INTEGRATION-01 的 Developer 明確授權進行單檔 Metadata 定稿與 Repository Integration。
Decision Approval：APPROVED；Source Candidate Approval：APPROVED WITH LIMITATIONS；Document State：APPROVED DECISION RECORD。
Repository Integration 的實際狀態以包含本文件的 Git commit 與遠端 branch 證據判定，不在正文預填 Commit SHA 或 CI 結果。
不要使用需求 CR 的 APPLIED 取代 Decision Approval 或 Repository Integration 狀態。
本紀錄不授權 Production Integration、額外 Native Run 或 NV-R05；其餘未完成 gates 保留。
