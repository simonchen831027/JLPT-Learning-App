# DEC-P1-002 — Furigana Data / Rendering

- Decision ID：`DEC-P1-002`
- Status：`APPROVED`
- 登錄日期：2026-09-27（Developer 核准日期未提供）
- 核准來源：Developer 提供的 `CURRENT_TASK.md`，Repository Decision Record 待 Human Review
- 適用範圍：Current Approved Spec V2.4 §6–7、§14.4、§17.1、§27–28、§38.3、§38.11；Phase 1 Furigana

## Context

V2.4 要求教學 Furigana 離線可用、預設開啟且可關閉，並避免在測驗題目中洩漏讀音答案。§38.11 要求記錄 reading alignment、句子 segmentation 與 ruby rendering 的適用決策。

## Decision

Phase 1 Furigana 使用 Content Pipeline 預先準備且驗證的 context-sensitive reading metadata。Domain／Content representation 支援有順序的 reading segments；概念表示如下：

```text
ReadingSegment
- surface
- reading（optional）

日本語 → にほんご
を → 無 reading
勉強 → べんきょう
します → 無 reading
```

Runtime 負責呈現既有 reading alignment，不使用 AI、線上字典或執行時形態分析來產生基本 Furigana。建立可重用的 Furigana／ruby rendering abstraction；Widget 不分散實作 parsing／alignment 邏輯。

`Show Furigana` 初次使用預設 ON，使用者可關閉；偏好存於 `AppSetting`，重啟後保留。`Reset Learning Data` 保留偏好，`Factory Reset` 恢復預設。

題目／學習內容支援語意等同 `inherit`、`show`、`hide` 的 reading-aid presentation policy，避免在測驗讀音的題型洩漏答案。正式 Mock Exam 題目不受全域 `Show Furigana` 額外注入 reading aid；只能顯示正式題組本身定義的 reading aid。

## Constraints

- 基本 Furigana 必須離線可用，UI 不猜測讀音。
- 不在 Widget 分散 parsing／alignment 邏輯。
- 未經明確 dependency review，不加入大型第三方套件。
- 精確 DB／table／field 名稱留作實作設計，不藉此改變已核准產品語意。

## Consequences / Trade-offs

內容發布前須驗證 reading 與 segment alignment；runtime 可維持離線且不依賴 AI／網路。重用 rendering abstraction 能使教材與題目依各自 policy 呈現；全域偏好不能覆蓋正式 Mock Exam 的題組邊界。資料欄位、migration 與 UI 細節須在適用 implementation slice 中設計及測試。

## Validation Expectations

- `Show Furigana` 預設 ON、OFF、重啟持久化與 Reset 範圍。
- 多漢字詞、漢字／假名混合、送り仮名及句子的 reading alignment 與離線呈現。
- `readingAidPolicy: hide` 不洩漏讀音答案。
- Mock Exam 正式題組不受全域偏好注入額外 reading aid。
