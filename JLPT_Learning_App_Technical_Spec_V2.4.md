# JLPT Learning App 技術規格 V2.4

> 版本：2.4，Developer Approved
> 基準：V2.3（前版 Current Approved Spec）；依 CR-0001（APPLIED）修訂
> 架構：Flutter / Dart + C# / ASP.NET Core + Python  
> 平台：Windows 11、Android、iOS  
> 定位：個人使用、非商業、Local-first、Offline-capable、AI-assisted、可逐步擴充

> 治理狀態：V2.4 是 Current Approved Spec；CR-0001 已 APPLIED；
> V2.3 保留為被取代的歷史 Spec；Phase 1 NOT STARTED，尚未進行 Codex implementation。

## V2.4 Change Summary — CR-0001

本版在 V2.3 原有架構與 Phase 順序內整合五項已核准需求：問題回報與
Developer 決策邊界、教學內容發音、預設開啟且可關閉的 Furigana、Practice /
Review 逐題回饋，以及 Mock Exam 交卷前不揭露結果的政策。新增需求分散於
內容、UI、資料、Assessment、Privacy、Phase gate 與測試章節。尚未決定的
provider、音效預設、Feedback 資料生命週期、Diagnostic / Benchmark 回饋時點
等參數列入 §38.11；不得於實作時猜測。

## 0. V2.3 修訂重點

V2.3 延續 V2.2 的產品範圍與技術架構，不增加 V2.2 未支持的產品功能。本次修訂針對開發落地時容易造成重工或結果不一致的規格缺口，明確定義階段順序、完成閘門、回歸要求與待決策處理方式。

V2.2 已定義的核心仍完整適用：Knowledge Mastery 與 QuestionConceptMap、Practice/Diagnostic/Benchmark/Mock 的用途區分、Readiness / Weak Point / Study Plan、Assessment 版本追蹤、Speaking 與 JLPT Readiness 分離、Local-first 與資料生命週期。

V2.3 主要修訂：

1. 統一 Phase 順序，明確區分 Phase 1.5 的資料模型基礎與 Phase 2.5 的 Assessment 功能實作。
2. 為 Phase 0、1、1.5、2、2.5、3、4、5 加上可檢查的完成閘門。
3. 列出 V2.2 尚未定義的政策參數，要求相關開發前建立 Decision Record，不得由 Codex 猜測後硬編碼。
4. 明確每階段對前一階段 Vertical Slice 的回歸責任。
5. 補充 migration 升級、原始資料與衍生分析重建、Reset scope 的驗證要求。
6. 規定階段交付回報需列出實際檢查結果、未執行項目、待決策與 Git 狀態。
7. 保留 Readiness 為 App 內部估計、AI 題目需驗證、Speaking 不納入 JLPT Readiness 等既有限制。

## 1. 專案目標

建立跨平台 JLPT 日文學習 App，提供：

- N5 起步，逐步擴充 N4/N3；Assessment abstraction 與最終 Mock Exam 能力保留 N5～N1
- 文法、單字、漢字、例句教學
- 教學漢字預設顯示可關閉的 Furigana；學習內容提供 context-sensitive 發音播放
- 選擇、填空、翻譯、閱讀、聽力等測驗
- Practice / Review 逐題回饋與詳解；Mock Exam 確認交卷後才揭露結果
- 使用者問題回報與經 Developer 審核的改善建議流程
- 錯題與學習歷程
- AI 教學、AI 題庫與解析
- 麥克風口說練習
- Speech-to-Text / Text-to-Speech
- 口說文字正確性與語音表現評估
- 個人化複習與學習統計
- Diagnostic Assessment / Benchmark Assessment / Mock Exam
- JLPT Readiness 準備度分析
- 單字、文法、漢字、閱讀、聽力弱點分析
- 個人化 Study Plan 與再測推薦
- 歷史資料重置與資料刪除
- Windows 11 / Android / iOS 共用主要程式碼

核心原則：

> Local-first + Offline-capable + Cross-platform + AI-assisted + Privacy-aware + 可測試 + 可逐步擴充

產品原則：

```text
核心學習能力
→ 不依賴 AI / Cloud 才能運作

AI / Speech / Cloud
→ 作為增強能力

所有外部服務
→ 經過 Service / Gateway 抽象化

所有使用者資料
→ 可追蹤、可刪除、可重置
```

產品核心循環：

```text
Learn
 ↓
Practice
 ↓
Assess
 ↓
Analyze
 ↓
Identify Weakness
 ↓
Recommend
 ↓
Review
 ↓
Re-assess
 ↓
Update Readiness
```

產品必須讓使用者最終能回答：

```text
1. 我目前對目標 JLPT 等級準備到什麼程度？
2. 哪些單字 / 文法 / 閱讀 / 聽力項目是目前主要弱點？
3. 接下來該學什麼、做多少練習、何時再次評估？
```

## 2. 技術總覽

| 項目 | 技術 |
|---|---|
| Frontend | Flutter |
| Language | Dart |
| Windows | Flutter |
| Android | Flutter |
| iOS | Flutter |
| Web | 預留，不列入 MVP |
| Local DB | SQLite |
| Local Repository | Dart Repository / DAO |
| Backend | ASP.NET Core |
| Backend Language | C# |
| Cloud DB | PostgreSQL，Phase 5 啟用 |
| Data / ETL | Python |
| AI Gateway | ASP.NET Core |
| AI Provider | OpenAI API（可替換） |
| STT / TTS | `SpeechService` 抽象層 + 可替換 provider |
| Architecture | Feature-first + MVVM + Use Case + Repository + Service |
| Testing | flutter test / integration_test / xUnit / pytest |
| Version Control | Git / GitHub |
| CI/CD | GitHub Actions |
| Container | Docker（Backend 啟用後） |
| AI Coding | Codex + ChatGPT |
| Primary IDE | VS Code |
| Secondary IDE | Visual Studio 2026 |

環境原則：

```text
Flutter SDK version → pinned
Dart SDK version → pinned
.NET SDK version → pinned
Python version → pinned
Dependencies → version controlled
Database schema → migration versioned
```

## 3. 整體架構

### 3.1 V2.2 主要架構

```text
                           Flutter App / Dart
                                    │
                  ┌─────────────────┼─────────────────┐
                  │                 │                 │
               Windows           Android             iOS
                  │                 │                 │
                  └─────────────────┼─────────────────┘
                                    │
                        Presentation / ViewModel
                                    │
                             Domain / Use Case
                                    │
                              Repository Layer
                           ┌────────┴────────┐
                           │                 │
                     Local Data        Online Services
                           │                 │
                        SQLite         HTTPS / REST
                                             │
                                      ASP.NET Core
                                      AI Gateway
                                      / API
                                      │
                           ┌─────────┴─────────┐
                           │                   │
                       OpenAI API        PostgreSQL
                     (AI Provider)      (Phase 5)
```

### 3.2 Local-first 原則

```text
Offline
 ↓
Lesson / Vocabulary / Grammar / Kanji
Quiz / Wrong Question / Progress / Review
 ↓
仍可正常使用
```

Online Enhancement：

```text
AI Explanation
AI Question Generation
Speech-to-Text（依 provider）
AI Speaking Evaluation
Cloud Sync
Backup
```

## 4. Flutter 架構

採 `Feature-first + MVVM + Use Case + Repository + Service`。

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── theme.dart
│   └── app_config.dart
├── core/
│   ├── database/
│   ├── network/
│   ├── errors/
│   ├── logging/
│   ├── config/
│   ├── permissions/
│   ├── audio/
│   └── utils/
├── features/
│   ├── home/
│   ├── lesson/
│   ├── vocabulary/
│   ├── grammar/
│   ├── kanji/
│   ├── quiz/
│   ├── wrong_questions/
│   ├── progress/
│   ├── speaking/
│   ├── review/
│   └── settings/
└── main.dart
```

每個 Feature 原則上包含：

```text
View
ViewModel
UseCase
Repository interface
Service interface（需要時）
Model / Entity
Widgets
```

UI 不直接操作 SQLite、OpenAI 或 Platform API。

## 5. Presentation / ViewModel / Domain / Repository

### Presentation

負責 Widget、Page、Layout、Animation、Responsive UI 與 UI accessibility。

### ViewModel

負責 UI state、使用者操作、載入、錯誤與 loading 狀態，呼叫 Use Case。

### Domain / Use Case

主要邏輯：

```text
StartLesson
CompleteLesson
GenerateQuiz
SubmitAnswer
RecordWrongQuestion
CalculateProgress
GenerateReviewPlan
StartSpeakingPractice
TranscribeSpeech
CompareSpeechText
EvaluateSpeaking
ResetLearningData
DeleteLocalLearningData
```

### Repository

Repository 統一資料來源與交易邏輯，例如：

```dart
abstract class LessonRepository {
  Future<Lesson?> getLesson(int id);
  Future<List<Lesson>> getLessons();
}
```

未來可同時存在：

```text
LocalLessonRepository
RemoteLessonRepository
```

並由 Application / Use Case 決定是否需要 Online fallback，不讓 UI 自行判斷。

## 6. UI / Responsive Design

手機：

```text
Bottom Navigation
Single-column / Scrollable content
```

Windows：

```text
NavigationRail / Sidebar
Master / Detail
```

大螢幕：

```text
Adaptive two-pane layout
```

同一套資料與業務邏輯，共用 UI 元件，但不強迫 Windows 與手機使用完全相同版面。

教學頁面與 Settings 須提供易辨識的 Furigana 開關與發音動作；Reading Aid
與 Audio Action 互相獨立。Furigana 使用可選取文字，不以圖片寫死，須在手機、
Windows、字級縮放、換行及捲動情境仍可閱讀且不遮蓋正文。Practice / Review
逐題顯示回饋；Mock Exam 作答畫面只呈現作答狀態，確認交卷後才進入結果與
詳解畫面。問題回報頁面須可由使用者存取；其適用階段見 §33 與 §38.9。

## 7. 本地資料庫與資料分層

MVP 使用 SQLite。

V2.2 明確將資料分成兩類：

### 7.1 Content Data

內容資料原則上由 App / Seed / Content Update 管理，不屬於一般使用者學習紀錄：

```text
Lesson
LessonSection
Vocabulary
Grammar
Kanji
ExampleSentence
Question
QuestionOption
SpeakingExercise
SourceReference
ContentVersion
Reading metadata / reading alignment（依需要）
Learning audio metadata / reference（依需要）
Question explanation（正式離線題目）
```

### 7.2 User Learning State

使用者行為與歷史資料：

```text
UserProfile
QuizSession
QuizAnswer
WrongQuestion
LearningProgress
ReviewItem
SpeakingResult
AppSetting
```

### 7.3 User Learning / Assessment / Derived Analytics 結構

V2.2 再細分 User State，避免把「原始行為資料」與「可重算的分析結果」混在一起。

```text
SQLite
│
├── Content Data
│   ├── Lesson
│   ├── LessonSection
│   ├── Vocabulary
│   ├── Grammar
│   ├── Kanji
│   ├── ExampleSentence
│   ├── Question
│   ├── QuestionOption
│   ├── SpeakingExercise
│   ├── SourceReference
│   ├── ContentVersion
│   ├── KnowledgeConcept
│   └── QuestionConceptMap
│
├── User Learning State
│   ├── UserProfile
│   ├── QuizSession
│   ├── QuizAnswer
│   ├── WrongQuestion
│   ├── LearningProgress
│   ├── ReviewItem
│   ├── SpeakingResult
│   ├── AssessmentSession
│   ├── AssessmentAnswer
│   ├── OfficialExamResult
│   └── AppSetting
│
└── Derived Analytics
    ├── LearnerKnowledgeMastery
    ├── WeakPoint
    ├── ReadinessSnapshot
    ├── ReadinessSectionResult
    ├── StudyPlan
    └── StudyPlanItem
