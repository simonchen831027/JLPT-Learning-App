# DEC-P1-008 — Content Research, Provenance & Publication Workflow

- Decision ID：`DEC-P1-008`
- Status：`APPROVED`
- 核准來源：Developer 對 Phase 1 Slice 1B publish eligibility CHAT_HANDOFF 的明確決策
- 適用範圍：Current Approved Spec V2.5、Phase 1 Slice 1B Content Data 與後續教材治理流程
- Spec Change Required：No

## Context

DEC-P1-007 要求 published content revision 至少關聯一筆有效的 `SourceReference`，但未定義來源的 `reviewStatus`、`contentUsageStatus` 如何決定發布資格。Slice 1B 已完成其他 Content Data foundation，正式 publish path 因此問題停止。Developer 核准以下治理與發布規則，解除該 `CHAT_HANDOFF`；V2.5 仍為 Current Approved Spec。

## Decision

### 教材開發角色與核准權

`JLPT App｜01 需求・架構決策` 負責產品、需求、架構、教材治理、`CHAT_HANDOFF` 與 Content Release 決策，並與 Developer 進行最終 Review，不承擔大量教材撰寫。`JLPT App｜03 教材研究・編寫` 負責多來源研究、交叉查證、App 專屬教學設計，以及原創說明、例句、題目、詳解、reading／Furigana candidate 與來源追蹤；03 的教材狀態至少區分 `DRAFT`、`NEEDS REVIEW`、`READY FOR DEVELOPER REVIEW`，不得自行宣告 `RELEASED`。

Codex 可依 Current Approved Spec 與 JLPT 範圍提出 Content Curriculum／Manifest proposal，整理 N5～N1 的長期分類、先備知識、學習順序與練習覆蓋，交 Developer Review；經 03 編寫及 Developer 核准後，才可將 Approved Content 整合進 repository 的 canonical content／seed／import format，並執行 schema、reading alignment、answer consistency、SourceReference、versioning 與 automated validation。Codex 不得自行把未核准教材當成正式 Content、複製大量第三方內容、跳過 Review、自行宣告 Release 或新增產品 Requirement。

Developer 是最終 Content Release authority，可 `APPROVE`、`REJECT` 或 `REQUEST REVISION`。日文知識品質不能只依賴 Developer 個人判斷；應結合多來源研究、交叉驗證、03 撰寫與自動檢查。Developer Review 主要確認理解性、教學順序、學習效果、難度、題目幫助及 App 呈現，並決定是否批准正式 Release。

### Curriculum scope、流程與來源原則

長期 Curriculum／Manifest backlog 可規劃 N5～N1，但 `Long-term Planning != Current Production Scope`；目前 Phase 1 production content 僅 N5 core。N4～N1 可研究與規劃，不得提前加入 Phase 1 production seed、UI 或正式功能。大量教材撰寫前，Codex 應先提交可 Review 的 Content Manifest proposal；可包含 content key、JLPT level、type、topic、lesson、learning objective、prerequisite、reference categories、03 的交付要求及 `PLANNED`、`RESEARCH_REQUESTED`、`DRAFTED`、`READY_FOR_DEVELOPER_REVIEW`、`APPROVED`、`INTEGRATED`、`RELEASED` 等 workflow status。本決策不要求 Slice 1B 建立 production Content Manifest entity；若未來需 persistence，另行決策。

流程為 JLPT scope／reference classification → Codex curriculum／manifest proposal → Developer 確認製作範圍 → 03 多來源研究、知識整理與原創編寫 → reading／answer validation → `READY FOR DEVELOPER REVIEW` → 01 與 Developer Review（必要時退回 03）→ Developer `APPROVED` → Codex 整合 Approved Content Package → automated validation → Content Release。不得省略 Developer approval。

公開網站為 `Reference Source`，不是 `Copy Source`。可研究一般語言知識、文法規則、JLPT 範圍並交叉比較，再自行設計教學結構、說明、例句、題目與詳解；不得大量保存或逐段改寫第三方文章，亦不得複製來源題庫、例句或不必要的圖片、音訊、PDF。正確的語言知識不需刻意改變；App 教材的表達與結構原則上由 Content Pipeline 重建。

