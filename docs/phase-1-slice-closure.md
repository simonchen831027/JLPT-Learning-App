# Phase 1 Internal Work Package Closure Record

Slice 1A / 1B / 1C

**文件狀態：Developer Approved Governance Record；等待 Repository integration。**

## 1. Purpose / Terminology

本文件記錄 Phase 1 早期 implementation decomposition 使用的內部 work packages：
**Phase 1 internal work package Slice 1A、Slice 1B、Slice 1C**。這些名稱不是
Current Approved Spec 定義的 Phase 1.5 Vertical Slice A、Phase 2 Vertical Slice B、
Phase 2.5 Vertical Slice B.5 或 Phase 3 Vertical Slice C。尤其 Phase 1 internal work
package Slice 1C 只涵蓋 B0 canonical Content integration 與 N5 L01 read-only learning
demo，與 Phase 1.5 Vertical Slice A、Phase 3 Vertical Slice C 均不同。

本次只將 Developer 已接受的歷史 work-package 完成狀態與證據界線寫入 Repository；
不新增產品 Requirement、架構決策或 Phase gate，也不重新宣告任何 Spec-defined
Vertical Slice 完成。

## 2. Status Summary

| 範圍 | 狀態 | 完成意義 |
|---|---|---|
| Phase 1 internal work package Slice 1A | COMPLETE | Phase 1 Persistence Foundation 的核准範圍完成 |
| Phase 1 internal work package Slice 1B | COMPLETE | Phase 1 Content Data Foundation 的核准範圍完成 |
| Phase 1 internal work package Slice 1C | COMPLETE | B0 canonical integration 與 N5 L01 唯讀學習展示的核准範圍完成 |
| Phase 0 | COMPLETE | 依既有 [Phase 0 Closure](phase-0-closure.md) |
| Phase 1 | STARTED / NOT YET COMPLETE | 仍須滿足 Current Approved Spec 的完整 Phase 1 gate |

## 3. Phase 1 internal work package Slice 1A — Persistence Foundation

**Status：COMPLETE。** Primary commit：`3b43e5dc4880175e2fecbb5c56214579d683dc93`。
相關正式決策：[DEC-P1-004](decisions/dec-p1-004-core-data-conventions.md)、
[DEC-P1-006](decisions/dec-p1-006-uuid-v7-generation.md)。

核准範圍建立 UUID v7 generation 與 persistence values 基礎，維持 `String`／SQLite
`TEXT` ID、明確 `createdAt`、UTC instant、date-only 與 nullable 慣例。DEC-P1-006
核准 `uuid 4.6.0`，解除此前的 dependency `CHAT_HANDOFF`。commit 包含實作、lockfile、
測試及 DEC-P1-006；本機 remote-tracking reflog 記錄該 commit 曾推送至目前 feature branch。

當時最終 Review-ready packet 記錄 `flutter pub get`、Dart format、目標 11 項測試、
`flutter analyze --no-pub`、完整 `flutter test --no-pub` 22 項測試與
`git diff --check` 通過。這是當時 HEAD `07f6803` 加未提交 Slice 1A 檔案的
historical working-tree validation，不是本次重新執行，也不是 committed
clean-checkout、CI 或 device validation。

獨立的「Slice 1A Final Review PASS」原文**未恢復**，不得補造。然而在後續
DEC-P1-008 的 Developer 核准續接指令中，Developer 明確以 `Slice 1A: COMPLETE`
及 commit `3b43e5d` 作為 Slice 1B 前提；後續 Planning 與 Slice 1C 工作亦一致承接。
Developer 現已正式接受「歷史驗證＋核准實作範圍＋commit/push＋後續明確承接」
作為此 internal work package 的歷史 closure evidence。

## 4. Phase 1 internal work package Slice 1B — Content Data Foundation

**Status：COMPLETE。** Primary commit：`1eb5c0a9f10d31da6deffb463781e8be6f82dce7`。
相關正式決策：[DEC-P1-007](decisions/dec-p1-007-phase-1-content-data-contract.md)、
[DEC-P1-008](decisions/dec-p1-008-content-research-provenance-publication-workflow.md)。

核准範圍建立 production schema v2、ContentVersion／immutable revision、
Content Data domain 與 repository、ReadingText／ReadingSegment、Phase 1
`singleChoice` Question／Option identity、SourceReference provenance，以及正式
publish eligibility path 與相應測試。先前 publish eligibility blocker 由
DEC-P1-008 解決。commit 包含 schema、domain、repository、tests 與兩份 Decision
Records；本機 remote-tracking reflog 記錄該 commit 曾推送至目前 feature branch。

DEC-P1-008 補修後的最終 Review-ready packet 記錄 Dart format、
`flutter analyze --no-pub`、目標 30 項測試、完整 `flutter test --no-pub`
43 項測試與 `git diff --check` 通過，dependency 未變。這是當時 HEAD `3b43e5d`
加未提交 Slice 1B 檔案的 historical working-tree validation，並非本次、
committed clean-checkout、CI 或 device validation。

較早的 `INCOMPLETE` 與 `REVIEW-READY` 是 blocker 與最終 Review 前的歷史狀態，
已被 DEC-P1-008 解決、最終驗證、commit/push 與後續 Developer 承接所 supersede。
獨立的「Slice 1B Final Review PASS」原文**未恢復**，不得補造。Developer 在其後
Content Planning 指令及 Review 中明確以 `Slice 1B: COMPLETE` 作為 Planning Gate
與 Slice 1C 的前提。Developer 現已正式接受這條歷史證據鏈作為此 internal work
package 的 closure evidence。

## 5. Phase 1 internal work package Slice 1C — B0 Canonical Integration + N5 Read-only Demo