```

Derived Analytics 必須能由原始 User Learning State 重建；不可把衍生結果視為唯一真實來源。

教學 Reading / Furigana alignment、發音來源參照與正式題目的 curated explanation
屬 Content Data；Show Furigana 與 Feedback Sound 開關屬 `AppSetting`。Mock Exam
交卷狀態、確認後完成時間與版本關聯屬 User Learning State；結果仍依既有
Assessment / Derived Analytics 責任分界管理。FeedbackReport 不混入學習證據或
Readiness，跨使用者 FeedbackCluster、ImprovementSuggestion、DeveloperDisposition
待 Cloud-capable Phase 才有 server-side 責任；實際儲存與留存政策依 §38.11 決定。

### 7.4 核心新增資料模型

#### KnowledgeConcept

```text
KnowledgeConcept
├── conceptId
├── type
├── jlptLevel
├── name
├── category
├── description
├── contentVersion
└── status
```

`type`：

```text
vocabulary
grammar
kanji
reading_skill
listening_skill
```

#### QuestionConceptMap

```text
QuestionConceptMap
├── questionId
├── conceptId
├── weight
└── isPrimary
```

一道題可測量多個概念，但必須有 `isPrimary` 概念，並可設定權重。

#### LearnerKnowledgeMastery

```text
LearnerKnowledgeMastery
├── userId
├── conceptId
├── exposureCount
├── attemptCount
├── correctCount
├── wrongCount
├── recentAccuracy
├── allTimeAccuracy
├── masteryScore
├── confidence
├── trend
├── lastAttemptAt
├── nextReviewAt
└── status
```

`status`：`new / learning / weak / improving / mastered`。

V2.2 MVP 不使用未經驗證的複雜 ML 作為唯一依據，先使用可解釋的加權規則；後續可用實際 JLPT 成績與模擬測驗資料校準。

#### 7.4.1 Reading、Audio、Explanation 與使用者設定

`Vocabulary`、`Kanji` 教學內容、`ExampleSentence`、`Grammar` 例句及
`Lesson` 內需要讀音的日文內容，須由 Content / Domain Model 提供 written form、
context-sensitive reading，以及需要時的 reading segments / alignment；例如
`今日 → きょう`、`日本語 → にほんご`。資料須能處理多漢字詞、漢字與假名混合、
送り仮名及句子。UI 不得臨時猜讀音，也不得機械列出單字中各漢字的所有音讀／
訓讀。欄位與表名由適用階段設計；不得在 Widget 分散 parsing / alignment 邏輯。

正式離線題目須保存可離線顯示的正確答案與 curated / stored detailed explanation；
音訊來源保留 Reference Audio / TTS abstraction 與必要 metadata，provider 未定。
`AppSetting` 保存 Show Furigana 與 Feedback Sound 偏好，重啟後仍有效。Show
Furigana 首次使用預設 ON；Feedback Sound 預設 ON / OFF 尚待決策，但使用者必須
能關閉。依 §17.1，Reset Learning Data 保留 App Setting，Factory Reset 恢復
預設；若將來增加其他 Settings reset scope，先記錄 Decision Record。

這些資料與 Mock Exam 交卷狀態若需 schema 變更，使用 versioned migration、
migration test 與可保留既有資料的升級路徑，不以刪除／重建資料庫替代一般升級。

### 7.5 資料存取

```text
Feature
 ↓
Use Case
 ↓
Repository
 ↓
DAO / Database layer
 ↓
SQLite
```

### 7.6 資料存取

```text
Feature
 ↓
Use Case
 ↓
Repository
 ↓
DAO / Database layer
 ↓
SQLite
```

所有 schema 修改必須透過 migration。

## 8. 教材來源與 Content Governance

主要參考來源目前規劃：

- 音速日語
- 時雨の町

這些來源定義為 `Reference Sources`，不是直接複製進 App 的 Content Database。

### 8.1 內容流程

```text
Reference Sources
 ↓
人工閱讀與理解
 ↓
抽取「知識概念 / 規則 / JLPT 範圍」
 ↓
建立 Canonical Knowledge Model
 ↓
自行撰寫教材與例句
 ↓
自行建立題目
 ↓
建立並驗證 context-sensitive reading / alignment、必要音訊授權與離線詳解
 ↓
AI 做程度調整 / 變體生成
 ↓
Validator / Review
 ↓
Content Release
```

禁止以以下方式作為產品內容生產的預設流程：

```text
原站文章
 ↓
大量擷取
 ↓
直接改寫
 ↓
大量保存
 ↓
App
```

避免直接重製：

- 完整文章
- 付費教材
- PDF
- 音檔
- 圖片
- 原站題庫
- 大量可辨識的原文段落

### 8.2 SourceReference

資料庫保存來源追蹤資訊：

```text
SourceReference
├── sourceId
├── sourceName
├── sourceUrl
├── sourceTitle
├── topic
├── referenceLevel
├── accessedAt
├── contentUsageStatus
├── reviewStatus
├── createdAt
├── updatedAt
└── note
```

`contentUsageStatus`：

```text
reference-only
original-content
licensed
needs-review
blocked
```

用途是內容 provenance、查證與內部審核，不是大量保存第三方內容。

### 8.3 Knowledge Mapping 原則

每一個正式教材單元與題目都應映射到 `KnowledgeConcept`。

```text
Lesson
 ↓
KnowledgeConcept
 ↓
Question / Exercise
 ↓
QuizAnswer / AssessmentAnswer
 ↓
LearnerKnowledgeMastery
 ↓
WeakPoint / StudyPlan
```

禁止只有「課程 → 分數」而沒有知識概念映射，否則無法可靠回答「哪個單字 / 文法需要加強」。

### 8.4 Content Governance 原則

```text
每一份教材
→ 有 contentId
→ 有 contentVersion
→ 可追蹤來源
→ 有建立 / 修改者資訊
→ 有 review 狀態
→ 可重新生成或撤回
```

正式發布前應保留人工審核流程。法律風險、授權與實際內容使用方式若有疑義，應在發布前另行取得適當的法律 / 授權確認。

AI 可於 Content Pipeline 提出 reading candidate、例句與解析，但正式
Content Release 前須驗證其 context-sensitive reading、Furigana alignment、
答案與解析一致性及音訊素材授權。核心教材 Reading metadata 須離線可用；
AI、線上字典與遠端 TTS 不是顯示基本 Furigana 的 runtime dependency。

## 9. AI 架構

### 9.1 AI 不由 Flutter 直接呼叫 Provider

正式 App 不應將 OpenAI API Key 或其他永久服務憑證固定在 App。

```text
Flutter
 ↓ HTTPS
AiService
 ↓
AI Gateway / ASP.NET Core
 ↓
Provider Adapter
 ↓
OpenAI API
```

### 9.2 AI Gateway 責任

```text
Authentication / Device Policy（Phase 2 之後逐步增加）
Rate Limit
Request Size Limit
Prompt Template 管理
Model Routing
Usage Logging（不記錄敏感原文）
Provider Abstraction
Retry / Timeout
Schema Validation
Cost Control
```

### 9.3 Flutter 端介面

```dart
abstract class AiService {
  Future<AiExplanation> explainGrammar(...);
  Future<List<Question>> generateQuestions(...);
  Future<SpeechTranscript> transcribeAudio(...);
  Future<SpeakingEvaluation> evaluateSpeaking(...);
}
```

Provider 不應直接出現在 UI 層。

### 9.4 Provider Adapter

```text
AI Gateway
├── OpenAiProvider
├── GeminiProvider（未來）
├── ClaudeProvider（未來）
└── MockAiProvider
```

## 10. AI 功能

### 10.1 AI 教學

- 改寫與簡化解釋
- 依程度調整說明
- 產生原創例句
- 解釋錯誤原因
- 比較相似文法
- 依使用者錯誤生成針對性提示

Phase 2 可提供 alternative / adaptive explanation 與額外例句；Phase 1 正式
Practice / Review 題目的 curated / stored detailed explanation 不得以 AI 回應
取代。AI Gateway 不可用時，離線題目仍須顯示原有詳解。

### 10.2 AI 題庫

- 單字題
- 文法題
- 填空題
- 選擇題
- 翻譯題
- 閱讀理解
- 聽力題

AI 題目流程：

```text
Canonical Knowledge / Lesson
 ↓
Prompt Template
 ↓
AI Generate
 ↓
JSON Schema Validation
 ↓
Rule Validation
 ↓
Answer Consistency Check
 ↓
Duplicate Detection
 ↓
Difficulty / JLPT Validation
 ↓
Optional Human Review
 ↓