### SourceReference 的雙維度狀態

`SourceReference.reviewStatus` 是明確 enum：`pending`、`approved`、`rejected`，不得為任意 String。`pending` 尚未完成必要治理檢查；`approved` 已完成來源檢查，可再依用途狀態判斷 provenance；`rejected` 不應支持正式發布。

Domain 的 `ContentUsageStatus` 為 `referenceOnly`、`originalContent`、`licensed`、`needsReview`、`blocked`；SQLite 分別保存 `reference-only`、`original-content`、`licensed`、`needs-review`、`blocked`，映射集中於 persistence layer。前 3 種可計入 publication provenance，後 2 種不得計入。`reference-only` 僅供研究、查證與 provenance，並不授權複製網站原文、例句或題庫。`reviewStatus` 與 `contentUsageStatus` 是不同維度，不能互相取代。

### 正式發布資格與原子性

只有 `reviewed` content revision 可轉為 `published`，且必須至少有一筆 attached `SourceReference`；**所有** attached sources 的 `reviewStatus` 均為 `approved`，用途狀態均為 `reference-only`、`original-content` 或 `licensed`。零來源、任何 `pending`／`rejected`／`needs-review`／`blocked` 來源都阻止整個 revision 發布；不得因另有一筆有效來源而忽略無效來源。發布前應完成來源審核，或從仍可修改的 draft／reviewed revision 移除不應屬於 provenance 的關聯。

Slice 1B 須有狹窄的 repository publish path：在同一 transaction（或等價原子操作）驗證全部來源資格，轉換 `reviewed → published`，並更新非空 actor `updatedBy` 與明確 UTC `updatedAt`。UI 不實作自己的 eligibility。SQLite 也須阻止直接 SQL reviewed→published 繞過零來源、非 approved review status 或 `needs-review`／`blocked` 用途限制；DB invariant 與 repository policy 必須一致。

來源核准不等於教材核准。教材仍須經 03 → Developer Review → Developer `APPROVED` → Codex 整合、驗證、Release。Slice 1B 不建立 `DeveloperApproval` production table；目前 Developer approval 是 Content Pipeline／task governance prerequisite。若未來要在 DB 永久保存 approval event，另行決策。

### Published provenance 與目前 migration

成為 published 或 withdrawn revision provenance 的 `SourceReference` 與關聯須保持 immutable。發布後發現來源、授權或教材問題時，withdraw affected revision，重新研究／編寫、Developer Review，建立新的 revision／ContentVersion，再驗證與發布；不得修改原發布歷史。未來若需 global source denylist／legal-risk registry，另行決策，不在 Slice 1B 預建。

目前 production schema v2 尚未 commit／release，故直接修正未提交 v2 migration：`source_references.review_status` 加入 `pending`／`approved`／`rejected` CHECK，發布 trigger 加入完整來源資格條件，並對應 Domain enum 與 persistence mapping；不建立 v3。v2 正式 commit／release 後不得回寫，往後以新 migration version 變更 schema。

## Constraints

- V2.5、DEC-P1-001～007 及當前 Phase 邊界維持有效；Phase 1 production content 僅 N5 core。
- 不新增 dependency、第三方內容複製 pipeline、自動 Content Release、Content Manifest production table、User Learning State、N4～N1 seed 或其他 Slice 1B 以外的功能。
- 03 不宣告 Release；Codex 不跳過 Developer approval 或自行新增 Requirement。

## Validation Expectations

驗證來源 enum 的 persistence mapping、所有單來源／多來源／零來源 publish matrix、repository transaction 與 DB direct-SQL bypass protection、成功發布的 status／actor／UTC timestamp、published provenance immutability、current published／withdrawn 查詢，以及既有 Slice 1A／1B regression。未執行的 build、device 或 CI 不得記為 PASS。
