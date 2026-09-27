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

`JLPT_Learning_App_Technical_Spec_V2.3.md`

V2.3 是目前的 Current Approved Spec，但版本未來可以經正式 Change Request
流程升級為 V2.4、V2.5、V3.0 等。

一旦新版 Spec：

1. 已經由 Developer 核准；
2. 已正式放入 repository；
3. 已明確指定取代前一版；

則新版 Spec 成為新的 Current Approved Spec。

Codex 不得因 AGENTS.md 曾記載 V2.3，而忽略 repository 中後續正式核准的新版本。

---

## 1.2 權威順序

若資訊互相衝突，依以下順序判定：

1. Current Approved Spec
2. 已核准且尚待套用的 Change Request
3. `AGENTS.md`
4. Repository 中正式 Architecture / Decision Record / Project Documents
5. Existing Code / Tests
6. Developer 當前明確指令
7. Current Codex Task Context
8. Previous Codex Session / Conversation Context

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

Developer 可以直接提供 implementation decision。

Codex 收到明確決策後：

1. 確認決策不與 Current Approved Spec 衝突；
2. 繼續 blocked work；
3. 執行相關 tests；
4. 在交付報告記錄該 implementation decision。

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

Chat 討論
→ Developer 核准 Change Request
→ Work 更新 Spec
→ Developer Review
→ 新版 Current Approved Spec 進入 Repository

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
→ Work 更新 Spec
→ Developer Review
→ 新 Spec 進 Repository
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

---

# 12. 測試結果回報

Codex 必須回報實際執行的檢查與結果。

未執行的檢查必須明確標示：

`未執行`

不得因推測測試應該通過而寫成已通過。

Repository 尚未建立對應專案或執行環境時，不得聲稱已執行其 build、analyze
或 test。

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
實際執行測試與結果。

## Limitations
目前限制。

## Pending Decisions
仍待 Developer 決策事項。

若存在未解決的 STOP Condition，不得把受影響 Task 標記為完整完成。

## Git Status
說明目前 Git 狀態。

---

# 14. Git 與安全

目前使用 `main`。

分支名稱依 Current Approved Spec 所定義流程。

目前 V2.3 §21 定義：

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

`codex resume --last` 可以用於延續目前 implementation context。

但 Codex Session 不是 Source of Truth。

每次遇到以下情況：

- Current Approved Spec 更新；
- `AGENTS.md` 更新；
- Developer 提供新的 Approved Change Request；
- 從 CHAT_HANDOFF 回復；
- 開始新的 Phase；

Codex 應重新讀取相關正式文件，而不能只依賴 previous session memory。

若 session context 與 repository 正式文件不同：

以 repository 正式文件為準。

---

# 16. 核心工作原則

整個專案遵循：

Chat
→ 討論需求與架構
→ Developer Decision
→ APPROVED CHANGE_REQUEST

Work
→ Impact Analysis
→ Conflict Check
→ 更新 Spec
→ Consistency Check

Developer
→ Review / Approve

Repository
→ Current Approved Spec

Codex
→ Implementation
→ Test
→ Review

若 Codex 發現 Spec / Product / Architecture 問題：

Codex
→ STOP affected work
→ CHAT_HANDOFF
→ 回 Chat 討論

不得跳過 Developer Decision。