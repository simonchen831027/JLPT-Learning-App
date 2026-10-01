# Repository Guidelines

## Language

- 使用繁體中文回覆與撰寫說明文件。
- 程式碼識別字、API 名稱、檔案名稱與必要的技術術語保留原文。
- Codex 的實作報告、問題回報、`CHAT_HANDOFF` 與 Decision Record 原則上使用繁體中文。

---

# 1. Source of Truth 與規格治理

## 1.1 Current Approved Spec

本 repository 的正式產品需求，以目前經 Developer 核准並存放於 repository 的
**Current Approved Spec** 為最高產品規格依據。

目前開發 Baseline：

`JLPT_Learning_App_Technical_Spec_V2.7.md`

V2.7 是目前的 Current Approved Spec；CR-0004 已 APPLIED；V2.6、V2.5、V2.4、V2.3
保留為被取代的歷史 Spec。
版本未來可以經正式 Change Request 流程升級為後續版本。

一旦新版 Spec：

1. 已經由 Developer 核准；
2. 已正式放入 repository；
3. 已明確指定取代前一版；
4. 對應 Change Request 已正式成為 `APPLIED`。

則新版 Spec 成為新的 Current Approved Spec。

Codex 不得因 AGENTS.md 曾記載 V2.7，而忽略 repository 中後續正式核准的新版本。

---

## 1.2 權威順序

若資訊互相衝突，依以下順序判定：

1. Current Approved Repository Spec
2. Approved Change Request
3. 正式 Project Documents / Architecture Documents / Decision Records
4. `AGENTS.md`
5. Existing Code / Tests
6. Current Task Packet / Current Chat / Work / Codex Task Context
7. Previous Session / Conversation
8. ChatGPT Memory

經 Developer 核准並正式進入 Repository 的 UI/UX Guideline、Design System、
Visual Style Guide、Content Governance Document 或其他專門治理文件，
屬於本項的正式 Project Document。

未經 Developer 核准、尚未正式進入 Repository 的 Draft、Proposal、Work output、
Screenshot Discussion、Benchmark Report 或 Local Handoff 不屬於本項。

此順序用於判定正式專案需求與狀態；Approved Change Request 的排序不代表
可在 Spec 更新前依新版需求實作。需求套用狀態依 §1.4 判定。

ChatGPT Memory、過去 Chat 討論、過去 Work 輸出、舊 Spec 草稿，以及 Codex
歷史 session 均不得覆蓋 Current Approved Spec。

若 Developer 當前指令與 Current Approved Spec 存在產品需求或架構層級衝突，
Codex 不得直接執行衝突部分，必須依本文件的 Escalation Protocol 回報。

---

## 1.3 Spec 與 Code 的關係

Spec 定義：

> 產品應該如何運作。

Code 定義：

> 目前實際實作狀態。

若 Code 與 Current Approved Spec 不一致，不得為了配合既有 Code 而自行修改
Spec，也不得直接假設 Spec 已過時。

必須判斷：

- 是否為單純 implementation bug；
- 是否為尚未完成的 Spec requirement；
- 是否涉及產品或架構決策。

若需要產品或架構決策，進入 STOP / CHAT_HANDOFF 流程。

---

## 1.4 Requirement / Change 狀態

正式需求變更遵循：

`DRAFT → APPROVED → APPLIED`

- `DRAFT`：尚在 Chat / Product Decision 流程討論中的 Requirement / Change Proposal。
  不得視為正式 Requirement，不得據此 implementation。
- `APPROVED`：Developer 已明確確認方案，並產生正式 `CHANGE_REQUEST`，
  Status 為 `APPROVED`。Spec 維護 Work 可依其修改 Candidate Spec，
  但 Codex 尚不得依新版 Requirement implementation。
- `APPLIED`：Candidate Spec 經 Developer Review / Approve，正式進入 Repository
  並成為新的 Current Approved Spec。

不得建立「`CHANGE_REQUEST: DRAFT`」作為必要正式 artifact。

Work 完成或產生 Candidate Spec 不等於 `APPLIED`。未 `APPLIED` 的 Change Request
不得讓 Codex 依新版需求 implementation；仍可進行不受影響的既有 Spec 工作。
若 CR 與 Current Approved Spec 有未解決衝突，不得自行以 CR 覆蓋現行規格。

此狀態流程用於需求變更；不改變 Spec 的 Implementation Decision 依 §7.1
處理。Developer 明確授權的純治理文件維護，不因此取得產品需求或實作修改權限。

---

## 1.5 Cross-Workspace Grounding Rule

本規則適用於：

- Chat / Product Decision；
- Spec 維護 Work；
- Content / Research Chat 或 Work；
- Visual Design / Image Work；
- UI/UX Review / Design System Work；
- Codex；
- 其他未來接入本 Repository 的 Agent / Work。

任何 Workspace、Conversation 或 Session 的歷史內容，都不是正式專案狀態本身。

開始新的重要 Task、恢復長時間未使用的對話、切換 Session、進行 Developer Review、
建立正式 handoff、產生 Candidate 文件，或對 Repository 狀態作實質判斷前，
應重新 grounding 至目前可取得的正式來源。

最低應確認：

1. Current Approved Spec；
2. `AGENTS.md`；
3. 與目前 Task 直接相關的正式 Decision Record / Project Document；
4. 適用的 Approved Change Request / `CODEX_DECISION`；
5. 若可存取 Repository：
   - current branch；
   - HEAD；
   - upstream；
   - working tree；
   - 相關 tracked files 的實際內容；
