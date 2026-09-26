# JLPT Learning App 技術規格 V2.3

> 版本：2.3  
> 基準：V2.2，依實際開發排序與驗收需求修訂  
> 架構：Flutter / Dart + C# / ASP.NET Core + Python  
> 平台：Windows 11、Android、iOS  
> 定位：個人使用、非商業、Local-first、Offline-capable、AI-assisted、可逐步擴充

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

- N5 起步，逐步擴充 N4/N3
- 文法、單字、漢字、例句教學
- 選擇、填空、翻譯、閱讀、聽力等測驗
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

diagnostic / benchmark / mock_exam
→ 優先使用固定版本、已驗證題組
→ 題目、難度、知識映射與 scoring version 必須可追蹤
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

V2.2 將測驗分成三種用途：

### 14.1 Practice Quiz

```text
目的：學習與練習
題目：可包含 AI 動態題
提示：可啟用
答案解析：可立即顯示
歷史比較：不作為正式能力基準
```

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

### 14.4 Mock Exam

模擬考盡可能依當前官方 JLPT 測驗結構與時間設計，但 App 結果仍屬模擬資料。

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

不做：

- 登入
- 雲端同步
- PostgreSQL
- 複雜 AI 個人化
- AI Speaking Evaluation

但是資料模型要預留未來 AI / Speaking / Cloud 所需欄位與 migration 策略。

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

## 30. Phase 2.5 — Assessment Engine

