# DEC-P1-007 — Phase 1 Content Data Contract

- Decision ID：`DEC-P1-007`
- Status：`APPROVED`
- 核准來源：Developer 對 Slice 1B `CHAT_HANDOFF` 的明確決策
- 適用範圍：Current Approved Spec V2.5、Phase 1 Slice 1B
- Spec Change Required：No

## Context

Slice 1B 的前次 preflight 因 ContentVersion 生命週期、reading 儲存、題目答案結構、KnowledgeConcept 時點與 provenance 關聯未定而停止。Developer 核准以下 Content Data contract，解除該五項 blocker；不修改 V2.5。

## Decision

### ContentVersion 與 revision

`ContentVersion` 表示 Content Release／Content Package version，不是 SQLite schema version 或 `questionSetVersion`。`contentId` 是穩定的 logical identity；同一教材修訂時沿用 `contentId`、建立新的 immutable revision，關聯新的 ContentVersion。已發布 revision 不原地覆寫。模型須區分 logical content identity、immutable content revision 與 content release／version；同一 `contentId` 可於多個 ContentVersion 有 revision。

正常 Learning／Practice 只選目前有效的 published revision；withdrawn revision 不供新流程選取。舊 revision 不因新版本發布或 withdraw 立即 hard delete，須保留 provenance、migration 與既有 User Learning State reference 所需資料。不得以 UUID timestamp 推導 revision 順序。

### Reading metadata

Canonical alignment 採 normalized、明確排序的 `ReadingText → ReadingSegment[]`，不得只存 JSON blob。每個 `ReadingSegment` 至少有 identity、parent `ReadingText` identity、ordinal／sequence、非 null 的 surface、僅在不需 reading aid 時為 null 的 reading。不同可讀 content field 可各自引用 `ReadingText` aggregate；`ReadingSegment` 只 FK 到 `ReadingText`，不以 polymorphic FK 直接連多種教材表。不同 content type 共用相同 schema，但不同 content revision 不共用同一組 mutable segments。Widget runtime 不猜測 reading。

### Phase 1 Question

Slice 1B 首個 production answer mode 為 `singleChoice`。`Question` 至少有 identity、prompt／content、適用 reading metadata、content version／provenance 與 curated offline detailed explanation。`QuestionOption` 至少有 identity、question identity、display order、option content 與適用 reading metadata。正解是恰好一個正確的 `QuestionOption` identity，不以顯示文字作 identity。

Kana keyboard／handwriting Practice 不使用此 contract，仍依 CR-0002。此 Slice 不建立 free-text grading、translation equivalence、multiple-correct grading、fuzzy matching 或 listening-specific grading contract；未來需要其他 grading semantics 時，以 versioned migration 擴充。

### KnowledgeConcept 時點

Slice 1B 不建立 `KnowledgeConcept`、`QuestionConceptMap`、placeholder concept ID 或 serialized fake mapping。依 V2.5 Phase 順序，Phase 1 建立 Core Offline Learning Content／User Learning foundation；Phase 1.5 再建立 KnowledgeConcept／QuestionConceptMap，對 Phase 1 正式內容補 mapping。當前 Content／Question identity 須穩定，以便後續 migration 建立 mapping。

### SourceReference 與 provenance

`SourceReference` 與 content revision 是 many-to-many，使用明確 join structure，relation 指向 revision 而非僅指向 logical `contentId`；不得把 source IDs 存於 comma string 或單一 JSON field。Draft 可無來源；published 至少有一筆有效 provenance relation，release／content validation 必須阻止無 provenance 的正式發布。

### Creator／modifier metadata 與 review lifecycle

每個正式 content revision 至少儲存非 null 的 `createdBy`、`updatedBy`、`createdAt`、`updatedAt`、`reviewStatus`。Actor identifier 是 `String`，Phase 1 不建立 User Account FK，也不以 null 表示 unknown actor。時間為明確 UTC timestamp，遵循 DEC-P1-004，不從 UUID timestamp 推導。

最低狀態為 `draft`、`reviewed`、`published`、`withdrawn`，不以 null 表示狀態。Draft 未通過人工審核，不供正式學習；reviewed 已完成審核但未發布；published 可供正常 Learning／Practice；withdrawn 不再供新流程使用，亦不因此 hard delete。

Published revision 為 immutable；learner-visible content、reading、answer、explanation 或 provenance 有變動時，須建立新的 revision／ContentVersion，不得 UPDATE 原 published revision 並仍視為同一版本。只有 DB physical schema 變更且內容語意不變時，不需建立新 revision。

### Slice 1B 邊界

可建立 ContentVersion、revision／governance primitives、SourceReference 與 join、ReadingText／ReadingSegment、Lesson／LessonSection、Vocabulary、Grammar、Kanji、Kana Content、ExampleSentence、singleChoice Question／QuestionOption，以及必要的 repository／DAO／mapper。不得建立 User Learning State、KnowledgeConcept／QuestionConceptMap、Assessment／Readiness、AI／Cloud 或真實 N5 seed content。

## Constraints

- 既有 `MigrationRunner`、`EntityIdGenerator` 與 `PersistenceValues` 須重用，不重複 UUID、UTC 或 migration 邏輯。
- Production schema 以 versioned、保留既有資料的 migration 升級，不使用 delete-and-recreate。
- 不新增 dependency，不擴張其他 Phase 1 feature，不修改 Current Approved Spec 或 DEC-P1-001～006。

## Validation Expectations

驗證 production v1 升級、fresh schema、舊資料保留與重開；版本及多 revision、published immutable／withdrawn 查詢、many-to-many provenance 與無來源發布拒絕；UTC metadata、有序 reading；代表性 Lesson、Vocabulary、Grammar、Kanji、Kana、ExampleSentence、singleChoice Question／Option 及正解不變條件；UUID v7 TEXT；既有 Slice 1A／database regression。DB constraint 無法完整表達的 invariant 可由 repository／domain validation 補強，並在 Review Packet 說明責任分界。