6. 本次 Task 的直接 input / handoff artifact。

不得因：

- 對話開頭曾提供某項資訊；
- Previous Session 曾記錄某狀態；
- ChatGPT Memory 記得某結論；
- Work 曾產生某份 Draft；
- 舊 Task / Review Packet 仍存在；

就推定該資訊目前仍然有效。

若歷史對話、Memory、舊 Work 輸出或 Session 摘要
與 Repository 正式來源不一致：

依 §1.2 權威順序重新判定。

若正式來源無法取得或不足以安全判斷：

不得自行補完、猜測或用舊對話代替；
須明確標示 limitation，並將需要正式決策的部分交回 Developer / 01。

對話長度、建立時間或 Session age
不改變任何來源的正式權威。

---

# 2. 主要產品規格

Current Approved Spec 是本 repository 的主要產品規格。

需求、階段順序、產品範圍、架構限制與驗收如有疑義，以 Current Approved Spec
為準。

在適用階段開始前，依規格建立必要的 Decision Record。

不得：

- 猜測未決產品政策；
- 將未決政策硬編碼；
- 將討論中的需求視為正式需求；
- 因實作方便自行擴大產品範圍；
- 因既有程式碼限制自行降低 Spec 要求。

---

# 3. Codex 職責與決策邊界

## 3.1 Codex 可以自行處理

當 Current Approved Spec 已清楚定義產品行為，而且不改變正式 Contract 時，
Codex 可以自行進行 implementation-level decision。

例如：

- private helper function 設計；
- local variable / private method 命名；
- 等價演算法選擇；
- internal refactoring；
- test organization；
- mock / fixture 組織；
- Spec 已定義行為下的 error handling 實作；
- 不改變外部行為的程式結構改善。

這類問題不需要停止開發。

---

## 3.2 Codex 不具有的權限

Codex 不得自行決定：

- 新產品需求；
- 使用者可觀察到但 Spec 未定義的產品行為；
- 正式 API Contract 變更；
- Database semantic / data lifecycle policy；
- Architecture boundary 變更；
- Privacy / retention policy；
- Readiness policy；
- AI Agent 的產品權限；
- Migration policy；
- Compatibility policy；
- Spec scope expansion；
- Spec requirement removal。

Codex 可以提出技術建議，但最終產品與架構決策由 Developer 決定。

---

## 3.3 Chat / Work / Developer / Repository / Codex 分工

| 角色 | 職責 |
|---|---|
| `01 需求・架構決策` | Product / Requirement / Architecture / Governance Decision；Developer Review 的主要分析入口 |
| `02 Spec 維護・Work` | 正式 Spec、治理文件、Decision / Change integration；只精確寫入已核准內容 |
| `03 教材研究・編寫` | Content research、Canonical Knowledge、original authoring、source tracking、Author QA、Content Candidate / handoff；不得自行發布正式 Content |
| `04 教材視覺設計・圖片生成` | 教材視覺規劃、visual asset proposal、圖片生成與 QA；不得自行授權 production integration |
| `05 UI/UX Review・Design System` | UI/UX Audit、Benchmark、Design System、Design Token、Component / Responsive / Accessibility 規則、implementation handoff / fidelity review |
| `06 教材校對・品質審查` | Independent Content QA / Editorial Review；Japanese / zh-TW / learner-facing / pedagogical / question / explanation / reading consistency QA；不得自行發布正式 Content 或改變 Curriculum / Product policy |
| Developer | 最終批准 Requirement、Decision、Content release、Design policy、Visual integration 與文件 |
| Repository | 正式專案狀態；保存 Current Approved Spec、正式文件、code、tests 與 approved tracked artifacts |
| Codex | Production Implementation / Test / Validation / Repository Review；不得自行創造 Product / Architecture / Content / Design policy |

01～06 的對話名稱是目前工作分工，不改變 §1.2 的正式權威順序。

Chat / Work 只是執行介面／工作模式，不改變 logical Workspace 的 authority。
03 Chat 與 03 Work 均屬同一 logical role「03 教材研究・編寫」：

- 03 Chat 適合快速教材討論、單點分析、研究討論、Developer interaction 與 task scoping。
- 03 Work 適合 multi-file research、batch authoring、Content Candidate、source tracking、
  revision package 與 Content handoff。

03 Work 不因為是 Work 而比 03 Chat 擁有更高治理權限。

任何 Work / Chat 的輸出，若尚未經 Developer 核准並進入正式 Repository，
原則上只具有 Draft / Proposal / READY FOR DEVELOPER REVIEW 狀態，
不得因其出自 Work 而自動升格為正式 Requirement、Design Policy、Content Release、
Architecture Decision 或 Production Authorization。

Spec 維護 Work 即使可以存取 Repository，除非有 Developer 明確授權，仍不得
修改 application implementation、test implementation、CI implementation、
Backend 或 Python implementation。文件維護授權不隱含任何上述實作授權。

治理文件不得新增、刪除或改變產品 Requirement、Architecture / API Contract、
Database Semantic、Data Lifecycle、Migration、Compatibility、Privacy / Security
或產品範圍；若需要這類變更，依正式 Specification Decision 流程處理。

---

## 3.4 Specialized Work Artifact Status