Save as Versioned Question
```

優先「預生成 + Cache」，不要每次作答都即時生成。

### 10.3 AI 題庫禁止直接成為唯一真實來源

AI 生成內容必須經過 validator；正式題庫應可標記：

```text
Draft
Validated
Reviewed
Published
Rejected
Deprecated
```

## 11. AI 題庫版本化與可追溯性

每一題至少保留：

```text
Question
├── questionId
├── contentVersion
├── generatorVersion
├── promptVersion
├── modelProvider
├── modelName
├── generatedAt
├── validatedAt
├── reviewedAt
├── jlptLevel
├── difficulty
├── status
└── sourceReferenceId（必要時）
```

目的：

```text
可以回答：
這一題是什麼版本生成？
依據哪個教材版本？
用了哪個 Prompt / Model？
哪個 Validator 通過？
什麼時候發布？
```

避免模型更新後無法追蹤題目差異。

### 11.1 題目用途分類

Question 增加：

```text
questionRole
```

允許：

```text
practice
review
diagnostic
benchmark
mock_exam
```

規則：

```text
practice / review
→ 可以動態生成與重複
→ 依 §14 的 Learning Mode Feedback Policy 逐題揭露答案與詳解

diagnostic / benchmark / mock_exam
→ 優先使用固定版本、已驗證題組
→ 題目、難度、知識映射與 scoring version 必須可追蹤
→ 不沿用 Practice / Review 的即時回饋；Mock Exam 依 §14.4 禁止交卷前揭露
```

評估用途禁止只依賴即時 AI 隨機題，避免每次評估的題目難度與內容不可比較。

## 12. Speaking

Speaking 分成兩層，不把 STT 結果直接視為發音評分。

### 12.1 Level 1 — Speech Correctness

```text
Speaking Exercise
 ↓
TTS / Reference Audio
 ↓
使用者朗讀
 ↓
Microphone
 ↓
Audio Capture
 ↓
STT
 ↓
Expected Text vs Transcript
 ↓
文字正確性
```

可以評估：

```text
文字相似度
漏字
多字
關鍵詞命中
語句完整性
```

### 12.2 Level 2 — Pronunciation / Fluency Evaluation

```text
Audio
 ↓
Speech Analysis
 ↓
Pronunciation / Timing Features
 ↓
AI / Scoring Service
 ↓
Speaking Evaluation
```

結果可包含：

```text
textCorrectness
pronunciation
fluency
pause
completeness
feedback
```

部分指標可能因平台、音訊品質、語音服務 provider 而不可用，Schema 必須允許 `null / unavailable`。

### 12.3 SpeakingResult

```text
SpeakingResult
├── resultId
├── exerciseId
├── transcript
├── textCorrectness
├── pronunciationScore
├── fluencyScore
├── pauseScore
├── completenessScore
├── feedback
├── provider
├── model
├── createdAt
└── audioRetentionStatus
```

AI 評估屬學習輔助，不宣稱等同 JLPT 官方評分。

### 12.4 Speaking 與 JLPT Readiness 的關係

Speaking 結果可以用於：

```text
口說練習
學習動機
個人弱點提示
整體日文學習報告
```

但不得直接作為 JLPT 官方 Readiness 的 scoring section。JLPT 官方結果主要依 Language Knowledge、Reading、Listening 的 scoring sections 判定；不同級別的分區結構與門檻必須以官方最新規格為準。

### 12.5 Audio Retention

預設：

```text
原始錄音 → 暫存 → 分析 → 刪除
```

除非使用者主動選擇保存，否則不永久保存原始錄音。

### 12.6 一般教材發音與 Speaking Audio 的分界

Vocabulary、Kanji 教學內容、Example Sentence、Grammar Example 與 Lesson
中需要讀音的日文內容提供發音播放動作；播放使用 §7.4.1 的 contextual reading
及 Reference Audio / TTS abstraction，不綁定 provider，也不把 Speaking 錄音
保留政策套用到教材參照音訊。Reading Aid 與發音播放獨立：Show Furigana = OFF
仍可播放；音訊不可用時，已儲存的 reading / Furigana 仍可顯示。

Phase 1 N5 核心 Lesson、reading 與 offline quiz 不依賴 remote TTS 或 Feedback
Service。可採 packaged reference audio、cached audio、on-device TTS，並於後續
使用 remote TTS 增強；適用階段先以 Decision Record 決定 provider / reference
audio generation、format、cache、cost / quota、licensing 與平台支援。發音不可用
須有不阻斷學習的狀態與降級行為，不得因 provider 失敗而使 Lesson 無法使用。

## 13. 學習進度、Knowledge Mastery、錯題與 Review

### 13.1 LearningProgress

LearningProgress 保留整體學習歷史：

```text
firstLearnedAt
lastReviewedAt
reviewCount
correctCount
wrongCount
masteryScore
nextReviewAt
```

### 13.2 Knowledge Mastery

`LearnerKnowledgeMastery` 是 V2.2 的核心能力模型。

每次作答後：

```text
QuizAnswer / AssessmentAnswer
 ↓
QuestionConceptMap
 ↓
更新 concept-level evidence
 ↓
LearnerKnowledgeMastery
 ↓
WeakPoint Engine
```

初版可採可解釋的加權規則：

```text
masteryScore
≈
recent performance
+ long-term performance
+ exposure / coverage
+ consistency
```

實際權重必須集中於單一 `MasteryPolicy`，不可散落在 UI 或 Repository；未經實證校準不得宣稱與官方 JLPT 能力值等價。

### 13.3 Review

MVP 先用簡單規則：

> 錯誤越多、最近越常錯、信心越低 → 越優先複習

後續再導入 spaced repetition。

錯題流程：

```text
Question
 ↓
QuizAnswer
 ↓
WrongQuestion
 ↓
ReviewItem
 ↓
Knowledge Mastery update
```

支援：

- 重新作答
- 標記已掌握
- 刪除錯題
- 依文法 / 單字 / 高錯誤率篩選
- 依最近錯誤日期排序

Review Quiz 與 Practice Quiz 同為 Learning Mode，單題提交後依 §14.1 立即回饋。
Review 中屬教學／複習呈現的日文內容使用 §7.4.1 reading metadata 與 Show
Furigana 偏好；正式題目的 Reading Aid 是否出現仍以題目設計與 Learning Policy
為準，不由 UI 自行加提示。

### 13.4 Knowledge Coverage

除了正確率，還要計算目標 JLPT 等級內容的覆蓋率：

```text
Knowledge Coverage
=
已充分評估的 KnowledgeConcept 數
÷
目標等級需要評估的 KnowledgeConcept 總數
```

Coverage 不代表 mastery；大量接觸但不熟練仍屬低準備度。

### 13.5 Learning Trend

至少保存：

```text
Current
7d
30d
All Time
```

並輸出：

```text
improving
stable
declining
insufficient_data
```

趨勢只能描述觀察到的歷史資料，不得將短期波動解讀成確定的能力變化。

## 14. Assessment Engine

Assessment 依用途區分為 Practice、Diagnostic、Benchmark 與 Mock Exam：

### 14.1 Practice Quiz

```text
目的：學習與練習
題目：可包含 AI 動態題
提示：可啟用
答案解析：單題提交後必須立即顯示
歷史比較：不作為正式能力基準
```

Practice / Review 每題提交後，依序評估正誤、播放可關閉的 correct / incorrect
feedback sound、呈現正確／錯誤狀態、使用者答案、正確答案／選項與 detailed
explanation，再進入下一題。不得只在整份 Quiz 結束後給學習回饋。音效素材、
時長、音量、動畫與 haptic 屬實作參數；聲音預設 ON / OFF 由適用階段
Decision Record 決定，使用者關閉能力已確定。Phase 1 正式離線題目使用
curated / stored explanation；AI 只能於後續 Phase 增強。

### 14.2 Diagnostic Assessment

第一次進入目標等級時，可進行 Diagnostic：

```text
選擇目標 JLPT
 ↓
Diagnostic Question Set
 ↓
Vocabulary / Grammar / Reading / Listening
 ↓
Baseline
 ↓
Knowledge Mastery 初始化
 ↓
Weak Point
 ↓
