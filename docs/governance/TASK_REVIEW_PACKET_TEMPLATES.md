# Task／Review Packet Templates

Applicability: 生效依 Root §0 完整 Bundle 條件及 Developer 對本 revision／全文的精確批准、正式整合、適用驗證與最終 Acceptance 判定；候選產出、Source Write 或 Review PASS 均不單獨使其生效。
Governance Revision: AGENTS-THINROOT-V270-R01
正式目的地：docs/governance/TASK_REVIEW_PACKET_TEMPLATES.md。

## T0. 權威／適用

本檔是Root §0登錄同revision的第4層AGENTS附錄，不因docs/路徑升權；須同Bundle精確Developer Approval、正式integration與明確生效revision。缺件／identity不符／Read Scope不足，STOP相依操作，不用摘要猜補。以下Task14欄及Review19欄連同起訖逐字移自正式AGENTS；CHAT_HANDOFF、CODEX_DECISION也保留原格式。原程序／例外在D相應章，不能只讀模板跳過批准、Source、Scope、Budget、STOP或Runtime Gate。

固定Task Slot：local_data/codex-task/CURRENT_TASK.md；Review Slot：local_data/codex-review/CODEX_REVIEW_PACKET.md。先確認gitignore；不得commit。並行／明准Workspace Inbox／Outbox仍依Root／D §13同格式例外，不建立第二報告系統、不自回填。正式啟用pointer時T1仍完整存在解析後Canonical TASK，T2完整存在批准Outbox RESULT；不把指標當完整任務。

## T1. CODEX_TASK_PACKET — 14 欄

```text
# CODEX_TASK_PACKET

Generated For:
Codex

Task:
...

Phase:
...

Execution Profile:
- Environment:
- Preferred Model:
- Reasoning:
- Approval:
- Escalation:

Related Decision:
...

Current Approved Spec:
...

Objective:
...

Context:
...

Required Work:
...

Constraints:
...

Must Not Change:
...

Validation:
...

Expected Review Output:
local_data/codex-review/CODEX_REVIEW_PACKET.md

Developer Approval State:
...

# END_CODEX_TASK_PACKET
```

### T1.1 重大Task／Binding資料落點（不改14欄）

Task欄記ID／Version／Attempt／唯一Sender／Target／Host／Owner／ActualTargetTurn（實際取得後，未分配不能猜）。Context／RelatedDecision記原始humanApproval Thread／Turn／Message及完整原文、適用Delegation／SourceCheckpoint／正式AGENTS／Spec／Decision／CR與canonicalPath／rawBytes／Expected及ObservedHash。Objective／RequiredWork記完整成果／DoD與依賴；Constraints記Read／Write／Tool／Artifact Scope、精確allowlist、Budget（Trigger／Observation／Artifact／Repair等分列）、Dependencies／ParallelGate／Writer與Reader／Runner／Native協調、STOP／UNKNOWN；MustNotChange保護項目；Validation記command／Evidence／Gate／ReviewOwner／DeveloperAcceptance；ExpectedReviewOutput記唯一實際位置，DeveloperApprovalState記批准有效性／模式與未授權事項。短小Task例外保持，不將未填欄位當批准。

以下為可選補充欄位，可置於上述 Validation 之後；不改既有必填結構與固定
Task Slot。簡單 Task 不要求填寫，不適用可省略或填 None。未填不新增 Minor
Repair 授權，亦不收回 §3.1 原 Task 已包含的 implementation authority。

| 可選欄位 | 應描述的範圍 |
|---|---|
| Allowed Minor Repairs | 是否獲 Developer 預先核准；精確 File Allowlist、Diagnostic Categories、禁止修改項目、修正／重驗證預算及 STOP / Escalation 條件（§3.6） |
| Validation Gates | 適用檢查、成功條件、執行順序與 Conditional Execution Gate；後續操作的獨立授權及失敗／阻擋時行為，不以修正授權代替 Native / Git / 資料操作授權 |
| Evidence Reuse | 已接受 evidence 的 identity / path / hash 或 commit / run、command / result、環境、接受來源與範圍，以及必須重驗證的觸發條件（§12.1–12.2） |
| Parallel Coordination | 僅在並行或共享資源時適用；列明 Task Owner、worktree／branch、Source Writer、checkpoint／Read Lease（需要時）、修改範圍、Task／Review／Evidence 位置、Git Integration Owner 與 Native 共用資源協調（§3.7）；欄位本身不授權任何操作 |