02～06 所產生的文件、proposal、mockup、asset、audit、guideline 或 handoff，
不得只因檔案存在或 Work 已完成，就視為正式 Project state。

預設 lifecycle：

Work output
→ DRAFT / PROPOSAL
→ READY FOR DEVELOPER REVIEW
→ Developer Approval
→ Repository Integration
→ Formal / Approved Artifact

只有在：

1. Developer 明確核准；
2. 適用時完成必要 Change / Decision lifecycle；
3. 正式 artifact 已進入 Repository；
4. Repository 中能識別其 Approved / Current 狀態；

之後，才能把該 artifact 當成後續 Task 的正式依據。

例如：

- Approved UI/UX Guideline；
- Approved Design System；
- Approved Visual Style Guide；
- Approved Content Package；
- Approved Architecture Document。

若已正式進入 Repository，可依 §1.2 第 3 項
「正式 Project Documents / Architecture Documents / Decision Records」
作為正式依據。

以下仍不是正式 Source of Truth：

- 未核准 Work draft；
- screenshot discussion；
- Chat recommendation；
- Design proposal；
- image candidate；
- benchmark report；
- local-only handoff；
- 過往 Session summary。

Task-specific approved input 例外：

經 Developer 明確核准，且由當前 Task Packet、CODEX_DECISION、
Developer instruction 或其他可識別的當前 task authorization
精確指定之 artifact，可以作為該次 Task 的 task-specific input，
即使該 artifact 尚位於 local-only handoff 或尚未成為正式 Repository Project Document。

此例外只授權該 artifact 在明確 scope 內作為輸入，不提升其正式權威。

該 artifact：

- 仍不是 Source of Truth；
- 仍不屬於 §1.2 第 3 項正式 Project Document；
- 不得覆蓋 Current Approved Spec、Approved Change Request、
  Decision Record 或 AGENTS.md；
- 不因被使用而自動取得 Content Release、Production Integration、
  Design Policy、Spec APPLIED 或其他未明確授權狀態；
- 應在可行時記錄實際 path / version / hash / approval scope，
  以避免誤用舊 handoff。

此機制允許 staged workflow，例如：

- Developer-approved Content Package
  → Codex production integration；
- Developer-approved Visual Candidate
  → 後續獨立 Visual Integration Task；
- Developer-approved UI/UX handoff
  → Codex implementation；

而不把 handoff artifact 本身提升為正式 Project Source of Truth。

04 的圖片 / Visual approval
不自動等於 Production Integration Authorization。

05 的 UI/UX recommendation
不自動等於 Codex Implementation Authorization。

03 的 Content recommendation
不自動等於 Content Publication / Release Authorization。

02 的 Candidate Spec
不自動等於 Current Approved Spec。

---

## 3.5 Workspace Awareness / Cross-Workspace Handoff

各 Workspace 應確認其他 Workspace 的存在、責任與交接邊界，但不得因另一
Workspace 有輸出，就推定該輸出已核准或目前有效；grounding 依 §1.5。

| 工作類型 | 交接角色 |
|---|---|
| Product / Requirement / Architecture / Governance Decision | 01 |
| Approved Spec / Decision / governance integration | 02 |
| Content research / authoring | 03 |
| Visual | 04 |
| UI/UX / Design System / fidelity | 05 |
| Independent Content QA / Editorial Review | 06 |
| Production implementation / tests / validation | Codex |
| Final approval / release / integration authorization | Developer |

單一 Task 涉及多 Workspace 時應拆分 responsibility，不得由單一 Workspace
越權替另一 Workspace 做正式決策。

Cross-workspace artifact 依 §3.4 分類與使用：

1. Formal Repository Artifact：依 §1.2 authority order 使用。
2. Developer-approved task-specific input：只在明確 task scope 內使用，不提升正式權威；
   保留 §3.4 的 task-specific approved input 例外及其限制。
3. Draft / Proposal / Screenshot / Review / historical artifact：可作 research / review /
   defect discovery input，不得當成正式 Requirement / Design / Content / Production authorization。

另一 Workspace 的「最新 Draft」不得自動視為 current approved input。

教材分工與 Independent QA 依
[DEC-P1-009](docs/decisions/dec-p1-009-independent-content-qa-editorial-review-workflow.md)。
03 在交 06 前仍須做 Author QA；06 負責獨立審查，不取代 03 authoring 或 Developer approval。
新建立或實質修訂的 learner-facing Content 原則上於 Developer Content Review 前經 06 QA；
適用範圍、targeted QA 例外與既有 Approved Content 的處理依該 Decision Record。

典型 Content flow：

```text
03 Content Work
→ CONTENT CANDIDATE
→ 06 Independent QA

REQUEST REVISION
→ 03 revision
→ 06 re-review（必要時）

PASS
→ READY FOR DEVELOPER REVIEW
→ Developer Content Approval
→ separate Production Integration Authorization（適用時）
→ Codex integration
→ validation
→ Repository formal state
```

06 可回報 PASS、REQUEST REVISION 或 BLOCKED / DECISION REQUIRED；涉及
Curriculum / Product / Requirement 的決策交 01 / Developer，author revision 交 03。
06 PASS 不等於 Content APPROVED、Content RELEASED 或 Codex integration authorization；
03 Content Candidate 也不等於 Content APPROVED / RELEASED。
Developer 保持最終 Content Approval / Release authority。

---

# 4. STOP Conditions

遇到以下任一情況時，Codex 必須停止「受影響部分」的實作：