Study Plan
```

Diagnostic 的目的是建立 baseline，不宣稱可以直接換算官方 JLPT scaled score。
Diagnostic 的回饋時點及 Reading Aid 額外提示仍待 Assessment Presentation
Policy 決定；不得預設等同 Practice 或 Mock Exam。

### 14.3 Benchmark Assessment

固定版本的評估題組，用來比較使用者不同時間點的能力變化。

要求：

```text
固定 questionSetVersion
固定 scoringVersion
固定 knowledge mapping
固定難度範圍
記錄完成時間與有效性
```

Benchmark 的回饋時點及 Reading Aid 額外提示仍待 Assessment Presentation
Policy 決定；不得預設等同 Practice 或 Mock Exam。

### 14.4 Mock Exam

模擬考盡可能依當前官方 JLPT 測驗結構與時間設計，但 App 結果仍屬模擬資料。
最終 Assessment / Mock Exam abstraction 保留 N5～N1；各級別題組依內容成熟度
逐步提供，Phase 1 仍只要求 N5 Core Offline Learning，不在 Phase 1 一次建置
N1～N5 題組。Mock Exam 採固定、已驗證且可重現的 versioned question set，
不得以即時 AI 隨機題作為唯一正式題組。

作答期間僅記錄答案與 exam state，不向使用者揭露正誤、正確答案、詳解、
單題或即時總分，也不播放 correct / incorrect feedback sound。按「交卷」後先
顯示確認；取消確認返回考試，只有使用者確認後才 finalize assessment、
計算結果並進入 post-submit Result / Review Mode，顯示 overall 與 scoring section
結果、正誤、正確答案、詳解、Weak Point / Knowledge Mapping，以及適用時的
Readiness contribution。未交卷、超時與續考的細節仍依 Assessment Validity /
Presentation Policy 決定，不得以一般 Practice 的逐題揭露規則代替。

Show Furigana 是 Learning Preference，不得向 Mock Exam 正式題組注入額外
Reading Aid；只有 question set 原本定義的 Furigana / reading 可顯示。AI 可在
交卷後輔助 Review，不得改變正式答案、題組或 scoring reproducibility。

目前官方資料顯示：N1～N3 成績分成 Language Knowledge、Reading、Listening 三個 scoring sections；N4～N5 分成 Language Knowledge (Vocabulary/Grammar)・Reading 與 Listening 兩個 scoring sections。官方合格判定要求總分達到門檻，且每個 scoring section 都不能低於分區最低門檻。

目前官方門檻如下，實作時應以發布前查驗的官方資料版本為準：

| Level | Overall pass mark | Sectional pass marks |
|---|---:|---|
| N1 | 100 / 180 | Language Knowledge 19 / 60；Reading 19 / 60；Listening 19 / 60 |
| N2 | 90 / 180 | Language Knowledge 19 / 60；Reading 19 / 60；Listening 19 / 60 |
| N3 | 95 / 180 | Language Knowledge 19 / 60；Reading 19 / 60；Listening 19 / 60 |
| N4 | 90 / 180 | Language Knowledge + Reading 38 / 120；Listening 19 / 60 |
| N5 | 80 / 180 | Language Knowledge + Reading 38 / 120；Listening 19 / 60 |

來源：JLPT 官方 `Scoring Sections, Pass or Fail, Score Report`。[[Official JLPT]](https://www.jlpt.jp/e/guideline/results.html)

### 14.5 Assessment Data Model

```text
AssessmentSession
├── assessmentId
├── userId
├── targetLevel
├── mode
├── questionSetVersion
├── scoringVersion
├── startedAt
├── completedAt
├── submission / confirmation state（Mock Exam；實際欄位待資料模型設計）
├── durationSeconds
├── validityStatus
└── createdAt
```

```text
AssessmentAnswer
├── assessmentId
├── questionId
├── answer
├── isCorrect
├── responseTimeMs
├── conceptEvidence
└── createdAt
```

Mock Exam 的 `AssessmentAnswer.isCorrect` 即使供內部評分使用，交卷確認前也不得
透過 UI / API response 洩漏；`completedAt` 與最終結果須以 confirmed submission
為界。資料模型仍保留 `questionSetVersion`、`scoringVersion`、knowledge mapping、
duration、validity status 與可重現性。Schema 新增以 versioned migration 升級。

```text
AssessmentResult
├── assessmentId
├── overallRawAccuracy
├── languageKnowledgeResult
├── readingResult
├── listeningResult
├── readinessContribution
├── dataConfidence
└── createdAt
```

### 14.6 Assessment Validity

Mock / Benchmark 結果若出現以下情況，應標記為低有效性或排除於 readiness：

```text
未完成
大量跳題
超出允許時間
網路 / provider 錯誤導致題目缺失
題組版本不完整
```

不得因為「想讓使用者看到比較好看的結果」而自動修正或刪除不理想的有效成績。

未完成 Mock Exam 與使用者取消交卷確認不可誤記為已確認交卷；其 validity、
timeout、resume 與排除 Readiness 的精確規則由適用階段 Decision Record 決定。

### 14.7 Assessment Feedback Matrix

| 行為 | Practice / Review | Mock Exam | Diagnostic | Benchmark |
|---|---|---|---|---|
| 單題提交立即顯示正誤、答案與詳解 | Yes | No | Pending Assessment Policy | Pending Assessment Policy |
| Correct / Incorrect sound | Yes，可關閉 | No | Pending Assessment Policy | Pending Assessment Policy |
| Explicit submit + confirmation | 不適用於逐題回饋流程 | Required | Pending Assessment Policy | Pending Assessment Policy |
| Final result | Yes | confirmed submission 後 | 依 Assessment Policy | 依 Assessment Policy |
| Post-submit explanation | Yes（逐題已提供） | Yes | Pending Assessment Policy | Pending Assessment Policy |
| Learning Furigana / Reading Aid | 依題目設計與 Learning Policy | 只依正式題組；global setting 不注入提示 | Pending Assessment Presentation Policy | Pending Assessment Presentation Policy |

Diagnostic / Benchmark 不得自行套用 Practice 或 Mock Exam 的回饋時點。

## 15. JLPT Readiness Engine

### 15.1 目的

Readiness Engine 的目的不是預測官方考試結果，而是根據 App 自己掌握的證據，提供：

```text
目前準備程度
各能力區塊準備程度
主要風險
資料可信度
最近趨勢
下一步建議
```

### 15.2 ReadinessSnapshot

```text
ReadinessSnapshot
├── snapshotId
├── userId
├── targetLevel
├── overallReadiness
├── languageKnowledgeReadiness
├── readingReadiness
├── listeningReadiness
├── masteryCoverage
├── assessmentEvidence
├── recentTrend
├── consistency
├── dataConfidence
├── weakPointCount
├── generatedAt
└── scoringPolicyVersion
```

### 15.2.1 Readiness Status

`overallReadiness` 必須搭配狀態，不用單一數字製造過度精確的感覺：

```text
insufficient_data
developing
needs_improvement
near_ready
ready_with_buffer
```

狀態由 Readiness、Data Confidence、Critical Section Gate 與最近趨勢共同決定。`ready_with_buffer` 只表示 App 目前觀察到的準備證據較完整，不代表保證通過。

### 15.2.2 Study Goal

使用者可設定：

```text
StudyGoal
├── goalId
├── userId
├── targetLevel
├── targetExamDate（optional）
├── weeklyStudyMinutes
├── targetMode
└── status
```

若有 `targetExamDate`，Study Plan 可根據剩餘時間調整每日建議量；若無考試日期，使用一般穩定學習節奏。

N4/N5 沒有獨立的 Reading scoring section 時，UI 應依官方 scoring structure 呈現，不要假造第三個官方分數區。App 內仍可另外維護 Reading skill analytics。

### 15.3 初版 Readiness 模型

Readiness 先採 0～100 的 App 內部指標：

```text
Assessment Evidence
        55%
Mastery Coverage / Mastery
        25%
Recent Trend
        10%
Consistency
        10%
--------------------------
Overall Readiness
```

上述權重是產品初版的工程假設，不是 JLPT 官方權重，也不是統計學上的官方通過機率。所有權重集中在 `ReadinessPolicy`，後續可使用實際 Mock / Official Exam Result 校準。

### 15.4 Section Gate

因為 JLPT 有分區最低門檻，Readiness 不應只看總平均。

```text
Overall Readiness
        │
        ├── Section Readiness
        │      ├── Language Knowledge
        │      ├── Reading（若該 level 為獨立 scoring section）
        │      └── Listening
        │
        └── Weakest Critical Section
```

如果某個必要能力區塊的 evidence 明顯不足或低於 App 自定的 safety threshold，UI 應將整體狀態標記為「仍有明顯風險」，而不是用平均分數掩蓋分區弱點。

### 15.5 Data Confidence

至少提供：

```text
Insufficient Data
Low
Medium
High
```

Confidence 應根據：

```text
有效評估題數
KnowledgeConcept 覆蓋率
Benchmark / Mock 次數
最近一次有效評估距今天數
結果穩定度
```

這些是 App 的資料品質指標，不代表統計學上的信賴區間。

### 15.6 Readiness UI

首頁核心區域建議：

```text
JLPT N5

通過準備度
████████░░ 78

資料可信度：Medium
趨勢：Improving

Language Knowledge + Reading   84
Listening                       66

最需要加強
1. て形相關文法
2. 日期 / 時間單字
3. Listening 短對話

今日建議
文法 15 min
單字 10 min
聽力 10 min
```

UI 上必須標示這是「App 內部準備度估計」，不是官方 JLPT 分數或保證通過。

## 16. Weak Point Engine 與 Study Plan

### 16.1 Weak Point

Weak Point 必須以 KnowledgeConcept 為核心，而不是只有題目編號。

```text
WeakPoint
├── weakPointId
├── userId
├── conceptId
├── priorityScore
├── reason
├── evidenceCount
├── masteryScore
├── trend
├── affectedSection
├── recommendedMinutes
├── createdAt
└── resolvedAt
```

### 16.2 初版 Weakness Priority

```text
priority
≈
(1 - mastery)
× importance
× recencyWeight
× evidenceConfidence
```

其中 `importance` 可由目標 JLPT level、section relevance、concept coverage 等決定。實際規則集中於 `WeakPointPolicy`。

### 16.3 Weak Point 必須可解釋

例如：

```text
弱點：て形文法

原因：
最近 20 題答對率 55%
錯誤集中在動詞變化
最近一次模擬評估仍出錯

建議：
複習 て形規則
→ 10 題基礎題
→ 5 題情境題
→ 隔日再測
```

使用者應可點擊弱點查看「哪些題目造成這個判定」。

### 16.4 StudyPlan

```text
StudyPlan
├── planId
├── userId
├── targetLevel
├── generatedAt
├── validUntil
├── strategyVersion
└── status
```

```text
StudyPlanItem
├── itemId
├── planId
├── conceptId
├── activityType
├── targetMinutes
├── targetQuestionCount
├── priority
├── reason
├── dueAt
└── status
```

### 16.5 Study Plan 內容

活動類型：

```text
learn
review
practice
listening
speaking
assessment
mock_exam
```

其中 `speaking` 可以加入整體學習計畫，但不直接提高或降低官方 JLPT Readiness scoring。

### 16.6 再評估

```text
StudyPlan
 ↓
完成指定活動
 ↓
Mini Assessment / Benchmark
 ↓
更新 Mastery
 ↓
更新 Weak Point
 ↓
重新計算 Readiness
 ↓
產生下一版 StudyPlan
```

## 17. Data Reset / Delete


Settings → Data Management：

```text
重置今日進度
重置測驗紀錄
清除錯題
清除學習歷程
清除 Speaking 歷史
清除 AI 產生的本地 Cache
全部重置學習資料
Factory Reset（進階）
```

### 17.1 Reset Scope

| 動作 | Content Data | User Learning State | App Setting | Account / Cloud |
|---|---:|---:|---:|---:|
| 重置今日進度 | 保留 | 清除今日狀態 | 保留 | 不處理 |
| 重置測驗紀錄 | 保留 | 清除 Quiz Session / Answer | 保留 | 不處理 |
| 清除錯題 | 保留 | 清除 WrongQuestion | 保留 | 不處理 |
| 清除學習歷程 | 保留 | 清除 Progress / Review | 保留 | 不處理 |
| 清除 Speaking 歷史 | 保留 | 清除 SpeakingResult | 保留 | 不處理 |
| 清除 AI Cache | 保留 | 清除本地 generated cache | 保留 | 不處理 |
| 全部重置學習資料 | 保留 | 清除所有學習狀態 | 保留 | 不處理 |
| Factory Reset | 可選刪除本地 Content | 清除 | 恢復預設 | 若有帳號需另行刪除 |

### 17.2 所有學習資料重置

```text
使用者選擇
 ↓