```text
Diagnostic Assessment
Benchmark Assessment
Mock Exam
Assessment Versioning
Assessment Validity
Readiness Snapshot v0
```

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
Phase 2.5 — Diagnostic / Benchmark / Readiness v0（Vertical Slice B.5）
Phase 3 — Speaking（Vertical Slice C）
Phase 4 — Readiness / Personalization 完整閉環
Phase 5 — Cloud
```

Phase 1.5 先建立後續 Assessment 所需的資料結構和最小概念證據更新能力；完整 Diagnostic、Benchmark、Readiness 使用流程於 Phase 2.5 實作。Phase 2 先於 2.5，因 AI Gateway 不依賴 Readiness。

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

完成閘門：離線完成課程、測驗、結果、錯題、進度及 Review；重啟後資料仍在；Reset scope 不誤刪 Content Data；適用測試、`dart format`、`flutter analyze` 通過。

### 38.4 Phase 1.5 — Vertical Slice A 與基礎模型

完成第 28 節 Slice A，建立 `KnowledgeConcept`、`QuestionConceptMap`、`LearnerKnowledgeMastery`、`AssessmentSession`、`AssessmentAnswer`、`AssessmentResult` 與 `ReadinessSnapshot` 的必要 schema。此階段不要求完整 Assessment UI 或 Readiness 結論。

完成閘門：Slice A 可從啟動跑到 Reset；正式題目有主要 KnowledgeConcept mapping；migration 可升級 Phase 1 資料；原始作答可重建 Derived Analytics；資料庫與 Slice A 回歸通過。

### 38.5 Phase 2 — AI Gateway 與題庫

完成第 29 節 Gateway、AI 題目/解釋、Validator、Cache、Versioning 與 Slice B。

完成閘門：Provider Secret 不在 App；題目通過 JSON Schema、規則、答案一致性與去重後才可使用；Gateway 不可用時 Phase 1 / Slice A 仍可離線運作；動態 AI 題不能充當固定 Assessment 題組；後端與 Flutter 相關建置/測試通過。

### 38.6 Phase 2.5 — Assessment 與 Vertical Slice B.5

完成第 30 節 Diagnostic、Benchmark、Mock Exam、Assessment Versioning/Validity、Readiness v0、Weak Point、Study Plan 與 Slice B.5。

完成閘門：Assessment 可追溯題組及評分版本；無效結果不作有效 Readiness 證據；資料不足顯示 `insufficient_data`；Readiness 明確標示為 App 估計；必要分區風險不被總平均掩蓋；弱點可追溯到概念與作答；相關 Unit/Widget/Integration Tests 通過。

### 38.7 Phase 3 — Speaking

完成第 31 節 Slice C。Speech correctness 與發音/流暢度評估分開；不支援的指標可為 unavailable/null；拒絕麥克風權限不阻擋核心學習。

完成閘門：Slice C 流程可驗證；錄音保留政策可驗證；Speaking 不改變 JLPT Readiness；Slice A、B、B.5 回歸通過。

### 38.8 Phase 4 — Readiness / Personalization

完成第 32 節 Coverage、Trend、Readiness v1、弱點、Review Scheduler、Personalized Quiz、Daily Plan、Adaptive Difficulty 與再評估閉環。

完成閘門：Study Plan 後可再評估並更新 Mastery、Weak Point、Readiness 與下一版 Plan；Coverage 與 Mastery 分開；資料不足和政策版本可追溯；相關測試與既有 Vertical Slice 回歸通過。

### 38.9 Phase 5 — Cloud

完成第 33 節帳號、Authentication、PostgreSQL、Cloud Sync、Backup、Usage Quota 與伺服器端刪除。

完成閘門：離線核心仍可用；同步、衝突處理、備份和刪除範圍可重現驗證；Reset、Local Delete、Cloud Delete、Account Delete 分離；後端 migration/tests 與本地 Vertical Slice 回歸通過。

### 38.10 Codex 階段執行規則

每次任務限一個 Phase 或一個可驗收 Vertical Slice。開始前閱讀本規格、`AGENTS.md`、Git 狀態及現有測試；先列出依賴與修改範圍；完成後回報修改、migration、驗證結果、待決策與前階段回歸結果。

規格未定義的規則不得自行猜測並固化。Codex 應列明缺少的決策與影響，先完成不依賴該決策的工作；若決策會改變資料格式、對外承諾或不可逆行為，暫停該部分並回報。

每個 Slice 使用可 review 的分支/commit 群組。Schema 變更必須同一交付包含 migration 與資料庫測試。Commit 類型使用 `feat:`、`fix:`、`refactor:`、`test:`、`docs:`、`chore:`。

### 38.11 待決策登錄表

下列項目在 V2.2 中尚未具體定義。開始相應功能前，以 Decision Record 記錄決策、理由、日期及套用的 policy/version；不得散落硬編碼。

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
| SDK / providers | 實際版本、STT/TTS provider、平台支援與成本限制 | Phase 0/2/3 |

本表只登錄 V2.2 已提及但未具體決定的實作參數，不新增產品功能。已決定項目須標記完成並保留決策紀錄。
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

## 41. V2.3 結論

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

## 42. V2.3 實作一致性補充

### 42.1 Schema 與資料生命週期

- 每次 schema 變更使用 versioned migration；不得以刪除資料庫或重建空資料庫作為一般升級方式。
- Content Data、User Learning State、Derived Analytics 的責任分界依第 7 節；Derived Analytics 可重算，不可取代原始作答/學習事件。
- Reset 操作必須依第 17 節 scope 執行於 transaction；完成後驗證 Content Data 保留及 Derived Analytics 清除/重建結果符合所選 scope。
- `contentVersion`、`questionSetVersion`、`scoringVersion`、`scoringPolicyVersion` 各自代表不同版本，不得共用一個版本欄位代替。
- V2.2 未定義的 ID 格式、時區策略與欄位空值規則，列為實作決策；選定後全專案一致使用，不由不同 feature 各自決定。

### 42.2 Policy 與可重現結果

Mastery、Readiness、Weak Point 與 Assessment validity 的規則集中在對應 policy。每筆衍生結果應記錄足以重現其計算的 policy/version 及證據範圍；政策更新不得靜默改寫舊 Assessment 的原始答案或版本資料。

V2.2 提供的 Readiness 初始權重 55/25/10/10 是工程假設。使用前仍須定義 insufficient-data 規則及分區 gate；在此之前，UI 不可顯示 ready/ready_with_buffer 作為有效結論。對外文字不得稱為官方分數、統計信賴區間或通過機率。

### 42.3 階段驗證最低要求

各 Phase 除其功能測試外，至少保留下列回歸檢查：

| 完成階段 | 必須重跑的既有流程 |
|---|---|
| Phase 1.5 | Phase 1 離線課程、Quiz、Wrong Question、Review、Reset；migration 升級 |
| Phase 2 | Phase 1 + Slice A；Gateway 關閉時離線流程 |
| Phase 2.5 | Phase 1 + Slice A + Slice B；動態題與固定 Assessment 隔離 |
| Phase 3 | Slice A、B、B.5；Speaking 不影響 Readiness |
| Phase 4 | Slice A、B、B.5、C；再評估及政策版本追蹤 |
| Phase 5 | 所有本地 Slice；離線使用、同步、各類刪除 scope |

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