1. Current Approved Spec 描述不明確。

2. Spec 內存在互相衝突的需求。

3. Developer 要求與 Current Approved Spec 發生產品需求或架構層級衝突。

4. 實作需要修改 Spec 未明確授權的 public API / Contract。

5. 實作需要新增或改變 Spec 未定義的 database schema semantic、
   data ownership 或 data lifecycle policy。

6. 實作需要改變既有 module / architecture boundary。

7. 存在多個合理方案，而且選擇會實質影響：
   - 未來 Architecture；
   - Product Behavior；
   - Compatibility；
   - Data Model；
   - Security / Privacy；
   - 長期維護成本。

8. 實作可能破壞既有功能或 backward compatibility，而 Spec 未明確授權。

9. Existing Code 與 Current Approved Spec 不一致，且無法單純判定為 implementation bug。

10. 完成需求所需的產品行為並未定義於 Spec。

11. Codex 判斷必須修改 Spec 才能安全繼續。

12. Previous Codex Session / Conversation 與 Current Approved Spec 發生衝突。

13. 需求涉及尚未建立但 Spec 要求先建立的 Decision Record。

14. 實作會超出 Current Approved Spec 所定義的 Phase 或產品範圍。

15. 要依尚未 `APPLIED` 的 Change Request 實作新版需求。

16. 目前 Phase gate 尚未完成，卻要求開始下一 Phase implementation。

---

# 5. STOP 發生後的行為

遇到 STOP Condition 時，Codex：

## MUST

- 停止受影響部分；
- 保留目前安全的工作狀態；
- 清楚說明問題；
- 產生 `CHAT_HANDOFF`；
- 等待 Developer 決策。

## MUST NOT

- 猜測 Developer 想要的產品行為；
- 靜默選擇新的產品政策；
- 自行修改正式 Spec；
- 為了讓 Code 能運作而改寫 Requirement；
- 自行擴大 Scope；
- 把 Codex 自己的 recommendation 當成 approval；
- 把 Previous Session 當成正式授權；
- 在尚未取得決策前完成 blocked implementation。

不受該問題影響且能明確證明彼此獨立的工作，可以繼續。

---

# 6. CHAT_HANDOFF Protocol

當 STOP Condition 發生時，Codex 必須產生以下格式。

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

產生 `CHAT_HANDOFF` 後，不得繼續 blocked work，直到取得 Developer 決策。

---

# 7. Escalation 回復流程

Developer 會將 `CHAT_HANDOFF` 帶到需求／架構討論流程。

可能得到兩種結果。

## 7.1 Implementation Decision

如果確認：

- Current Approved Spec 本身已足夠；
- 不改變產品行為；
- 不改變正式 Architecture / API / Data Contract；
- 不需要修改 Spec；

流程：

`Implementation Decision → CODEX_DECISION → Codex Resume`

Developer 以 `CODEX_DECISION` 明確記錄 implementation decision，使用以下固定正式格式：

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

若接受 validation evidence，在 `Validation` 中列出證據來源、適用版本／工作樹、
command/result 與接受範圍（依 §12）。

Codex 的建議或自行撰寫的紀錄不等於 Developer 核准。
`CODEX_DECISION` 不得取代需要 Specification Decision 的 CHANGE_REQUEST，也不得豁免 Spec gate。
§3.1 的一般 implementation-level decision 不需要逐項升級為 `CODEX_DECISION`。

Codex 收到明確決策後：

1. 確認決策不與 Current Approved Spec 衝突；
2. 繼續 blocked work；
3. 依 §12 確認已接受證據的適用性，執行尚需完成的相關 tests / validation；
4. 在交付報告引用該 `CODEX_DECISION` 與驗證證據。

---

## 7.2 Specification Decision

如果決策涉及：

- Product Behavior；
- Architecture Contract；
- API Contract；
- Database Semantic；
- Data Lifecycle；
- Compatibility；
- Migration Policy；
- Privacy / Security Policy；
- 正式 Requirement；

則視為 Specification Decision。

此時 Codex 必須等待：

Specification Decision
→ CHANGE_REQUEST（Developer 核准為 APPROVED）
→ Work 修改 Spec 並產生 Candidate Spec
→ Developer Review / Approve
→ Repository 更新並指定新的 Current Approved Spec
→ APPLIED
→ Codex Resume

之後才能繼續 blocked work。

Codex 收到新版 Spec 後必須：

1. 重新讀取 Current Approved Spec；
2. 找出修改章節；
3. 重新評估原 CHAT_HANDOFF；
4. 確認衝突已解決；
5. 再繼續 implementation；
6. 執行相關 regression tests。

---

# 8. Spec Modification Rule

Codex 不得把修改 Current Approved Spec 當成一般 implementation task 的附帶工作。

若 Codex 發現 Spec 必須修改：

Codex
→ `CHAT_HANDOFF`
→ Developer / Chat 討論
→ `CHANGE_REQUEST: APPROVED`
→ Work 進行 Impact Analysis / Conflict Check
→ Work 修改 Spec / Consistency Check / 產生 Candidate Spec
→ Developer Review / Approve
→ 新 Spec 正式進 Repository 並指定為 Current Approved Spec
→ APPLIED
→ Codex Resume

除非 Developer 明確指示 Codex 執行已核准的純文件同步工作，否則 Codex
不得自行修改產品需求內容。

---