顯示影響範圍
 ↓
二次確認
 ↓
明確警告不可復原
 ↓
執行 Transaction
 ↓
Rebuild / Recalculate derived state
 ↓
顯示完成結果
```

### 17.3 Reset 與 Account Deletion 分離

```text
Reset Learning Data
≠ Delete Account
≠ Delete Server Data
```

加入雲端後，Server Data deletion 必須有獨立流程。
§7.4.1 的 Show Furigana 與 Feedback Sound 偏好均屬 App Setting，依 §17.1
Reset Learning Data 保留、Factory Reset 恢復預設。Feedback server-side 資料的
刪除與留存不可由本地 Learning Data Reset 推定，須依適用階段隱私決策制定。

## 18. Backend / AI Gateway

### 18.1 Phase 1

不需要 Backend，SQLite 可獨立運作。

### 18.2 Phase 2 開始

加入最小 AI Gateway：

```text
Flutter
 ↓ HTTPS
ASP.NET Core
 ├── /api/ai/explain
 ├── /api/ai/generate-question
 ├── /api/ai/transcribe
 └── /api/ai/evaluate-speaking
       ↓
   Provider Adapter
       ↓
     OpenAI
```

此階段仍不需要登入、不需要 PostgreSQL。

### 18.3 Phase 5

再增加：

```text
User Account
Authentication
Cloud Sync
PostgreSQL
Backup
Usage Quota
Server-side User Data Deletion
Remote Content / Question Catalog
Feedback storage / aggregation / Developer disposition（依 §33）
```

### 18.4 Backend 原則

```text
Flutter
 ↓ HTTPS
API
 ↓
Application
 ↓
Domain
 ↓
Infrastructure
 ↓
PostgreSQL
```

AI Provider 不直接從 Domain 層散落呼叫；統一由 AI Gateway / Provider Adapter 管理。

## 19. Python

Python 不負責主要 UI。

用途：

```text
python/
├── importers/
├── content_pipeline/
├── validators/
├── question_generation/
├── duplicate_detection/
├── data_cleaning/
├── export/
├── analytics/
└── migration_tools/
```

例如：

```text
Canonical Content JSON
 ↓
Python
 ↓
Schema Validation
 ↓
Content Governance Checks
 ↓
Duplicate Detection
 ↓
Question Validation
 ↓
SQLite Seed / Release Package
```

Python 產出的資料必須帶 `contentVersion`。

## 20. C# / ASP.NET Core

後端採：

```text
Api
Application
Domain
Infrastructure
Tests
```

AI Gateway 建議：

```text
Api
 ↓
Application / AI Use Cases
 ↓
AI Gateway
 ↓
Provider Adapter
 ↓
External AI API
```

一般雲端資料則：

```text
API
 ↓
Application
 ↓
Domain
 ↓
Infrastructure
 ↓