**Status：COMPLETE，限於當時核准的唯讀範圍。** Primary commit：
`f5972c0ea3b4a4491c2c5a78f990e1eae502ebcf`。沿用
[DEC-P1-004](decisions/dec-p1-004-core-data-conventions.md)、
[DEC-P1-006](decisions/dec-p1-006-uuid-v7-generation.md)、
[DEC-P1-007](decisions/dec-p1-007-phase-1-content-data-contract.md)、
[DEC-P1-008](decisions/dec-p1-008-content-research-provenance-publication-workflow.md)。

### Approved input 與 canonical content

Developer-approved B0 Content、已核准的 SourceReference remediation、
`Source Approval Gate: PASS` 與 Developer 授權的 canonical local publication
構成本 work package 的輸入。B0 canonical Content Data integration 的核准數量是
Lesson 1、Vocabulary 6、Grammar 2、Kanji 2、ExampleSentence 5、Question 3；
current B0 release 有 **19 published revisions**、**17 active SourceReferences**。
來源資格、publication lifecycle、immutable revision 與 current release 遵守既有
Content Data contract。

### Learner-facing 唯讀路徑與資料契約

完成 `Home → N5 → L01` 唯讀學習流程，畫面經
`Presentation → ViewModel → Use Case → Repository → SQLite` 讀取 current
published Content Data。保留 `ReadingText`／`ReadingSegment` canonical metadata、
contextual reading、核准 Question payload、`QuestionOption` identity、
`correctOptionId`、stored explanation 及 published revision immutability；UI 不在
runtime 猜測 reading。Question 資料存在不表示 interactive Quiz／Practice 作答流程已完成。

### Developer 修正、歷史驗證與最終核准

首次 Developer Review 為 `PASS WITH REQUIRED MINOR CORRECTIONS`。必要修正為：

1. 補足 Lesson canonical Step 3，使 EX-B0-01～03 於核准的 Step 3 語意位置呈現，
   不再由 Step 2 直接跳 Step 4；不重複建立 ExampleSentence。
2. 保留 Step 6 canonical Reading metadata 的核准 contextual alignment，不修改
   approved surface、不以 runtime 推測讀音。

兩項修正後，當時重新執行的 historical working-tree validation 記錄 Dart format、
`flutter analyze --no-pub`、`flutter test --no-pub` **46 tests**、Windows release
build、Windows integration smoke、`git diff --check` 及 B0 content／repository
assertions 均 PASS。Windows smoke 涵蓋 `Home → N5 → L01 → Back → reopen` 及
current release／content persistence 相關行為。Final Review 前 `Pending Decisions: None`、
`Unresolved CHAT_HANDOFF: None`。

Developer 直接給出 `Slice 1C Developer Final Review: PASS`、
`Slice 1C: APPROVED / COMPLETE`、`Required Corrections: NONE`、
`Commit: AUTHORIZED`、`Push: AUTHORIZED`。最終 reviewed scope 已以 `f5972c0`
commit 並推送至 feature branch；本機 remote-tracking reflog 亦留有 push 紀錄。

### Completion boundary

`Slice 1C COMPLETE` **只表示上述核准的 B0 canonical integration 與 N5 L01
read-only learning demo 範圍完成**。它不表示 Phase 1 interactive Practice UI、
Quiz scoring／Result、Wrong Question、Learning Progress、Review workflow、
Reset Learning Data、完整 User Learning State、Audio、完整 Show Furigana Settings、
Kana Practice、handwriting 或 visual asset integration 已完成；也不代表 AI／network、
Android／iOS device、CI 或 public App／Store release 已完成。這些項目不屬此
internal work package 的 closure 條件；其中屬於 Phase 1 正式 Requirement 的項目
仍須於 Phase 1 gate 完成前交付。

因此此狀態**不代表** Phase 1 Quiz／Review／Reset 完成、Phase 1 gate 完成、
Phase 1.5 Vertical Slice A 完成，或 Phase 3 Vertical Slice C 完成。

## 6. Historical Validation Evidence Boundary

本次是治理文件正式化，**沒有重新執行** `flutter analyze`、`flutter test`、build、
Windows smoke、Android／iOS device validation 或 CI。上列 1A、1B、1C 的結果
僅是當時各自核准 task scope 的 **historical working-tree validation**；沒有據此
宣稱目前工作樹通過測試、目前 CI PASS 或 committed clean-checkout PASS。

本機 remote-tracking reflog 與 commits 可核對當時的 commit／push chain；
本次未 live fetch，不能用本機 ref 推定遠端即時狀態。commit 證明內容曾進 Git，
但單獨不構成 Developer approval；1A／1B 的後續 Developer 明確承接及本次正式接受，
與 1C 的直接 Final Review，分別提供核准證據。

## 7. Phase Boundary

Phase 1 internal work package Slice 1A、Slice 1B、Slice 1C 均 `COMPLETE`，
**不等於 Phase 1 COMPLETE**。Phase 0 維持 `COMPLETE`；Phase 1 維持
`STARTED / NOT YET COMPLETE`。整體完成仍須符合 Current Approved Spec 的
Phase 1 gate；本文件不 waive gate、不減少 Requirement、不授權 Phase 1.5 開始，
也不宣稱任何 Spec-defined Vertical Slice 完成。

## 8. Governance Purpose

`local_data/codex-review/CODEX_REVIEW_PACKET.md` 是可覆寫的固定 Review slot，
不是永久 closure archive。本 tracked record 保存 Developer 已接受的 internal
work-package status、核准 scope、相關 Decision、primary commit、歷史證據分類與
已知限制，以免 packet 覆寫後再次遺失 closure context。

本文件不取代 Current Approved Spec、Decision Records、Git commits、原始驗證
evidence 或 Phase gate；也不修改先前 V2.6／CR-0003 promotion 的工作樹狀態。