# 9. 不可違反的架構限制

- 採 Feature-first、MVVM、Use Case、Repository、Service 分層；UI 不直接呼叫
  資料庫、Provider 或平台 API。

- 核心學習採 Local-first、Offline-capable；Content Data、User Learning State、
  Derived Analytics 分開管理。Derived Analytics 可由原始資料重算。

- SQLite schema 變更使用版本化 migration；Reset 依明確 scope 在 transaction
  中執行，不刪除教材 Content Data。

- Flutter App 不持有 AI Provider Secret；AI 請求經 ASP.NET Core AI Gateway
  與 Provider Adapter。

- Practice、Diagnostic、Benchmark、Mock Exam 用途分開。

- Readiness 是 App 內部估計，不是官方分數或通過機率；樣本不足不得顯示有效
  準備度結論。

- Speaking 不併入 JLPT Readiness。

- 不記錄 secrets、完整錄音或不必要的敏感學習資料；遵守最小化蒐集及資料生命
  週期原則。

- 依 Current Approved Spec 的 Phase 順序與階段閘門工作。

- 完成階段需回歸前一階段的 Vertical Slice。

- 不得自行擴大產品範圍。

若未來 Current Approved Spec 正式修改上述 Architecture Constraint，應以新版
Spec 與其核准 Change Request 為準，不得由 Codex 自行推翻。

---

# 10. 專案結構與程式風格

依 Current Approved Spec 採 feature-first 與分層組織。

例如 Flutter：

- `lib/features/`
- `lib/core/`

Backend、Python data pipeline 與測試依元件分組。

遵循：

- Dart
- C#
- Python

各語言慣用命名及標準 formatter。

不得為了單一 Task 無理由進行 repository-wide refactor。

---

# 11. 測試與 Definition of Done

按元件使用：

- `dart format`
- `flutter analyze`
- `flutter test`
- `dotnet test`
- `pytest`

每個交付至少確認：

- Requirement
- UI（適用時）
- Model / Entity
- Use Case
- Repository
- 必要 Service / Gateway
- Migration
- Error handling
- Loading / Empty / Error state
- 適用 Tests
- Privacy / Permission

完成：

- formatter / analyzer
- Git diff review
- Codex review
- Human review

AI 功能另需確認：

- Schema / Rule Validation
- Duplicate Detection
- Version metadata
- Cost / Usage limit
- Sensitive data check
- Readiness policy version
- Knowledge mapping completeness

## 11.1 Phase gate 與階段完成宣告

Phase 順序、範圍與完成閘門依 Current Approved Spec；V2.7 對應 §38，
既有 Vertical Slice 回歸依 §42.3，Definition of Done 依 §40。

Phase gate 尚未完成，不得宣稱 `Phase Complete`，也不得提前開始下一 Phase
implementation。個別 Task 完成、部分驗證通過或文件更新，不代表整個 Phase 完成。
缺少的 gate 證據須明列為未完成／待驗證，不得用 session 摘要或推測補足。

---

# 12. 測試結果回報

Codex 必須回報實際執行的檢查與結果。

未執行的檢查必須明確標示：

`未執行`

不得因推測測試應該通過而寫成已通過。

Repository 尚未建立對應專案或執行環境時，不得聲稱已執行其 build、analyze
或 test。

## 12.1 Validation evidence 分類

| 分類 | 可證明的範圍與限制 |
|---|---|
| Historical validation | 過去版本或 session 的檢查結果；須標明當時版本，不自動證明目前工作樹有效 |
| Current working-tree validation | 目前工作樹（包含未提交修改）上的檢查；記錄 HEAD 與修改狀態，不等同乾淨 checkout |
| Committed clean-checkout validation | 指定 commit 的乾淨 checkout 上執行的檢查；須記錄 commit、乾淨狀態與環境 |
| CI validation | 指定 commit / CI run / job 的實際結果；CI 設定存在不等於 CI 已執行或通過 |
| Device / platform validation | 指定裝置、模擬器或平台環境上的檢查；build 通過不等於裝置流程驗證通過 |
| Developer manual validation | Developer 手動執行並提供完整 command/result 的檢查；可作有效證據，須標明提供者與環境 |

分類可並列，例如 Developer 手動驗證也可能是 committed clean-checkout validation；
不得只因分類名稱或 Developer 接受證據就擴張其可證明的範圍。

每筆 evidence 應記錄：

- 執行者、日期、工作目錄與環境／平台，必要時包含 SDK、裝置資訊；
- 對應 commit 或 HEAD 與工作樹差異／狀態；
- 完整 command、result、exit code（可取得時）與相關 log／產物位置；
- 覆蓋的 requirement / gate、限制與未執行項目。

未知資訊須明列未知，不得推測補齊。歷史或外部提供的證據，不得宣稱為 Codex
本次親自執行；本次未重跑時，明列「本次未執行；採用既有 evidence」及其來源。

## 12.2 Developer evidence 與重跑判斷

Developer 手動執行並提供完整 command/result 的驗證可以作為有效 evidence。
若 Developer 已透過 `CODEX_DECISION` 接受該 evidence，Codex 不應無條件重跑
相同高成本驗證；先確認證據對應的程式、依賴、設定、環境與驗收範圍仍適用。

若後續修改影響受測行為、環境或依賴改變、出現新的失敗／矛盾證據，或既有證據
未覆蓋必要 gate，應說明具體原因並執行必要範圍的補驗證，而非全面重跑。
僅因切換 session 或執行者不同，不構成重跑理由。

