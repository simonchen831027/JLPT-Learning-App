# DEC-P1-001 — Learning Audio Delivery

- Decision ID：`DEC-P1-001`
- Status：`APPROVED`
- 登錄日期：2026-09-27（Developer 核准日期未提供）
- 核准來源：Developer 提供的 `CURRENT_TASK.md`，Repository Decision Record 待 Human Review
- 適用範圍：Current Approved Spec V2.4 §7.4.1、§12.6、§27、§38.3、§38.11；Phase 1 Learning Audio

## Context

V2.4 要求教學內容提供 context-sensitive 發音，基本 Lesson、Reading、Furigana、Quiz 須可離線使用；§38.11 要求在 Phase 1 導入發音前記錄交付方式。UI 不直接操作平台 API。

## Decision

Phase 1 以本機裝置／作業系統的日語 TTS 作為主要發音播放方式，置於 Audio / Speech Service 抽象層之後。發音輸入使用 Content Model 中已驗證的 context-sensitive reading metadata；UI、TTS runtime 或 Widget 不猜測漢字讀音。核心學習不依賴 Remote TTS、Backend 或 Cloud。

若日語語音能力不可用：

1. 顯示 audio unavailable／disabled 狀態。
2. 說明缺少可用的日語系統語音／speech resource。
3. 提供安裝或啟用日語語音資源的可操作指引。
4. 平台若提供可靠且受支援的設定操作，App 可提供開啟相應系統設定的動作。
5. 若沒有可靠的 settings deep link，改以清楚的手動步驟指引。
6. Lesson、Reading、Furigana、Practice、Review 仍可使用。

App 不得在使用者未明確操作時，自行安裝或下載作業系統語言／語音套件。Phase 1 不要求儲存或快取動態合成的 TTS 音訊；Reference Audio、Remote TTS 與進階 audio caching 留待後續增強。

## Constraints

- UI 不直接呼叫平台 API；須透過 Audio / Speech Service abstraction。
- 不硬編碼特定作業系統 voice name，不把 Windows／Android／iOS 特定 settings URI 升級為產品要求。
- TTS 可用性不控制 Furigana 或核心教材的可用性。

## Consequences / Trade-offs

本機發音不需要 Phase 1 Remote TTS、Backend、Cloud 或動態音檔快取；語音品質與日語 voice 可用性取決於裝置／作業系統。平台設定入口只在可靠受支援時提供，否則以手動指引處理；音訊不可用須有明確狀態，但不能阻斷學習。

## Validation Expectations

- 日語 voice 可用時，能播放對應 context-sensitive reading 的發音。
- 日語 voice 不可用時，顯示 unavailable 狀態與安裝／啟用指引。
- 設定入口涵蓋 supported、unsupported 與 failure 狀態。
- Speech 不可用時核心 Lesson／Quiz 仍可使用，且沒有 Backend／Remote TTS 依賴。
