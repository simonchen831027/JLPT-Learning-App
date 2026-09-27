# DEC-P1-003 — Practice / Review Feedback

- Decision ID：`DEC-P1-003`
- Status：`APPROVED`
- 登錄日期：2026-09-27（Developer 核准日期未提供）
- 核准來源：Developer 提供的 `CURRENT_TASK.md`，Repository Decision Record 待 Human Review
- 適用範圍：Current Approved Spec V2.4 §7.4.1、§14.1／§14.4、§17.1、§24、§27、§38.3、§38.11；Phase 1 Practice / Review

## Context

V2.4 要求 Practice／Review 逐題立即顯示正誤、答案與離線詳解，並提供可關閉的 correct／incorrect feedback sound。§38.11 留待適用階段決定音效預設與呈現參數；Mock Exam 不沿用逐題回饋。

## Decision

`Feedback Sound` 預設 ON；使用者可於 Settings 關閉，偏好重啟後仍保留。Phase 1 使用兩個短的 packaged local feedback sounds，分別用於 correct 與 incorrect；音效離線可用，遵循平台／系統 media volume。

Phase 1 不加入 App 專屬 volume slider、haptic feedback 或複雜 feedback animation。

Practice／Review 每題流程：

```text
Submit Answer
→ Evaluate Answer
→ Show Correct / Incorrect state
→ 若 Feedback Sound 為 ON，播放相應音效
→ Show user answer
→ Show correct answer
→ Show curated / stored detailed explanation
→ 等待使用者明確操作，才繼續下一題
```

不得自動前進下一題。正誤不能只靠顏色區分；須有可讀文字、語意 icon／state 或等效的無障礙提示。正式 Phase 1 離線題目須有 stored／curated detailed explanation，AI 不能是唯一詳解來源。

## Constraints

- Packaged sound 不依賴網路。
- UI 不直接存取 Settings database。
- 不將 Practice／Review 即時揭露回饋套用到 Mock Exam。

## Consequences / Trade-offs

兩個短本機音效提供可離線且一致的正誤提示，但需要隨 App 封裝及驗證；系統 media volume 控制播放音量，不建立 App 專屬音量政策。逐題等待使用者繼續，確保答案與詳解可閱讀；Mock Exam 仍維持交卷前不揭露的獨立流程。

## Validation Expectations

- 答對與答錯路徑皆顯示相應狀態、使用者答案、正確答案及詳細離線詳解。
- Sound 預設 ON、關閉後持久化；兩種音效離線可用。
- 不自動前進；須由使用者明確繼續。
- 正誤狀態不只依賴顏色，且 UI 不直接讀寫 Settings database。