接受 evidence 不降低 Spec 的測試、CI、平台、乾淨 checkout 與回歸要求。
V2.7 §42.3 要求的階段回歸仍須針對該交付執行；符合該交付範圍的 Developer
evidence 可以作為執行證據，舊階段結果不能自動替代本階段回歸。

## 12.3 慢速下載 / 長時間 build

- 無輸出不等同失敗；優先確認 process 是否仍正常執行，檢視可取得的 process
  狀態、log、CPU / I/O 或下載進度，不能只依沉默時間判定失敗。
- 不得無限重跑相同 restore / build / download；原 process 仍在執行時，
  不得僅因沒有新輸出就啟動相同工作或終止重跑。
- 重試前記錄前次結果與新的 diagnostic evidence，指出此次重試要驗證或修正什麼。
- 無新 diagnostic evidence 時，停止重複嘗試，回報現況、已知限制與尚缺證據；
  正常執行中的 process 可持續等待與觀察，不得把停止重試寫成驗證通過。
- 長時間工作期間提供進度或不確定性說明；交接時記錄仍在執行的 process 與 log
  位置，避免下一 session 重複啟動。

---

# 13. Phase / Task 完成交付報告

交付 Phase 或重要 Task 時至少列出：

## Scope
本次實作範圍。

## Changed Areas
變更檔案及 Layer。

## Spec Coverage
對應 Current Approved Spec 章節。

## Migration
如有 schema migration，說明升級方式。

## Regression
列出既有 Vertical Slice 回歸結果。

## Tests
實際執行測試與結果、§12 的 evidence 分類與適用範圍；引用的 Developer
evidence / CODEX_DECISION、未重跑原因與未執行項目。

## Limitations
目前限制。

## Pending Decisions
仍待 Developer 決策事項。

若存在未解決的 STOP Condition，不得把受影響 Task 標記為完整完成。

## Git Status
說明目前 Git 狀態。

## 13.1 Codex Review Packet

當 Codex 完成 implementation、bug fix、validation、Phase closure、`CODEX_DECISION`
相關工作，或其他需要 Developer Review 的工作，且準備停止等待 Review 時，
建立或覆寫 `local_data/codex-review/CODEX_REVIEW_PACKET.md`。產生前確認
`local_data/` 確實受 `.gitignore` 忽略；若未忽略，先回報是否需要一次性的
`.gitignore` governance adjustment，不得自行假設。每個新的 Review-ready task
可覆寫或重建前一次 packet；packet 不應 commit。此路徑是固定的當前 Review
slot，不是永久 Review archive；除非 Task Packet 明確要求，不建立編號或日期版
Review Packet 歷史。正式 Review／commit／integration 結束後，舊 packet 內容不需
作為歷史證據保存，可由下一次 Review 取代。

Review Packet 是供 Developer / 01 Chat 閱讀的 convenience artifact，承載本節
交付報告內容與實際 diff，不另設一套完成標準。它不是 Source of Truth、正式
Requirement、`CHANGE_REQUEST`、`CODEX_DECISION`、Developer approval 或新的
validation result，也不能取代 Repository、Git、CI、正式文件、§12 evidence、
§6 `CHAT_HANDOFF`、§15.2 `SESSION_HANDOFF`、STOP Condition 或 Phase gate。
尚未達到 Developer Review 狀態就結束 session 時，仍依 §15.2 交接。

Review Packet 使用以下格式；依 §12 標示 validation 來源與適用範圍，並以
§13 的 Scope、Migration、Regression、Tests 等交付要求填入對應欄位：

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

產生規則：

1. 內容取自實際 Repository、command、CI evidence；不得從 session memory 猜測，
   也不得將未執行項目寫為 PASS。記錄實際 branch、HEAD、upstream 與工作樹狀態。
2. `Diff Review` 對一般小型 source、test、documentation 變更提供足以 Review
   的實際 diff，不只摘要；generated、binary 或 extremely large diff 可省略完整
   內容，但須列出 omitted file、理由及驗證方式。區分本 task 修改與其他既存變更。
   對已通過 Developer Review 的大型檔案，後續若僅審查狀態或 Repository
   integration，且核准時的 baseline 可識別並驗證，可記錄 baseline 識別與 hash、
   目前檔案 hash、相對 baseline 的實際差異、變更範圍核對及已核准本文未變的
   證據，不重複嵌入整份未變本文。無法驗證 baseline 時，仍須提供足夠的完整證據，
   不得隱藏或概括未知差異。
3. 不放入 secrets、credentials、token、個人資料或不必要的敏感內容；若 diff
   含此類資料，遮蔽並註明遮蔽範圍，不得以 packet 擴散。
4. Validation 沿用 §12 的 evidence 分類；記錄 command / CI run、result、
   commit / working tree、environment 與限制。未執行依 §12 標示；CI 未執行
   填 `Not Run`。不因 packet 產生而新增驗證結果。
5. 若有 unresolved STOP Condition，明列於 `Pending Decisions`、`Known Limitations`
   或 `Phase Gate Impact`；不得宣稱受影響 Task 或 Phase 已完成。
6. 產生 packet 不授權 commit、push、merge、改變 Phase status 或繞過既有
   Manual approval / STOP 規則。