PostgreSQL
```

## 21. Git / GitHub

Branch：

```text
main
develop
feature/*
fix/*
```

Commit：

```text
feat:
fix:
refactor:
test:
docs:
chore:
```

重要規則：

```text
main → 可建置 / 可發布
feature → 小範圍功能
大變更 → PR + Review
Schema 變更 → Migration + Test
```

## 22. Codex + ChatGPT

Codex 作為主要 AI Coding Agent。

流程：

```text
ChatGPT
 ↓
需求分析
 ↓
Technical Design
 ↓
Task Breakdown
 ↓
Codex
 ↓
Implement
 ↓
Run Tests
 ↓
Codex Review
 ↓
Human Review
 ↓
Git Commit / PR
```

建立：

```text
AGENTS.md
```

內容：

```text
Project Goal
Architecture
Coding Rules
Flutter Rules
Dart Rules
Backend Rules
Testing Rules
Git Rules
Security Rules
AI Rules
Content Governance Rules
Privacy Rules
Definition of Done
```

規則：

1. 不任意新增大型 dependency
2. Schema 修改必須同步 migration
3. 不刪除測試來讓測試通過
4. API Key / Secret 不可進 source control
5. 修改功能補測試
6. 執行 formatter
7. 執行 analyzer
8. 執行相關 tests
9. 不直接複製第三方教材
10. AI 生成內容不能跳過 validator
11. Speaking / AI log 不保存不必要的敏感資料
12. 大型重構先提出計畫

## 23. Flutter Coding Standards

必須：

```text
dart format
flutter analyze
flutter test
```

需要時：

```text
flutter test integration_test
```

原則：

- sound null safety
- 避免不必要 dynamic
- Model 優先 immutable
- UI 與資料存取分離
- Repository abstraction
- Service abstraction
- Use Case 承載 business logic
- Widget 避免大量 business logic
- dependency injection
- 統一錯誤處理
- 統一 logging
- Responsive UI
- Accessibility / permission state 明確

## 24. Testing

### Unit Test

```text
Quiz scoring
Progress calculation
Review scheduling
Question validation
Duplicate detection
Repository
Reset scope
AI response parsing
Speaking result parsing
Knowledge mastery update
Assessment validity
Readiness calculation
Readiness section gate
Weak point priority
Study plan generation
Furigana default / setting persistence / mixed Kanji-Kana alignment / contextual reading
Audio unavailable fallback / context reading / provider failure isolation
Practice / Review per-question feedback / sound setting / offline explanation
Mock Exam pre-submit disclosure suppression / confirmed submission / validity preservation
Feedback classification boundary / Developer disposition authorization / privacy policy
```

### Widget Test

```text
LessonPage
QuizPage
QuizResultPage
ProgressPage
SpeakingPage
SettingsDataManagementPage
ReadinessDashboardPage
WeakPointsPage
StudyPlanPage
AssessmentResultPage
Learning Settings / Furigana / Audio state
Practice / Review immediate feedback and explanation
Mock Exam confirmation / post-submit review
Problem Report page（適用階段）
```

### Integration Test

```text
開啟 App
 ↓
選課程
 ↓
完成測驗
 ↓
建立錯題
 ↓
更新進度
 ↓
進入 Review
 ↓
Reset Learning Data
 ↓
確認 Content Data 保留
```

Phase 1 / Slice A 同一流程應檢查：教學 Furigana 預設 ON、關閉與重啟持久化、
Audio 與 Furigana 獨立、發音不可用時 Lesson 可繼續、逐題正誤／答案／音效／
離線詳解，以及 Reset Learning Data 保留 App Setting。

第二條：

```text
Lesson
 ↓
AI Explanation
 ↓
AI Generate 5 Questions
 ↓
Schema Validation
 ↓
Quiz
 ↓
AI Answer Explanation
```

第三條：

```text
Diagnostic Assessment
 ↓
Baseline
 ↓
Knowledge Mastery
 ↓
Readiness
 ↓
Weak Point
 ↓
Study Plan
```

第四條：

```text
完成 Study Plan
 ↓
Benchmark Assessment
 ↓
比較前後 Readiness
 ↓
確認弱點是否改善
```

第五條：

```text
Speaking Exercise
 ↓
Microphone Permission
 ↓
Record
 ↓
STT
 ↓
Text Comparison
 ↓
Speaking Evaluation
 ↓
SpeakingResult
 ↓
Retention Policy
```

Phase 2.5 Mock Exam 流程須驗證：作答期間無正誤、答案、詳解、分數與回饋音效；
交卷確認可取消；確認後才 finalize 與揭露結果／詳解；固定題組版本、知識映射、
有效性與 Furigana 隔離保持一致。Feedback Phase 須驗證回報提交、狀態、
聚合邊界、Developer disposition、AI 建議不能自動套用，以及隱私政策。

CR-0001 的相關測試至少涵蓋：

- Furigana：預設 ON、OFF 與重啟持久化；切換不改正文或音訊可用性；離線
  reading、多漢字詞、漢字／假名混合、送り仮名與句子 context；手機／Windows
  responsive 與字級縮放；Mock Exam 不受 global setting 注入提示；Reset
  Learning Data 保留設定。
- Audio：發音動作可用、詞／句 context 正確、音訊 unavailable 或 provider
  failure 時 Lesson / offline quiz 仍可完成，已儲存 Furigana 仍顯示。
- Practice / Review：答對與答錯均立即回饋，對應音效可區分且可關閉；使用者
  答案、正確答案與 detailed explanation 顯示；離線仍有 curated explanation。
- Mock Exam：作答期無答案、解析、正誤、分數及回饋音效；明確交卷、確認與
  取消確認；confirmed submission 後才 finalize 和揭露結果／詳解；版本、
  validity、knowledge mapping 及 Furigana 題組隔離可重現。
- Feedback：回報類型與提交、status、分類／跨使用者聚合邊界、Developer
  disposition；AI recommendation 無權自動套用 Requirement；敏感欄位依
  已核准政策處理。未決政策於 Phase 5 導入前完成 Decision Record。

## 25. CI/CD

GitHub Actions：

```text
Push / Pull Request
 ↓
dart format check
 ↓
flutter analyze
 ↓
flutter test
 ↓
Backend build / test（存在時）
 ↓
Python test / lint（存在時）
 ↓
Build Windows
 ↓
Build Android
```

iOS：

```text
macOS runner
 ↓
Flutter build
 ↓
Xcode signing
 ↓
TestFlight / App Store
```

CI 不允許因為測試失敗而跳過測試直接產生 release build。

## 26. Docker

MVP 不需要 Docker。

Phase 2 AI Gateway 可選擇使用 Docker 進行本機 Backend 開發；Phase 5 正式雲端則建議：

```text
api
postgres
optional tools
```

使用 Docker Compose 管理開發服務。

## 27. MVP / Phase 1 — Core Offline Learning

第一階段：

```text
Flutter
SQLite
N5
```

功能：

- 首頁
- 課程列表
- 文法
- 單字
- 基本漢字
- 基本例句
- 基本測驗
- 測驗結果
- 錯題
- 學習進度
- Review
- Reset Learning Data
- 教學 Reading metadata 與預設 ON、可關閉的 Furigana；設定重啟後保留
- Vocabulary、Kanji context、Example Sentence、Grammar Example 與 Lesson 發音能力及 Audio abstraction
- Practice / Review 單題正誤、可關閉音效、答案與離線 curated explanation

不做：

- 登入
- 雲端同步
- PostgreSQL
- 複雜 AI 個人化
- AI Speaking Evaluation

但是資料模型要預留未來 AI / Speaking / Cloud 所需欄位與 migration 策略。
Phase 1 的教材、reading、詳解與離線測驗不依賴遠端 AI / TTS；音訊 unavailable
時仍可完成 Lesson 與 Quiz。Furigana／音訊的具體 implementation parameter
依 §38.11 在適用開發前決定，不得因此擴張為 N1～N5 全部教材或 Mock Exam。

## 28. Phase 1.5 — Vertical Slice A

完成第一條可獨立展示與測試的核心流程：

```text
App Start
 ↓
N5 Lesson List
 ↓
Lesson Detail
 ↓
開始 5 題測驗
 ↓
提交答案
 ↓
計算分數
 ↓
建立錯題
 ↓
更新學習進度
 ↓
進入 Review
 ↓
Reset Learning Data
 ↓
確認教材仍保留
```

此 Slice 及回歸須覆蓋 reading metadata、context-sensitive Furigana ON / OFF、
設定持久化、Furigana 與 Audio 獨立、Practice / Review 逐題回饋與離線詳解，
以及 Reset 不誤刪 Content Data／不誤改 App Setting。

完成後才擴充大量內容。

同階段建立：

```text
KnowledgeConcept
QuestionConceptMap
LearnerKnowledgeMastery
AssessmentSession / Result
ReadinessSnapshot schema
```

先建立資料模型與最小計算框架，避免 Phase 4 才大幅重構資料庫。

## 29. Phase 2 — AI Gateway + AI 題庫

### 29.1 技術

```text
Flutter
SQLite
ASP.NET Core AI Gateway
OpenAI Provider
```

### 29.2 功能

```text
AI Question Generator
AI Explanation
AI Example Generator
Question Validator
Question Cache
Question Versioning
Usage Limits
```

### 29.3 Vertical Slice B

```text
Lesson
 ↓
AI Explanation
 ↓
AI Generate 5 Questions
 ↓
JSON Schema Validation
 ↓
Rule Validation
 ↓
Duplicate Detection
 ↓
SQLite Cache
 ↓
Quiz
 ↓
AI Explanation of Answer
```

AI 可增加 alternative explanation、reading candidate validation 或 remote /
provider audio enhancement；既有 curated explanation 與基本 reading 不以
Gateway 為唯一 runtime 依賴。Gateway 關閉時 Phase 1 / Slice A 仍可運作。

## 30. Phase 2.5 — Assessment Engine

```text
Diagnostic Assessment
Benchmark Assessment
Mock Exam
Assessment Versioning
Assessment Validity
Readiness Snapshot v0
```

此階段實作 Mock Exam 與 §14.7 Feedback Matrix：作答期間抑制正誤／答案／
詳解／分數／音效，明確交卷與確認，取消確認返回考試，確認後才揭露結果與
詳解；Show Furigana 不向固定正式題組注入提示。保留 N5～N1 Assessment
abstraction，實際各級別題組隨內容成熟度逐步提供。Diagnostic / Benchmark
回饋時點先由 Assessment Presentation Policy 決定。

完成後，使用者第一次就能看到 baseline；累積足夠資料後，才能顯示較完整的 Readiness。

Vertical Slice B.5：

```text
Diagnostic
 ↓
AssessmentResult
 ↓
KnowledgeMastery
 ↓
WeakPoint
 ↓
ReadinessSnapshot
 ↓
StudyPlan
```

## 31. Phase 3 — Speaking

```text
Microphone Permission
 ↓
Audio Recording
 ↓
STT
 ↓
Expected / Actual Text Comparison
 ↓
Speech Correctness
 ↓
Speaking Evaluation
 ↓
SpeakingResult
```

### Vertical Slice C

```text
Speaking Exercise
 ↓
TTS / Reference Audio
 ↓
User Recording
 ↓
STT
 ↓
Text Accuracy
 ↓
Pronunciation / Fluency Evaluation（可用時）
 ↓
Feedback
 ↓
History
```

## 32. Phase 4 — Readiness / Personalization

```text
Learning Analytics
Knowledge Mastery
Assessment Analytics
Readiness Engine
Weak Point Detection
Spaced Repetition
Personalized Quiz
Daily Learning Plan
Adaptive Difficulty
```

優先順序：

```text
學習紀錄
 ↓
Knowledge Mastery
 ↓
Diagnostic / Benchmark / Mock
 ↓
Readiness Engine
 ↓
弱點偵測
 ↓
Review Scheduler
 ↓
Personalized Quiz
 ↓
Daily Plan
 ↓
再次 Assessment
```

Phase 4 不只做推薦，而是完成「評估 → 解釋 → 行動 → 再評估」閉環。

## 33. Phase 5 — Cloud

```text
ASP.NET Core
PostgreSQL
Authentication
Cloud Sync
Backup
AI Gateway
Usage Quota
Remote Content
Feedback backend / 跨使用者聚合 / Developer disposition
```

### Sync 原則

```text
Local State
 ↓
Change Tracking
 ↓
Sync Queue
 ↓
HTTPS API
 ↓
Server
 ↓
Conflict Resolution
```

第一版同步策略應簡單、可解釋，不在一開始導入複雜 CRDT / offline conflict engine。

### 33.1 問題回報與改善建議

App 須提供使用者可存取的「問題回報」頁面，至少能回報功能、教材、題目、
答案／解析、音訊／發音、UI / UX 與其他產品問題。Feedback lifecycle：

```text
User Problem Report
→ FeedbackReport
→ 分類 / 去重 / 跨回報聚合（FeedbackCluster）
→ AI Summary / ImprovementSuggestion
→ Developer Review
→ DeveloperDisposition：pending / accepted / deferred / rejected
```

`FeedbackReport` 即提交後的 Feedback Record。概念資料須能追蹤 app version、
platform、feature / area、created time、report status；FeedbackReport、
FeedbackCluster、ImprovementSuggestion 與
DeveloperDisposition 的實際 schema / ownership 由適用 Phase Decision Record
決定。跨多位使用者的儲存與聚合需要 server-side capability，安排於 Phase 5
Cloud-capable 範圍；Phase 1 不要求 feedback backend、跨使用者 AI clustering，
核心離線 Lesson 與 Quiz 不以 Feedback Service 作為啟動依賴。

AI Agent 只可分類、去重、聚合、識別重複問題、歸納趨勢及提出改善建議；
不得修改 Current Approved Spec、將回報自動提升為 Requirement、決定 accepted /
rejected、建立正式 implementation scope，或指示 Codex 自動實作。User Feedback、
AI Summary 與 ImprovementSuggestion 均非產品 Requirement；只有 Developer
明確接受的改善方向，才可依既有 CHANGE_REQUEST → Candidate Spec → Developer
Review / Approve → Repository → APPLIED 流程進入 implementation。

匿名或帳號關聯、附件／截圖、diagnostics / logs、敏感資訊過濾、retention、
Developer management UI 與 backend storage design 均屬 §38.11 Pending Decision。
未決政策不得硬編碼；不得把上傳的敏感內容直接送 AI 或永久保存。

## 34. Privacy / Security / Data Lifecycle

### 34.1 禁止

```text
API Key hard-code
Password hard-code
Token commit
Private data log
Unauthorized audio retention
```

### 34.2 Log 禁止

```text
API Key
Authorization Header
完整錄音內容
不必要的完整 transcript
敏感使用者資料
未經過濾的 Feedback 敏感原文 / 附件
```

### 34.3 Data Lifecycle

```text
Collect
 ↓
Process
 ↓
Store only what is needed
 ↓
Use for stated feature
 ↓
Retention period
 ↓
Delete
```

### 34.4 AI Data Minimization

原則：

```text
必要資料才送 AI
不送無關使用者歷史
盡量送結構化 / 最小化資料
原始錄音預設不永久保存
```

Feedback 可能包含個人資訊、截圖或 diagnostics；在確定蒐集範圍、過濾、
留存、刪除與 AI 最小化傳送政策之前，不得假定可收集或共享。使用者回報頁面
與後端聚合須遵守資料生命週期及 Developer 核准的隱私政策。

### 34.5 Permission

涉及以下功能時，要有清楚的 permission state：

```text
Microphone
Audio Recording
Notification（如未來使用）
```

拒絕 Permission 時，核心學習功能仍應正常運作。

## 35. Account / Data Deletion（Phase 5）

若未來加入帳號：

```text
Delete Account
 ↓
Explain what will be deleted
 ↓
Confirm
 ↓
Delete / Anonymize server data according to policy
 ↓
Invalidate sessions / tokens
 ↓
Clear local user data
 ↓
Show result
```

明確區分：

```text
Reset Learning Data
Delete Local Data
Delete Cloud Data
Delete Account
```

## 36. 成本控制

主要成本：

```text
AI Provider API
Speech / Audio Provider（若計費）
Apple Developer
Google Play（若發布）
Server（Phase 2 / Phase 5）
```

降低 AI 成本：

1. 題目預生成
2. Cache
3. SQLite 保存
4. 避免重複生成
5. 簡單工作使用低成本模型
6. 高階模型只處理需要推理的工作
7. Python 批次生成
8. Schema validation
9. 限制單次 token / payload
10. 原始錄音預設不永久保存
11. 對 AI Gateway 設定 rate limit / usage quota
12. 記錄模型與版本，避免不必要的重新生成

## 37. 開發環境

### VS Code

主要：

```text
Flutter
Dart
Python
YAML
Docker
Git
Codex
```

### Visual Studio 2026

保留：

```text
C#
ASP.NET Core
.NET
Flutter Windows toolchain
```

開發配置：

```text
Windows
→ Flutter / Windows / Android / C# / Python / DevOps

Mac
→ iOS build / signing / TestFlight / App Store
```

## 38. 實際開發順序與階段閘門

本節是 Phase 的唯一執行順序。若其他段落的順序表述有歧義，依本節執行；各 Phase 功能範圍仍依對應章節。

### 38.1 唯一開發順序

```text
Phase 0 — 開發前準備
Phase 1 — Core Offline Learning
Phase 1.5 — Vertical Slice A + Knowledge / Assessment 基礎資料模型
Phase 2 — AI Gateway + AI 題庫（Vertical Slice B）
Phase 2.5 — Diagnostic / Benchmark / Mock Exam / Readiness v0（Vertical Slice B.5）
Phase 3 — Speaking（Vertical Slice C）
Phase 4 — Readiness / Personalization 完整閉環
Phase 5 — Cloud
```

Phase 1.5 先建立後續 Assessment 所需的資料結構和最小概念證據更新能力；完整 Diagnostic、Benchmark、Mock Exam、Readiness 使用流程於 Phase 2.5 實作。Phase 2 先於 2.5，因 AI Gateway 不依賴 Readiness。

### 38.2 Phase 0 — 開發前準備

```text
1. 確認 repository 根目錄與 Git 工作樹狀態，保留既有修改
2. 將本規格放入 repository 並指定為主要產品規格
3. 固定 Flutter / Dart / .NET / Python SDK 與依賴版本策略
4. 設定 Git 分支策略與忽略檔
5. 建立 AGENTS.md，摘錄架構、限制、測試與 DoD
6. 建立 Flutter project、平台 target、App Shell 與最小 CI
7. 建立 SQLite migration framework
8. 登錄尚未決定的政策；不得由 Codex 猜測後寫死
```

完成閘門：乾淨 checkout 可重現 App Shell 建置；版本與本機開發步驟已記錄；CI 基本工作可執行；待決策項目已登錄。

### 38.3 Phase 1 — Core Offline Learning

完成第 27 節 N5 核心離線功能及第 17 節 Reset。

完成閘門：離線完成課程、測驗、結果、錯題、進度及 Review；重啟後資料仍在；Reset scope 不誤刪 Content Data。N5 教學 reading / Furigana 預設 ON、關閉與持久化可驗證；context-sensitive 發音能力、Audio unavailable fallback、Practice / Review 逐題正誤／可關閉音效／答案／離線詳解可驗證；Reset Learning Data 不誤改設定。適用測試、`dart format`、`flutter analyze` 通過。

### 38.4 Phase 1.5 — Vertical Slice A 與基礎模型

完成第 28 節 Slice A，建立 `KnowledgeConcept`、`QuestionConceptMap`、`LearnerKnowledgeMastery`、`AssessmentSession`、`AssessmentAnswer`、`AssessmentResult` 與 `ReadinessSnapshot` 的必要 schema。此階段不要求完整 Assessment UI 或 Readiness 結論。

完成閘門：Slice A 可從啟動跑到 Reset；正式題目有主要 KnowledgeConcept mapping；migration 可升級 Phase 1 資料；原始作答可重建 Derived Analytics；reading metadata、Furigana ON / OFF、設定持久化、Audio 獨立、逐題回饋／詳解及 Reset 設定範圍納入資料庫與 Slice A 回歸。

### 38.5 Phase 2 — AI Gateway 與題庫

完成第 29 節 Gateway、AI 題目/解釋、Validator、Cache、Versioning 與 Slice B。

完成閘門：Provider Secret 不在 App；題目通過 JSON Schema、規則、答案一致性與去重後才可使用；Gateway 不可用時 Phase 1 / Slice A 的 reading、Lesson 與 curated explanation 仍可離線運作；動態 AI 題不能充當固定 Assessment 題組；後端與 Flutter 相關建置/測試通過。

### 38.6 Phase 2.5 — Assessment 與 Vertical Slice B.5

完成第 30 節 Diagnostic、Benchmark、Mock Exam、Assessment Versioning/Validity、Readiness v0、Weak Point、Study Plan 與 Slice B.5。

完成閘門：Assessment 可追溯題組及評分版本；無效結果不作有效 Readiness 證據；資料不足顯示 `insufficient_data`；Readiness 明確標示為 App 估計；必要分區風險不被總平均掩蓋；弱點可追溯到概念與作答。Mock Exam 交卷前不揭露回饋，確認後才 finalize 並顯示結果／詳解，取消確認返回作答，Show Furigana 不注入額外提示；相關 Unit/Widget/Integration Tests 通過。

### 38.7 Phase 3 — Speaking

完成第 31 節 Slice C。Speech correctness 與發音/流暢度評估分開；不支援的指標可為 unavailable/null；拒絕麥克風權限不阻擋核心學習。

完成閘門：Slice C 流程可驗證；錄音保留政策可驗證；Speaking 不改變 JLPT Readiness；Slice A、B、B.5 回歸通過。

### 38.8 Phase 4 — Readiness / Personalization

完成第 32 節 Coverage、Trend、Readiness v1、弱點、Review Scheduler、Personalized Quiz、Daily Plan、Adaptive Difficulty 與再評估閉環。

完成閘門：Study Plan 後可再評估並更新 Mastery、Weak Point、Readiness 與下一版 Plan；Coverage 與 Mastery 分開；資料不足和政策版本可追溯；相關測試與既有 Vertical Slice 回歸通過。

### 38.9 Phase 5 — Cloud

完成第 33 節帳號、Authentication、PostgreSQL、Cloud Sync、Backup、Usage Quota 與伺服器端刪除。

完成閘門：離線核心仍可用；同步、衝突處理、備份和刪除範圍可重現驗證；Reset、Local Delete、Cloud Delete、Account Delete 分離；Feedback 頁面、server-side 分類／聚合、AI 建議與 Developer disposition 可驗證，AI 不可自動將建議變成 Requirement；Feedback 隱私／留存政策已決定並可驗證；後端 migration/tests 與本地 Vertical Slice 回歸通過。

### 38.10 Codex 階段執行規則

每次任務限一個 Phase 或一個可驗收 Vertical Slice。開始前閱讀本規格、`AGENTS.md`、Git 狀態及現有測試；先列出依賴與修改範圍；完成後回報修改、migration、驗證結果、待決策與前階段回歸結果。

規格未定義的規則不得自行猜測並固化。Codex 應列明缺少的決策與影響，先完成不依賴該決策的工作；若決策會改變資料格式、對外承諾或不可逆行為，暫停該部分並回報。

每個 Slice 使用可 review 的分支/commit 群組。Schema 變更必須同一交付包含 migration 與資料庫測試。Commit 類型使用 `feat:`、`fix:`、`refactor:`、`test:`、`docs:`、`chore:`。

### 38.11 待決策登錄表

下列項目含 V2.2 未具體定義的參數與 CR-0001 新增需求的未決參數。
開始相應功能前，以 Decision Record 記錄決策、理由、日期及適用的
policy/version；不得散落硬編碼。

| 項目 | 需決定的內容 | 最晚決策階段 |
|---|---|---|
| KnowledgeConcept identity | ID 格式、內容改版後是否沿用 concept ID | Phase 1.5 |
| QuestionConceptMap | 權重範圍、合計規則、主要概念限制 | Phase 1.5 |
| MasteryPolicy | 加權公式、最低證據量、狀態切換條件 | Phase 1.5/2.5 |
| Assessment 題組 | 各模式/級別題數、題型、抽題規則 | Phase 2.5 |
| Assessment validity | 超時、跳題、缺題、重複作答門檻 | Phase 2.5 |
| ReadinessPolicy | Section safety threshold、狀態切分、權重與版本遷移 | Phase 2.5 |
| Data Confidence | 各信心級別所需題數、覆蓋率、次數與時效 | Phase 2.5 |
| WeakPointPolicy | importance、recency、confidence 尺度與最低證據 | Phase 2.5 |
| Study Plan 排程 | 每日/每週量、考期接近時的調整與排序 | Phase 2.5/4 |
| 官方 JLPT 資料 | 發布前核對日期、分區及門檻版本 | 發布前 |
| SDK / providers | SDK 版本與 AI / Speaking / STT 等 phase-specific provider、平台支援及成本限制；Phase 1 Learning Audio 依下一列 | SDK：Phase 0；其餘於對應 Phase 導入前 |
| Learning Audio delivery | Reference Audio / on-device / remote TTS 組合、provider、format、cache、授權、成本／quota、平台支援 | Phase 1 導入發音前；遠端增強於對應 Phase 前 |
| Furigana data / rendering | alignment 與句子 segmentation 格式、ruby rendering 細節；不改預設 ON | Phase 1 |
| Practice / Review feedback | 音效素材、音量／時長、預設 ON / OFF、haptic、動畫、各題型 Reading Aid 政策 | Phase 1 |
| Assessment Presentation Policy | Diagnostic / Benchmark 回饋時點與額外 Furigana；Mock Exam 已定義不得提前揭露 | Phase 2.5 |
| Mock Exam execution | 各級別題數、官方時限、section transition、未完成／timeout／resume 的精確 validity 規則與 rollout | Phase 2.5 導入對應模式／級別前 |
| Feedback / Privacy | anonymous / account-linked、附件／截圖、logs、過濾、retention、developer UI、backend storage 與刪除範圍 | Phase 5 Feedback 功能前 |

本表登錄 V2.2 已提及但未具體決定的實作參數，以及 CR-0001 新增需求中
尚未決定的實作／政策參數；不將未決事項視為已批准的產品行為。已決定項目
須標記完成並保留決策紀錄。Show Furigana 預設 ON、可關閉、Mock Exam 交卷前
不揭露，以及 Practice / Review 可關閉回饋音效均為已確認需求，非未決參數。
## 39. 最終架構

```text
                         JLPT Learning App
                                  │
                         Flutter / Dart
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
           Windows              Android               iOS
              │                   │                   │
              └───────────────────┼───────────────────┘
                                  │
                         Presentation / MVVM
                                  │
                           Domain / Use Case
                                  │
                        Repository / Services
                         ┌────────┴────────┐
                         │                 │
                    Local-first         Online
                         │                 │
                      SQLite            HTTPS
                         │                 │
          ┌──────────────┼────────────┐  ASP.NET Core
          │              │            │  AI Gateway / API
      Content Data    User State  Derived Analytics
          │              │            │      │
      Knowledge      Learning     Readiness  │
      Concept       Assessment    WeakPoint  │
      Provenance    Results       StudyPlan  │
                         \               ┌───┴────┐
                          \              │        │
                           └────────── OpenAI  PostgreSQL
                                                Phase 5
                        
                     Python
                   Data / ETL
                        │
                 Content Pipeline
                        │
                Git / GitHub / CI
                        │
                 Codex + ChatGPT
```

## 40. Definition of Done

每個功能至少需要：

```text
[ ] 需求明確
[ ] UI 完成
[ ] Model / Entity 完成
[ ] Use Case 完成
[ ] Repository 完成
[ ] Service / Gateway 完成（需要時）
[ ] Database migration 完成（需要時）
[ ] 錯誤處理完成
[ ] Loading / Empty / Error state
[ ] Unit Test
[ ] Widget Test（需要時）
[ ] Integration Test（需要時）
[ ] Privacy / Permission 檢查（需要時）
[ ] flutter analyze
[ ] dart format
[ ] Git diff review
[ ] Codex review
[ ] Human review
[ ] CR-0001 適用功能的 Furigana / Audio / Feedback / Mock Exam 行為與離線降級已驗證
[ ] Learning Preference 不改寫正式 Mock Exam 題組；交卷前沒有答案洩漏
[ ] Feedback AI 建議須經 Developer 決策，敏感資訊依已核准政策處理
```

AI 功能另外需要：

```text
[ ] JSON Schema
[ ] Rule Validation
[ ] Duplicate Detection
[ ] Version metadata
[ ] Cost / usage limit
[ ] Sensitive data review
[ ] Readiness policy version
[ ] Assessment version metadata
[ ] Knowledge mapping completeness
```

## 41. V2.4 結論

本專案技術主軸維持：

```text
Flutter + Dart
      +
C# / ASP.NET Core
      +
Python
      +
SQLite
```

其中：

- Flutter 負責 Windows / Android / iOS 跨平台 App
- SQLite 負責 Local-first 核心學習、測驗與使用者狀態
- ASP.NET Core 從 AI Phase 起作為 AI Gateway，後續再擴充完整 Backend
- PostgreSQL 延後到 Cloud Phase
- Python 負責 Content Pipeline、ETL、題庫生成、驗證與分析

V2.3 延續 V2.2 的產品核心：

```text
Content
Learning
Assessment
Analytics
Readiness
Recommendation
```

組成完整閉環：

> Learn → Practice → Assess → Analyze → Weak Point → Study Plan → Review → Re-assess → Update Readiness

CR-0001 補足此循環的學習體驗：教學內容以 contextual reading 同時支援
可關閉的 Furigana 與獨立發音；Practice / Review 逐題揭露答案及離線詳解；
Mock Exam 則先完成確認交卷，於結果／Review 畫面才揭露。問題回報與 AI
改善建議歸 Developer 審核，不自動轉成產品 Requirement。

### 使用者最終體驗

使用者完成足夠的課程、練習與 Assessment 後，App 應能清楚呈現：

```text
目標：N5

目前準備度：78 / 100
狀態：near_ready
資料可信度：Medium
趨勢：Improving

主要能力：
Language Knowledge + Reading：84
Listening：66

主要弱點：
1. て形相關文法
2. 日期 / 時間單字
3. Listening 短對話

下一步：
文法 15 分鐘
單字 10 分鐘
聽力 10 分鐘

建議再次評估：完成本輪 Study Plan 後
```

以上 `Readiness` 為 App 內部的準備度估計，不是官方 JLPT scaled score，也不是保證通過的機率。

### 最重要的產品限制

- 不以一般練習題答對率直接換算官方 JLPT 分數。
- 不把 AI 動態題當成唯一的能力測量工具。
- 不用單一總平均掩蓋某個必要 scoring section 的明顯弱點。
- 不把 Speaking 分數直接併入 JLPT 官方 Readiness。
- 不在樣本不足時顯示看似精確的 readiness 結論。

### 最終開發策略

> 先建立可離線運作的 N5 核心學習 App，同時建立 Knowledge Mapping 與 Assessment 基礎；接著完成 AI、Diagnostic、Mock、Readiness、Weak Point、Study Plan、Speaking，最後才加入帳號、同步與 Cloud。

內容策略：

> 第三方網站以 Reference Source / Provenance 管理；正式 App Content 以自行建立的 Canonical Knowledge、原創教材與題目為核心，AI 作為輔助生成與個人化工具。

AI 策略：

> Flutter 不直接持有 AI Provider Secret；所有 AI 請求經過 AI Gateway，並使用 Schema Validation、Rule Validation、Versioning、Caching 與 Usage Control。

資料策略：

> Content Data、User Learning State 與 Derived Analytics 分離；Derived Analytics 可由原始資料重新計算；Reset 不誤刪教材；Account / Cloud Data Deletion 另行處理。

Assessment 策略：

> Practice 用於學習，Diagnostic 用於建立 baseline，Benchmark 用於長期比較，Mock Exam 用於接近真實考試情境；所有 Assessment 均需保留版本與有效性資訊。

Readiness 策略：

> 以多來源證據估計「準備程度」而非假裝取得官方考試結果；隨著實際測驗與使用者主動輸入的官方成績增加，再逐步校準模型。

Speaking 策略：

> 將「文字是否說對」與「發音 / 流暢度」分開評估，並將 Speaking 作為學習能力指標，而非 JLPT 官方 scoring section。

最終目標不是一次把所有功能做完，而是讓每一個 Phase 都形成可運作、可測試、可回退、可擴充的版本。

## 42. 實作一致性補充

### 42.1 Schema 與資料生命週期

- 每次 schema 變更使用 versioned migration；不得以刪除資料庫或重建空資料庫作為一般升級方式。
- Content Data、User Learning State、Derived Analytics 的責任分界依第 7 節；Derived Analytics 可重算，不可取代原始作答/學習事件。
- Reset 操作必須依第 17 節 scope 執行於 transaction；完成後驗證 Content Data 保留及 Derived Analytics 清除/重建結果符合所選 scope。
- `contentVersion`、`questionSetVersion`、`scoringVersion`、`scoringPolicyVersion` 各自代表不同版本，不得共用一個版本欄位代替。
- CR-0001 的 reading / alignment、audio reference、curated explanation、AppSetting 與 Mock Exam confirmed submission 若需新增 schema，須以 versioned migration 保留既有資料並測試舊版升級；Feedback backend 的實際 schema 與 retention 待 Phase 5 決策，不預建假 Cloud 實作。
- V2.2 未定義的 ID 格式、時區策略與欄位空值規則，列為實作決策；選定後全專案一致使用，不由不同 feature 各自決定。

### 42.2 Policy 與可重現結果

Mastery、Readiness、Weak Point 與 Assessment validity 的規則集中在對應 policy。每筆衍生結果應記錄足以重現其計算的 policy/version 及證據範圍；政策更新不得靜默改寫舊 Assessment 的原始答案或版本資料。

V2.2 提供的 Readiness 初始權重 55/25/10/10 是工程假設。使用前仍須定義 insufficient-data 規則及分區 gate；在此之前，UI 不可顯示 ready/ready_with_buffer 作為有效結論。對外文字不得稱為官方分數、統計信賴區間或通過機率。

### 42.3 階段驗證最低要求

各 Phase 除其功能測試外，至少保留下列回歸檢查：

| 完成階段 | 必須重跑的既有流程 |
|---|---|
| Phase 1.5 | Phase 1 離線課程、Quiz、Wrong Question、Review、Reset；reading / Furigana、Audio 降級、逐題回饋／詳解、Settings 持久化與 migration 升級 |
| Phase 2 | Phase 1 + Slice A；Gateway 關閉時 reading、Lesson、curated explanation 與 Quiz 的離線流程 |
| Phase 2.5 | Phase 1 + Slice A + Slice B；動態題與固定 Assessment 隔離；Mock Exam 交卷前資訊抑制、確認後揭露與 global Furigana 隔離 |
| Phase 3 | Slice A、B、B.5；Speaking 不影響 Readiness |
| Phase 4 | Slice A、B、B.5、C；再評估及政策版本追蹤 |
| Phase 5 | 所有本地 Slice；離線使用、同步、各類刪除 scope；Feedback 聚合與 Developer disposition 不影響離線核心 |

### 42.4 交付與 Codex 回報

每個 Phase 的交付回報須包含：

```text
Scope completed
Files / layers changed
Database migration and upgrade path
Commands/checks run and results
Earlier slices re-tested
Known limitations and pending decisions
Git commit(s) or branch state
```

不得以「已完成」取代測試結果；未執行的檢查須明確標為未執行。

### 42.5 CR-0001 驗收與風險

驗收以 §6–8、§12–14、§17、§24、§27–30、§33–34、§38 的要求及測試為準：

- 問題回報頁面可提交 §33.1 類型；AI 只做分類／聚合／建議，Developer 才決定
  disposition 與是否進入正式變更；跨使用者資料與隱私政策於 Phase 5 驗證。
- Vocabulary、Kanji、例句、文法例句及 Lesson 的 context-sensitive reading、
  Furigana 與發音獨立；預設 Furigana ON、可關閉且重啟保留，離線可顯示 reading，
  音訊或 provider 失敗不阻斷 Lesson / Quiz。
- Practice / Review 逐題顯示正誤、使用者與正確答案、curated explanation，
  correct / incorrect sound 可關閉；AI 不可成為離線詳解的唯一來源。
- Mock Exam N5～N1 abstraction 可逐步供應題組；作答時不揭露正誤、答案、詳解、
  分數或回饋音效，取消交卷確認返回作答，確認後才顯示結果／Review。題組版本、
  評分版本、mapping、validity 與 Readiness 分界保持可追溯；global Furigana
  不向正式題組注入提示。Diagnostic / Benchmark 回饋時點保持 Pending Decision。

風險：音訊素材可能增加 App size；remote TTS 有成本、延遲與連線依賴；
context-sensitive reading 或 alignment 錯誤會造成誤學；ruby 在小螢幕、縮放與
換行時可能失真；AI 詳解可能不一致；Feedback 可含敏感資訊且跨使用者聚合
需要 retention / privacy 決策；Mock Exam 提前揭露答案或被 Furigana 注入提示
會破壞 validity；一次擴張 N1～N5 題組會造成範圍失控；AI 改善建議不得繞過
Developer governance。這些風險須在各適用 Phase 的 Decision Record、實作與
驗收中處理，不改變 V2.3 原有 Phase 順序。

治理狀態：V2.4 是 Current Approved Spec；CR-0001 已 APPLIED；
V2.3 保留為被取代的歷史 Spec；Phase 1 NOT STARTED，尚未進行 Codex implementation。