修正／重驗證預算由 Developer 依 Task 明確核准，本文件不設定通用次數或
無限重試預設。Evidence Reuse 沿用 §12，不因填寫此欄位而自動接受新證據、
豁免 Spec gate，或把 CI / build PASS 當成 device / platform validation 完成。

**逐 Child 批准與執行（批次指引）**

- 在既有 Task Packet／Authorization 欄位逐 Child 記錄 Task／Version／Attempt、原始人類批准定位、唯一 Sender／Target Thread／Host／Owner、canonical Packet 路徑及 raw bytes／SHA-256、Source Checkpoint、依賴與 Parallel Gate、Read／Write／Tool／Artifact Scope、Budget、STOP／UNKNOWN 處置及 Review／Acceptance Owner。
- 同一份 Developer Batch Approval 可逐 Child 明准指定 Sender → Target 的 Delegated Activation。發訊前逐一核對原始批准、唯一有效入口／Attempt、完整 Packet 身分、Source、依賴、資源及當次平台權限。未明准委派時依原批准採人工模式。必要依賴或 Gate 未成立時，暫停該 Child。
- 每個 Child 在首次啟動前依原始批准選定唯一模式。只有在尚未提出任何發訊呼叫、委派工具已確認不可用，且原批准明列互斥的人工啟動條件時，才可由 Developer 在指定 Target 採該人工路徑。
- Direct Trigger 一經提出即計入額度，每個 Attempt 至多一次。呼叫遭拒絕、逾時或送達／執行狀態為 UNKNOWN 時，依原 STOP 處理，只在核准額度內唯讀查核原 Target。維持原模式與已用額度，停止重送、改派及切換人工路徑。額度耗盡即停止相依操作。
- 資源協調由實際 Owner 提供當次確認，記錄 checkout、各共用資源的實際 Owner、SDK／cache、Runner、協調窗口及釋放責任。程序觀察只作補充證據。必要 Owner 或協調狀態未確認時，停止使用受影響資源。
- 替代診斷、恢復、Minor Repair 與補驗須有精確批准，逐項界定觸發條件、工具、Scope、額度及 STOP。依既有 §3.6、§3.7、§13.2 及原批准執行，保留原 STOP 與實耗。


## T2. CODEX_REVIEW_PACKET — 19 欄

```text
# CODEX_REVIEW_PACKET

Generated For:
Developer / JLPT App｜01 需求・架構決策

Task:
...

Phase:
...

Related Decision:
CODEX_DECISION / CHANGE_REQUEST / None

Current Approved Spec:
...

Repository State:
- Branch:
- HEAD:
- Upstream:
- Working Tree:

Objective:
...

Implementation Summary:
...

Changed Files:
- path

Requirement / Decision Coverage:
...

Diff Review:
本 task 實際修改的 patch / diff。

Validation Evidence:
對每項實際執行的 validation 記錄：
- Evidence type
- Command / CI Run
- Result
- Commit / Working Tree
- Environment
- Relevant limitation

CI Evidence:
- Workflow:
- Run ID / URL:
- Commit:
- Jobs / Results:
- 若未執行則寫 Not Run

Known Limitations:
...

Pending Decisions:
...

Phase Gate Impact:
...

Git Status:
...

Recommended Next Action:
...

Developer Review Requested:
Yes

# END_CODEX_REVIEW_PACKET
```