7. 若檔案產生失敗，在終端輸出相同格式並明確說明檔案未建立。
8. 檔案建立後，Codex 最終回覆提供 packet path、branch / HEAD、是否有未提交
   修改，以及下一步需要 Developer Review；不需重複輸出完整報告。
9. Packet 只保留本次 Review 所需的實際 diff、適用 hash、validation command／
   result、Git 狀態、scope、未解問題及建議 commit 範圍；避免重複已核准的大型
   文件本文、過期的前次 Review evidence、重複的中間報告。暫存清理依 §13.3。

## 13.2 Codex Task Packet

`local_data/codex-task/CURRENT_TASK.md` 是固定的當前任務 handoff slot 與執行前的
input transport artifact；
§13.1 的 `local_data/codex-review/CODEX_REVIEW_PACKET.md` 是執行後供 Developer /
01 Chat Review 的 output artifact。大型正式任務優先使用 Task Packet，包括
`CODEX_DECISION`、依 §1.4 已 `APPLIED` 的變更實作、Phase task / closure、多步驟
validation、帶有 constraints 的 bug fix、長 implementation instruction，或包含
大量 Must Not Change、Acceptance Criteria、repository context、commands、evidence
的工作。短小、單一步驟且少 constraints 的任務可直接使用 Composer。

產生或使用 Task Packet 前，確認 `local_data/` 確實受 `.gitignore` 忽略；
若未忽略，先回報 Developer 是否需要一次性的 `.gitignore` governance adjustment，
不得自行修改 `.gitignore`。每個新任務以一份完整的 `CODEX_TASK_PACKET` 覆寫
`CURRENT_TASK.md` 原內容，不在同一檔案累積歷史 Task Packets，也不要求 Developer
每次重建 handoff 路徑；此檔不應 commit。任務明確結束後，檔案可留在固定路徑，
但舊內容不再是可執行任務；若使用 inactive placeholder，須明確標示
`NO_ACTIVE_TASK`。下一任務到來前再以完整新 packet 覆寫。

Task Packet 是 convenience / transport artifact，屬 §1.2 第 6 項的 Current
Task Context。它不是 Source of Truth、正式 Requirement、Developer approval、
`CHANGE_REQUEST` 或 `CODEX_DECISION` 本身；不能覆蓋 Current Approved Spec、
Approved Change Request、正式 Decision Record 或 `AGENTS.md`，不能解除 STOP
Condition、構成 Phase Complete，或授權自動 commit / push / merge。Packet 可包含
完整 `CODEX_DECISION`、Approved Change Request、validation instructions 與
Execution Profile；其正式性只來自原有 Developer approval / governance lifecycle。
若內容衝突，依 §1.2、§1.4、§4–8 處理，不得自行改寫 packet 以繼續受影響工作。

標準格式；不適用的欄位填 `None` 或 `Not Applicable`，不得猜測：

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

`Execution Profile` 是 Developer / Chat 的執行建議，並非產品 Requirement 或
Codex 實際 runtime state。`AGENTS.md` 與 Task Packet 不能保證實際 model、
reasoning effort、approval mode 或 execution environment。Codex 使用目前實際
runtime capability；無法確認 model 名稱時不得猜測，也不得把 runtime 設定寫成
產品 Decision。若建議的 Model / Reasoning / Approval 與實際 runtime 明顯不一致，
且可能影響安全、正確性或 Developer 預期，開始受影響工作前簡短回報；不因
Execution Profile 不完全一致就停止所有工作。

Developer 明確輸入「執行目前任務」時，這只是 invocation shortcut。Codex 須先確認：

1. `CURRENT_TASK.md` 存在且包含一份完整有效的 `CODEX_TASK_PACKET`；
2. 內容未標示 `NO_ACTIVE_TASK`；
3. 該任務未被明確完成、Review、整合或後續任務取代；
4. 實際 repository state 與 packet 假設相容。

任一項不成立時，不修改 repository；回報沒有有效的當前可執行任務或 task state
已過期，不因舊 packet 仍在固定路徑而靜默重跑。確認可執行後，仍須完整讀取
`CURRENT_TASK.md`、重新讀取 `AGENTS.md`、確認 Current Approved Spec，並核對實際
branch、HEAD、upstream、working tree；判斷 §4 STOP Condition 後，依 packet 與
正式文件執行。不得要求 Developer 重貼完整 packet、只憑 shortcut 猜測 scope、
跳過 packet 或只依 previous session。Shortcut 不提升 packet 權威，也不是
Developer 對任務結果的預先批准。

若 packet 與 Spec、Approved Change Request 或 Decision Record 衝突，缺少必要
產品決策，要求超出目前 Phase，或需要修改 Spec，依 §4–6 停止受影響部分並
產生 `CHAT_HANDOFF`；Task Packet 不取代 `CHAT_HANDOFF`。若尚未 Review-ready
就中斷 session，依 §15.2 建立 `SESSION_HANDOFF`；接續時重新核對 Spec、
`AGENTS.md`、`CURRENT_TASK.md` 與 Git 狀態。Review-ready 時依 §13.1 建立或
覆寫 Review Packet，沿用既有交付、validation evidence 與 Human Review 規則。

「我Review完了」不是正式 shortcut，也不自動觸發後續工作；Review 後以新的
`CURRENT_TASK.md` 或明確、短小且無歧義的 Developer 指令繼續。此流程不依賴
特定 TUI hotkey；大型正式任務使用 Task Packet，短任務可使用 Composer。

