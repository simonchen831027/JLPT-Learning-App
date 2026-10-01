# DEC-P1-009 — Independent Content QA & Editorial Review Workflow

- Decision ID：`DEC-P1-009`
- Title：Independent Content QA & Editorial Review Workflow
- Status：`APPROVED`
- 核准來源：Developer 對 DEC-P1-009 governance integration 的明確核准。
- Spec Change Required：No
- Product Requirement Change：No
- Architecture / API / Database Semantic Change：No
- Phase Gate Change：No

## Context

DEC-P1-008 已定義 03 的 Content research / authoring、provenance / publication baseline，
Developer 為最終 Content Release authority。DEC-P1-009 補充 Independent Content QA /
Editorial Review gate，不重寫 DEC-P1-008 的 original approved record。

新增 06 的目的為分離 Author 與 Independent Reviewer、降低 self-review blind spot、
提升 learner-facing Content quality，並讓 Developer Review 聚焦於教學方向、產品價值
與最終 Release decision。既有 Approved Content 不因本 Decision 自動失效。

## Decision

### 角色與權限

- 03：Content Author / Researcher。
- 06「JLPT App｜06 教材校對・品質審查」：Independent Content QA / Editorial Review。
- Developer：Final Content Approval / Release Authority。
- Codex：依明確授權進行 Production Integration。

03 Content Candidate 不等於 Content APPROVED / RELEASED。
06 PASS 不等於 Content APPROVED、Content RELEASED 或 Codex integration authorization。

### 03 Responsibilities

03 負責：

- research 與 cross-source verification；
- Canonical Knowledge；
- original Lesson authoring；
- Vocabulary、Grammar、Kanji、ExampleSentence；
- Question、Option / distractor、Correct Answer、detailed explanation；
- reading / Furigana candidate；
- SourceReference / provenance；
- Content revision candidate 與 Content handoff。

03 在交 06 前仍須自行做 Author QA。

### 06 Responsibilities

06 至少檢查：

- Japanese accuracy 與 Japanese naturalness；
- Traditional Chinese editorial quality；
- learner-facing readability 與 pedagogical clarity；
- JLPT level appropriateness；
- terminology consistency；
- internal metadata leakage；
- question / answer consistency；
- distractor quality 與 explanation quality；
- reading / Furigana QA；
- cross-content consistency。

06 可輸出 PASS、REQUEST REVISION、BLOCKED / DECISION REQUIRED。
06 可提出 line-level proposed revision，但 proposal 不自動成為 Approved Content。

### 06 Must Not Decide

06 不得自行：

- 改 Curriculum scope；
- 新增 / 刪除正式 Knowledge target；
- 改 Product Requirement；
- 改 Architecture / API；
- 改 Content schema；
- 改 Data Lifecycle；
- 改 JLPT level policy；
- 宣告 RELEASED；
- 授權 Codex production integration。

涉及 Curriculum / Product / Requirement 的問題交 01 / Developer；author revision 交 03。

### Independent QA Gate

新建立或實質修訂的 learner-facing Content，原則上在 Developer Content Review 前
經 06 Independent QA。至少適用於：

- Lesson learner-facing body；
- Vocabulary learner-facing definition；
- Grammar explanation 與 Kanji explanation；
- ExampleSentence；
- Question stem、Options / distractors、Answer、detailed explanation；
- learner-facing translation；
- reading / Furigana metadata；
- learner-visible title / label / instructional copy。

純 internal metadata、source URL maintenance，或不影響 learner-facing semantic 的
technical correction 可採 targeted QA；不得利用此例外繞過重大 learner-facing revision。
此為 Content review workflow，不改變既有 Phase gate。

### Existing Approved Content

DEC-P1-009 不追溯撤銷既有 Approved Content。若既有 Content 發現 learner-facing
quality issue、進行實質 revision、建立新 revision / ContentVersion，或 Developer
要求 re-QA，則 revised candidate 應經 06。

不得因本 Decision 原地覆寫 immutable historical revision。

### Content Workflow

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

Developer 保持最終 Content Release authority；06 QA 與 03 authoring 均不取代其批准。

## Constraints

本 Decision 僅補充已核准的 Content governance workflow；不修改 Current Approved
Spec V2.7、Product Requirement、Architecture / API Contract、Database schema / semantic、
Migration、Data Lifecycle、Content production data、Phase status / gate 或 CR-0001～0004 狀態。
DEC-P1-001～008 的 historical decision semantics 保持不變。

Chat / Work 是執行介面／工作模式，不改變 logical Workspace authority。
Artifact lifecycle、cross-workspace routing 與 task-specific approved input 依 AGENTS.md
§3.3～3.5；本 Decision 不提升 Draft / QA output 的正式權威。
本次治理整合不授權啟動 03 / 06 Content production task 或 production implementation。

## Validation Expectations

- AGENTS.md 正確記錄 03 Author、06 Independent Reviewer 與 Developer 最終批准分工。
- Independent QA gate 包含適用範圍、targeted QA 例外與既有 Approved Content 邊界。
- 06 PASS、03 Candidate 不被視為 Content Release 或 production integration authorization。
- DEC-P1-008 original approved record、V2.7、Phase status / gate 與實作保持不變。