Review沿D§13.1九項產生規則及§12 Evidence；Scope／Migration／Regression／Tests映射既有欄。Task/RelatedDecision記原批准、Attempt、ActualTargetTurn；RepositoryState記source及dirty；Coverage／DiffReview記實際變更與例外；KnownLimitations／PendingDecisions／PhaseGateImpact記STOP；Validation記實際預算與資源狀態。Final前依Root§13.1核Expected／ActualTask／Deliverable，不以模板填齊冒充完成。

## T3. CHAT_HANDOFF

```text
# CHAT_HANDOFF

## Context

說明目前正在執行什麼功能、Phase、Task。

## Current Spec

列出：

- Current Approved Spec 版本；
- 相關章節；
- 相關 Decision Record（若有）。

## Problem

精確描述發現的問題。

避免只寫：

「Spec 不清楚。」

必須說明「哪裡不清楚」以及「為什麼會阻止安全實作」。

## Why Codex Stopped

指出觸發哪一項 STOP Condition。

## Current Implementation

說明目前相關：

- Code；
- Architecture；
- Data Model；
- API；
- Tests；

的實際狀態。

只列與問題相關的內容。

## Conflict or Ambiguity

說明：

- Spec 要求；
- Existing Implementation；
- Current Task；

之間的衝突或缺口。

## Options

列出技術上合理的方案。

每個方案至少說明：

- Product behavior impact
- Implementation impact
- Architecture impact
- API impact
- Database / Data impact
- Compatibility impact
- Migration impact
- Testing impact
- Risk

不得替 Developer 做最終產品決策。

## Codex Technical Recommendation

Codex 可以提供技術建議與理由。

必須明確標示：

> 此為技術建議，不代表產品決策，需 Developer 核准。

## Decision Required

列出 Developer 必須回答的具體問題。

問題應盡可能能直接交給 ChatGPT 的「需求・架構決策」對話分析，而不要求
ChatGPT 猜測 repository 狀態。

## Blocked Work

列出目前因該決策而停止的工作。

## Safe Work Remaining

列出不受影響且可以安全繼續的工作。

若沒有：

`None`

# END_CHAT_HANDOFF
```

## T4. CODEX_DECISION

```text
# CODEX_DECISION

Decision ID:
DEC-XXXX

Related CHAT_HANDOFF:
若無正式 CHAT_HANDOFF，填 None。

Decision:
...

Reason:
...

Spec Change Required:
No

Constraints:
...

Validation:
...

# END_CODEX_DECISION
```

## T5. SESSION_HANDOFF

在長任務的可安全中斷點、切換 session 前或需要交接時，建立 session checkpoint；
以 `SESSION_HANDOFF` 記錄可讓下一 session 核對的事實。至少包含：

- Task、Phase、Current Approved Spec 與相關正式文件；
- repository / 工作目錄、實際 branch、HEAD、未提交修改及需保留的工作；
- 已完成項目、尚未完成項目與 Phase gate 狀態；
- CR 狀態、已核准 `CODEX_DECISION`、未解決 `CHAT_HANDOFF`；
- validation evidence 分類、command/result、適用版本、未執行與不需重跑的理由；
- 仍在執行的 process、log／產物位置、已嘗試的診斷及結果；
- 下一步安全工作、blocked work 與需要 Developer 決定的事項。

交接內容以 `# SESSION_HANDOFF` 開始、`# END_SESSION_HANDOFF` 結束；可在
交付訊息或專案交接文件保存，不含 secrets 或不必要的敏感資料。
Checkpoint 不要求為交接而自動 commit、切換 branch 或清除工作樹。

接手時重新核對 Git 與相關正式文件，不把 checkpoint 當成正式需求、批准或新的
驗證結果。`SESSION_HANDOFF` 用於延續工作，不能取代處理未決產品／架構問題的
`CHAT_HANDOFF`，也不能解除 STOP Condition。

---

補記原Activation／ActualTargetTurn／TaskVersion／Attempt／canonical入口／PacketHash／Scope／已用及剩餘Budget／STOP，以恢復同一Binding；不新增第二份批准、不把checkpoint變新Task，不重置額度。