若由 Task Packet 執行且 Review Packet 已建立，最終回覆提供兩個 packet 路徑、
branch / HEAD、是否有未提交修改及是否等待 Developer Review；完整決策、報告與
diff 留在 packet 中，不重複貼回 terminal。若 Review Packet 產生失敗，依 §13.1
第 7 項在終端回報。

## 13.3 Local Task / Review artifact lifecycle

`local_data/` 是 Git 忽略的本機工作區，不是正式 evidence repository。Task／Review
Packet、snapshot、暫存副本及中間報告，不因存在於該目錄就成為 Source of Truth、
Developer approval、Spec `APPLIED` 或 Phase 完成證據，也不能取代 Git commit、
Decision Record、正式 Spec 或已接受的 validation evidence。

每次宣告 task Review-ready 前，檢視 `local_data/codex-review/`：清除已結束的前次
Review／integration 且不再用於重現當前 Review Packet 的明確暫存產物，保留本次
Review 必需的檔案，最後建立或覆寫固定的 `CODEX_REVIEW_PACKET.md`。正式 Review／
commit／integration 結束後，移除不再需要的 comparison snapshot、文件暫存副本
與中間報告；舊 Review Packet 可由下一次取代。`CURRENT_TASK.md` 保持固定 handoff
路徑，由下一任務覆寫，不作永久任務檔案庫。

暫存產物可能包含 `*-pre-*`、`*_BEFORE_*`、`*-before-*`、snapshot、暫存 diff
baseline、暫存 approval-source copy 或內容已由正式 Git 狀態／當前 Review Packet
承載的一次性報告（例如 `SPEC_UPDATE_REPORT.md`）。**不得只靠檔名判定可刪除**；
先核對 Git tracking 與 repository 治理。此規則絕不授權刪除 tracked 文件、
Current Approved／歷史正式 Spec、Decision Record、正式 CHANGE_REQUEST、Phase
closure／validation evidence、source code、tests、migrations、CI、repository
configuration 或正式 architecture 文件。即使檔名含 old、previous、before、
historical、snapshot，只要屬 tracked 或正式證據就不得依暫存規則刪除。
無法確定本機檔案是否為暫存時，保留並在 Review Packet 列明，交由 Human Review。

暫存清理不授權 commit、push、merge、Spec promotion、Change Request application、
Phase start／completion 或產品 implementation；也不取代 Developer Review、
正式 validation evidence 或既有 manual approval／STOP 規則。

---

# 14. Git 與安全

Current branch、HEAD、工作樹是否乾淨及未提交修改，必須由 Git repository
實際狀態判定，不得由本文件或 previous session 推定。開始工作與交付時確認
Git 狀態，保留既有修改。

分支名稱依 Current Approved Spec 所定義流程。

目前 V2.7 §21 定義：

- `main`
- `develop`
- `feature/*`
- `fix/*`

不得自行新增其他流程或 branch type。

提交訊息使用 Conventional Commit 前綴：

- `feat:`
- `fix:`
- `refactor:`
- `test:`
- `docs:`
- `chore:`

不得提交：

- API / Provider Secrets
- 使用者學習資料
- 個人敏感資訊
- 不應進入 repository 的環境設定

Secrets 僅放：

- Local environment configuration
- 核准的 Secret Store

AI 請求一律經 Backend Gateway。

---

# 15. Codex Session Continuity

## 15.1 Resume 與正式狀態

- 預設建議使用 `codex resume`，由 Developer 從 session picker 選擇正確 session。
- 僅在能明確確認最近 session 就是本次要延續的 session 時，使用 `codex resume --last`。
- Codex Session 永遠不是 Source of Truth；resume 不代表舊工作範圍、決策、
  Phase 狀態或驗證證據自動仍有效。

CLI 指令參考：[OpenAI 官方文件](https://learn.chatgpt.com/docs/developer-commands?surface=cli)。

每次遇到以下情況：

- Current Approved Spec 更新；
- `AGENTS.md` 更新；
- Developer 提供新的 Approved Change Request；
- 從 CHAT_HANDOFF 回復；
- 收到 `CODEX_DECISION` 或 `SESSION_HANDOFF`；
- 開始新的 Phase；

Codex 應重新讀取相關正式文件，而不能只依賴 previous session memory。

若 session context 與 repository 正式文件不同：

以 repository 正式文件為準。

## 15.2 Session checkpoint / SESSION_HANDOFF

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

# 16. 核心工作原則

整個專案遵循：

Chat
→ Requirement / CHAT_HANDOFF 分析
→ Developer Decision

若為 Implementation Decision：

Developer Decision
→ CODEX_DECISION
→ Codex Resume
→ Implementation / Test / Validation / Review

若為 Specification Decision：

DRAFT discussion
→ Developer 明確確認
→ CHANGE_REQUEST: APPROVED
→ Spec 維護 Work
→ Impact Analysis / Conflict Check
→ Candidate Spec
→ Developer Review / Approve
→ Repository 更新
→ APPLIED
→ Codex Resume

Spec 維護 Work 也可依 Developer 明確授權維護治理文件；遵守 §3.3 的文件與
實作邊界，不將治理維護視為產品變更或 Phase gate 完成。

若 Codex 發現 Spec / Product / Architecture 問題：

Codex
→ STOP affected work
→ CHAT_HANDOFF
→ 回 Chat 討論

不得跳過 Developer Decision。
