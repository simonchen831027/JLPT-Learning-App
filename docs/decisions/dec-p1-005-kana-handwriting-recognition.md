# DEC-P1-005 — Kana Handwriting Recognition

- Decision ID：`DEC-P1-005`
- Status：`APPROVED`
- 登錄日期：2026-09-27；Developer 核准日期：2026-09-27
- 核准來源：Developer 於 `JLPT App｜01 需求・架構決策` 明確確認採用 `DEC-P1-005`；`CURRENT_TASK.md` 僅傳遞已核准內容供 Repository 登錄
- 適用規格：Current Approved Spec V2.5（CR-0002 `APPLIED`），§4–8、§12.6、§14.1、§38.3–38.4、§38.11、§42.6
- Spec Change Required：No

## Context

V2.5 將 Hiragana／Katakana 學習與鍵盤、手寫 Practice 納入 Phase 1，要求核心學習離線可用，並在辨識不可用時保留鍵盤降級。§38.11 要求在導入辨識器前，先決定 provider、平台適配、候選處理與答案正規化。本紀錄只登錄已核准決策；Phase 1 尚未開始。

## Decision

### 1. 架構

Kana 手寫辨識依 `Presentation → ViewModel → Use Case → HandwritingRecognitionService → Platform Adapter` 分層。UI 不直接依賴 ML Kit、Windows handwriting API、OCR／ML provider SDK 或 provider 專屬原始辨識物件；provider 專屬型別留在 adapter／service 邊界內。

### 2. Android／iOS provider

Android／iOS 使用 Google ML Kit Digital Ink Recognition，日語模型的 BCP-47 語言標籤為 `ja`。Flutter 整合方向為專用套件 `google_mlkit_digital_ink_recognition`；不因本功能引入完整的 `google_ml_kit` umbrella package。本決策核准 provider 與整合方向，不授權在本次文件任務新增 dependency。

### 3. 辨識模型交付

日語手寫辨識模型採 provider 支援的動態下載。Application／Domain 至少區分 `modelNotInstalled`、`downloading`、`ready`、`unavailable`、`error`。首次請求辨識而模型尚未安裝時，須清楚告知使用者需要下載日語手寫辨識模型，且僅在使用者明確操作後下載；不得靜默下載大型模型。

成功供應模型後，辨識須能離線運作。模型尚未供應且裝置離線時，手寫辨識不可用；Keyboard Practice 仍可用，Kana Learning 仍可進行，核心學習不受阻。Kana 核心學習維持 Offline-capable；手寫辨識在首次離線使用前可能需要一次性模型供應。

### 4. Windows

Google ML Kit 不作為 Windows provider；保留 `WindowsHandwritingRecognitionAdapter` 抽象。不得只為跨平台功能一致性而引入 Cloud 手寫辨識、未核准的大型自製 ML 模型或不穩定的 native dependency。

若適用的實作時點仍無已核准的離線 Windows adapter，Windows 手寫辨識為 unavailable，Keyboard Kana Practice 保持可用，UI 清楚指出該裝置／設定無法使用手寫辨識。觸控／觸控筆能力與辨識器能力分開判定：有 touch 不等於有 recognizer。未來 Windows provider 須另作 Decision／technical spike。

### 5. 筆跡表示與生命週期

辨識輸入為暫存的 `Stroke → ordered StrokePoint[]`；`StrokePoint` 至少包含 `x`、`y`、`timestamp`，可另外包含書寫區域的 width／height。Phase 1 原始 strokes／points 不存入 SQLite 或 analytics，不上傳 Cloud，也不用於模型訓練。辨識完成、使用者清除 Canvas 或離開手寫流程時，釋放暫存筆跡資料。

### 6. Kana 正規化

答案比對使用單一集中政策，至少包括：移除首尾空白、Unicode normalization、將半形 Kana 相容字元正規化為標準 Kana，以及處理組合濁點／半濁點表示。Hiragana 與 Katakana、小字與一般 Kana、`っ` 與 `つ` 保持語意不同。未轉換的 Romaji 不視為有效 Kana 答案。`expectedKana` 一律來自已核准的 Content Data。

### 7. 候選與正誤政策

辨識器可回傳排序後的候選。Phase 1 不以任意、未校準的數值 confidence threshold 作為唯一正誤規則，而依排名判定：

1. Top 1 候選正規化後等於 `expectedKana`：Correct。
2. Top 1 不等於 `expectedKana`，但 `expectedKana` 出現在 Top 3：Ambiguous Recognition；最多顯示 3 個候選，請使用者確認原意。選擇 `expectedKana` 時為 Correct，並記錄 `recognitionResolution = userConfirmed`；選擇其他候選為 Incorrect。不得將較低排名的 `expectedKana` 靜默判為 Correct。
3. Top 3 不含 `expectedKana`：Incorrect，提供 Retry。

### 8. Confidence score

若 provider 提供候選 score，可暫時用於排序、輔助或 debug。Phase 1 不持久化 confidence score、不轉換成 learner mastery、不顯示手寫品質分數，也不用未校準的 score threshold 判斷手寫品質。

### 9. Domain 辨識結果

Domain-level 結果至少可表達 `recognized`、`ambiguous`、`noCandidate`、`modelNotInstalled`、`unavailable`、`error`。`RecognitionCandidate` 至少包含 `text` 與 `rank`。Provider 專屬原始結果物件不得滲入 Domain 或 UI。

### 10. 失敗與降級

模型未安裝、下載失敗、辨識器不可用、provider error、平台不支援、沒有 touch／stylus，或首次供應模型時沒有網路，都不得阻斷 Kana Learning、Visual Prompt Practice 或 Keyboard Practice。

### 11. 隱私

原始手寫點位僅作暫存輸入；Phase 1 不永久保存完整手寫筆跡。未來若要加入手寫歷史儲存、telemetry、上傳、模型訓練或手寫 analytics，須另作 Privacy／Data Lifecycle Decision。

### 12. 範圍

Phase 1 手寫辨識只回答「使用者寫了哪個 Kana？」不評估筆順、筆畫角度、書法美觀、手寫品質、書寫速度或 AI 手寫分數。

## Reason

採用成熟的裝置端行動平台手寫辨識，同時維持 Local-first／Offline-capable 核心學習與鍵盤降級；不以 Cloud 辨識或過早建立自製 ML 技術堆疊強求 Windows 功能一致。

## Constraints

- 遵循 V2.5 與 CR-0002，不擴大 Phase 1 範圍。
- Kana 核心學習不依賴 Cloud 手寫辨識；模型供應失敗不阻斷核心學習。
- UI 不直接依賴 provider API；provider 專屬物件留在 service／adapter 邊界內。
- Phase 1 原始筆跡資料僅暫存。
- 本 Decision Record 不授權在本次任務開始 implementation。

## Consequences / Trade-offs

Android／iOS 首次離線手寫辨識取決於模型是否已供應；供應前仍可使用鍵盤與 Kana 學習。Windows 若無核准的離線辨識器，只提供鍵盤降級。模糊候選需要使用者確認，避免較低排名候選被靜默計為正確；原始筆跡不保留，無法用於日後回放或分析，相關能力須另行決策。

## Validation Expectations

未來 implementation 須驗證：Android 與 iOS 日語模型供應、模型下載後的離線辨識、模型缺失且離線時的降級、Top 1 正確、Top 3 模糊候選及使用者確認、錯誤辨識、`noCandidate`、清除／重試、筆跡不持久化、Windows 無辨識器降級，以及 Keyboard Practice 持續可用。

本次僅登錄 Decision Record；application build、tests 與 CI 均未執行。
