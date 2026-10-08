# JLPT Learning App 技術規格 V2.16

> 版本：2.16，Developer Approved
> 基準：V2.15（前版 Current Approved Spec）；依 CR-0013（APPLIED）修訂
> 架構：Flutter / Dart + C# / ASP.NET Core + Python
> 平台：Windows 11、Android、iOS
> 定位：個人使用、非商業、Local-first、Offline-capable、AI-assisted、可逐步擴充

> 治理狀態：V2.16 是 Current Approved Spec；Developer Approved / Repository Integrated；
> V2.16 取代 V2.15；CR-0001～CR-0013 均已 APPLIED；
> CR-0013 APPLIED；
> 本版只整合 Developer 於 2026-10-08 核准的 SR-D01～03；
> Production implementation、Phase 1.5 與 Phase 2 start 均 NOT AUTHORIZED；
> A6-Core APPLIED；A6-D1～D7 OPEN；A1-D1～D6 OPEN；
> A2-P1 / A2-R1 OPEN / DEFERRED；A3-D1～D4、A4-D1～D4 OPEN；
> A5-D1 / D3 / D4 / D5 OPEN；A5-D2 PARTIALLY RESOLVED：
> Search core semantic 已核准，Browse / Sort 與具體 Search interaction / presentation 仍 OPEN；
> AI-assisted Retrieval：DRAFT / NOT PART OF CR-0012 / NOT AUTHORIZED；
> V2.15、V2.14、V2.13、V2.12、V2.11、V2.10、V2.9、V2.8、V2.7、V2.6、V2.5、V2.4、V2.3 保留為被取代的歷史 Spec；
> Phase 0 COMPLETE；Phase 1 STARTED / NOT YET COMPLETE；Phase 1.5 / Phase 2 NOT AUTHORIZED。

## V2.16 Change Summary — CR-0013

僅整合 SR-D01～03：Phase 1 沿用現有 App Shell「設定」目的地作為 Settings
family 的可發現入口；Settings 與 Lesson 使用同一個全域 AppSetting.showFurigana，
Lesson toggle 更新該 persisted value，不建立 temporary per-page override。
保存成功後，適用的已掛載 Lesson / Practice inherit consumers 反映最新
confirmed value。全域偏好讀取失敗時，有本次執行期間的 confirmed value 則
暫時沿用並提供提示／retry；冷啟動無 confirmed value 則一般 inherit 教學文字
暫採 surface-only，不當作 OFF、不寫入 false 或建立 persisted fallback。
恢復成功讀取後更新 consumers 並清除不再適用的錯誤提示。
正常首次初始化 default ON、重啟持久化、explicit show / hide 優先及 Mock Exam
正式 reading policy 保留。不改 Content / renderer / DB schema、Reset、Audio
或 Feedback Sound；不決定 coordinator class、public API 或 subscription mechanism。
A1-D1～D6 與 A2-R1 仍未決；SR-D04～08 未由本 CR 核准。
本版不代表整份 05 V0.1、Settings family UI/UX 或 Global Design System 已批准；
§6.1 gate、Phase 順序與完成定義保留，production implementation 未授權。
本版經 Developer 核准並正式進入 Repository（Developer Approved / Repository Integrated），取代 V2.15 為 Current Approved Spec；CR-0013 APPLIED。

## V2.15 Change Summary — CR-0012

新增 Local Canonical Content Search，V1 以 single query 搜尋正式 Vocabulary /
Grammar，預設跨 N5～N1；Level 為 metadata / optional filter，不以 primary target、
viewed level、completion 或 mastery gate 搜尋，亦不改 target。以 deterministic
normalization 進行 exact / prefix / contains matching，依 §1.2.7 固定 relevance
ranking；不修改 canonical 內容、不加入 personalized / AI ranking。
Result 沿用 logical identity、immutable revision、ContentVersion、effective published
selection 與 provenance；不返回 draft、未發布 reviewed 或 withdrawn current result。
結果最小資訊與 canonical detail navigation 不新增 mandatory Content fields；
result presence 不表示整個 Level × Content Family Available。
Search 是 Local-first / Offline-capable 的 discovery，不是 learning / Assessment
evidence，不要求 Search History；不選定 schema、index、engine 或 UI placement。
正式放在 Phase 2 的 early offline enabling slice，不追溯擴張 Phase 1 gate，
不新增 Phase 1.x；Phase 1 → 1.5 → 2 不變。A5-D2 僅部分解決 Search core，
其他未決項目依 §38.11 保留；CR-0011 contextual Tutor 契約完整保留。
AI-assisted Retrieval 維持 DRAFT / NOT PART OF CR-0012 / NOT AUTHORIZED。
本版經 Developer 核准並正式進入 Repository，取代 V2.14 為 Current Approved Spec；
CR-0012 APPLIED。本次 Spec promotion 不授權 Search implementation、Phase 1.5 或 Phase 2 start。

## V2.14 Change Summary — CR-0011

Phase 2 新增 Context-Aware AI Tutor Q&A，定位為 Supplemental Learning Assistance：
Lesson 為主要 contextual entry，支援 LessonSection、Vocabulary、Grammar、
ExampleSentence 與 Practice / Review post-feedback。Text input、多輪限於綁定
啟動 canonical context / revision 的 ephemeral Tutor Session；canonical-first，
可補充可靠日語知識，明確區分 answer basis 與 insufficient context。
繁體中文（臺灣）解釋、日文例句；canonical validated reading 沿用既有政策，
即時 AI 新日文不自動套用 canonical-style ruby / Furigana。
請求經 Use Case、AI abstraction、HTTPS AI Gateway、AI Application Use Case、
Prompt / Context Builder 與 Provider Adapter；structured response 須可 schema validate。
Practice 只有正式 durable 作答與完整回饋／stored explanation 後可追問；
active Diagnostic / Benchmark / Mock 預設禁用 Tutor，完成後使用仍待正式 policy。
對話不自動產生學習／評估證據，不修改正式教材、答案、結果或 Requirement；
最小化傳送、ephemeral session 與 server/provider retention 邊界依 §10.1、§34。
離線核心不依賴 Tutor；V1 不加入 Global AI Chat、voice、image、history / sync，
亦不要求 Vector DB / full semantic RAG。API、retry / timeout 與必要 privacy 決策於適用階段完成，
既有 Phase order、非 AI Phase scope / gates、A1～A6 Open Decisions 均保持。
本版經 Developer 核准並正式進入 Repository，取代 V2.13 為 Current Approved Spec；CR-0011 APPLIED。本次 Spec promotion 不授權 Phase 2 implementation。

## V2.13 Change Summary — CR-0010

Assessment 為獨立 Global Product destination，具有 N5～N1 destinations；可發現
不等於可用，不建立 sequential assessment unlock，也不修改 primary StudyGoal target。
Learning / Assessment 皆形成 learner evidence，但不同來源不視為等價；歷史 evidence /
results 與目前 Mastery、WeakPoint、Review Priority 分離。WrongQuestion 不等於
concept-level WeakPoint，remediation 不要求一直重做同題。固定 active / improving /
resolved / reopen semantic，單次答對不足以自動 resolution；resolved 預設退出 active
weakness queue，保留歷史證據並可因新 negative evidence reopen。Adaptive Review
優先 weak / improving / low-confidence concepts，高 mastery 降低重複優先度但非永久
排除；不改 fixed Benchmark / Mock validity。Learning History 是 learner-facing
projection / view，不要求單一 persistence table，不回寫 historical AssessmentResult /
ReadinessSnapshot。Assessment Content 仍依 03 → 06 → Developer，JLPT 公開資料
僅作 Reference Source。A6-D1～D7 登錄 OPEN；A1～A5、既有 policies、schema、
migration、Phase order / gates 與 Practice / Review / Assessment contracts 保持。

## V2.12 Change Summary — CR-0009

固定 Learning 的 Foundation / JLPT Courses / Vocabulary / Grammar semantic frame；
N5～N1 均為 discoverable Level destinations，但不代表 content production-ready。
Level navigation 不修改 primary target，只有 explicit learner target-change action
可改 target。每 Level 有 Course Area、Canonical Vocabulary Curriculum 與 Canonical
Grammar Curriculum；canonical curriculum 是 coverage authority，Course / Lessons
是 pedagogical organization，不以 Lesson union 判定 curriculum 完整性。
Lesson 使用既有 canonical identities；canonical item 可在 Reference 及 applicable
focused Practice 出現而沒有 Lesson mapping。區分 Lesson Practice、Vocabulary
Level Practice、Grammar Level Practice contexts，保留既有 Practice / Review 契約。
Curriculum / Content 依 03 → 06 → Developer 流程；A1-D1～D6 及 A2～A5 未決項目
保持 OPEN，不固定 UI、inventory、classification、coverage count、lesson sequence、
completion、Practice selection / scoring、schema 或 migration，不改 Phase scope。

## V2.11 Change Summary — CR-0008

將 Vocabulary Index 與 Grammar Index 定義為 distinct learner-facing reference
indexes，各有 independently discoverable entry，不依賴 Lesson entry 或 completion。
支援 N5～N1 level 組織／篩選，但不代表各級 content 已 production-ready，也不擴張
Phase 1 N5 production content。瀏覽不受 StudyGoal target 限制且不修改 target；
沿用 canonical Vocabulary / Grammar identity、immutable revision、publication /
provenance 與 A3 availability，不另建 Reference content source 或 unlock state。
Grammar 可導向 zero / one / multiple applicable learner-facing learning destinations，
不鎖定 representation。Browse / detail view 不自動等於 completion、mastery 或
Assessment evidence。A5-D1～D5 登錄 OPEN；A3／A4 未決項目、Local-first、Content
workflow、KnowledgeConcept、schema、migration、Phase order / gates 均保持不變。

## V2.10 Change Summary — CR-0007

將 Kana / 50音 明確定位為 Shared Foundational Learning Area，正式產品概念為
`Kana Foundation`；不是 JLPT Level、不建立 synthetic N0，也不由 N5 semantic
ownership 管理。與 Phase 1 N5 一起交付只是 rollout / implementation relationship。
提供 independently discoverable entry，learner 可 skip、隨時 revisit；Kana
completion 不作任何 Available / Partial JLPT content 的 prerequisite，Kana activity
不隱性修改 StudyGoal target。固定 Foundation Core scope 與 non-core 邊界，
不把 core coverage 寫成 learner completion requirement。A3-D1 與 A4-D1～D4
保持 OPEN；CR-0002、Audio / Feedback / Handwriting 契約、availability、target
ownership、Phase scope 與架構不變，不新增 schema、migration 或 production 授權。

## V2.9 Change Summary — CR-0006

固定 A3 Content Availability 的 authoritative scope 為 `JLPT Level × Content Family`，
以 Available、Partial、ComingSoon、Unavailable 表達 product availability；Level-wide
availability 僅為依 relevant families 推導的 summary。Available / Partial 可存取，
不受 StudyGoal / target、progress、mastery、前級或 Kana 完成狀態限制。此契約與
既有 Content lifecycle / contentVersion、runtime capability、N5→N1 development
rollout 分離，作為 A5、Level Selector 及未來 Reading / Listening availability 的
上游 semantic contract。A3-D1～D4 保持 OPEN；不決定 UI、schema、migration、
Cloud 或 Content Update protocol，不改 learner target ownership 或 Phase scope。

## V2.8 Change Summary — CR-0005

補足既有 `StudyGoal.targetLevel` 作為 learner primary JLPT learning /
exam-preparation target 的 authoritative ownership；與 navigation、selected /
viewed level、unlock 及 content availability 分離。Learner 可存取所有目前已有
available content 的 JLPT level，沒有 active `StudyGoal` 也不阻止使用。
Assessment、Readiness 與 StudyPlan 等記錄自己的 `targetLevel` 只代表各記錄適用
級別，不取代目前 primary target。A2-P1 persistence timing 與 A2-R1 Reset semantics
保留 OPEN / DEFERRED；不新增 schema / migration，不改 Phase scope、UI design、
availability taxonomy、Cloud Sync 或 account policy。

## V2.7 Change Summary — CR-0004

為 Phase 1 `singleChoice` Practice / Review 補足 `QuizSession`、逐題 durable
`QuizAnswer`、不可變有序題目快照與精確 Question revision 綁定、重啟恢復、
冪等提交／完成、正式完成與 Final Result 原始資料來源；以新版本化 migration
保留既有 Content Data。另定義跨級別共用 Design System、依 interaction family
交付的 05 UI/UX entry gate，以及以穩定教材批次進場的 04 Visual entry gate；
Design / Visual approval 與 Codex production integration authorization 保持分離。
不改 CR-0001～0003、Kana retry、Mock Exam、Phase 順序或既有 Phase 1 gate。

## V2.6 Change Summary — CR-0003

釐清 Phase 1 Practice / Review `singleChoice` 的空提交驗證、有效作答後的選項
鎖定，以及最後一題逐題回饋至既有 Final Result 的明確轉場。完成狀態須以
必要 evaluation、User Learning State 保存及 Use Case / Repository 的正式完成
操作為準，不能由 UI navigation 推定。不改 Kana retry、Mock Exam、資料 schema、
Phase 範圍或其他 UI/UX workflow decision。

## V2.5 Change Summary — CR-0002

在 Phase 1 N5 Core Offline Learning 增加 Hiragana / Katakana 學習與 Practice：
鍵盤輸入、支援裝置上的觸控／觸控筆手寫、聽音或視覺提示後作答、離線辨識
抽象與鍵盤降級。沿用既有 Learning Audio、Practice 逐題回饋及資料生命週期規則；
不加入筆順／書寫品質評分，不擴張 Mock Exam 或後續 Phase。辨識 provider、
平台適配與答案正規化等未決參數列於 §38.11。

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

- N5 起步，逐步擴充 N4/N3（開發／內容 rollout，不是 learner sequential unlock）；Assessment abstraction 與最終 Mock Exam 能力保留 N5～N1
- Learning 以 Foundation / JLPT Courses / Vocabulary / Grammar 區分正式語意；Course / Canonical Curriculum 與 Practice contexts 依 §1.3，不固定最終 UI
- 文法、單字、漢字、例句教學
- distinct Vocabulary Index / Grammar Index，可獨立進入並依 N5～N1 level 瀏覽／篩選與存取 detail；內容與未決邊界見 §1.2
- Shared `Kana Foundation`（Kana / 50音）學習與鍵盤、觸控／觸控筆手寫 Practice；Phase 1 與 N5 一起交付，非 N5-owned learning area（§1.1）
- 教學漢字預設顯示可關閉的 Furigana；學習內容提供 context-sensitive 發音播放
- 選擇、填空、翻譯、閱讀、聽力等測驗
- Practice / Review 逐題回饋與詳解；Mock Exam 確認交卷後才揭露結果
- 使用者問題回報與經 Developer 審核的改善建議流程
- 錯題與學習歷程
- AI 教學、AI 題庫與解析
- Phase 2 Context-Aware AI Tutor Q&A：針對目前 canonical learning context 追問的補充教學；不取代正式教材或離線詳解（§10.1）
- 麥克風口說練習
- Speech-to-Text / Text-to-Speech
- 口說文字正確性與語音表現評估
- 個人化複習與學習統計
- Diagnostic Assessment / Benchmark Assessment / Mock Exam
- 獨立 Assessment destination、learner-facing Learning History 與 concept-level Adaptive Weakness Review；semantic 與未決邊界依 §1.4、§13–16
- JLPT Readiness 準備度分析
- 單字、文法、漢字、閱讀、聽力弱點分析
- 個人化 Study Plan 與再測推薦
- 歷史資料重置與資料刪除
- Windows 11 / Android / iOS 共用主要程式碼

Learner 可存取所有目前已有 available content 的 JLPT level，不受 primary
`StudyGoal.targetLevel` 限制；未設定 primary target 也不阻止使用 available content。
瀏覽、學習或 navigation 到其他級別不隱性修改 primary target。Ownership 契約見
§15.2.2。上述可用內容包含 §8.5 的 Available / Partial；Level 有 learner-usable
content 不代表每個 family 均已 Available。本 Spec 不因此決定 Level Selector UI。

核心原則：

> Local-first + Offline-capable + Cross-platform + AI-assisted + Privacy-aware + 可測試 + 可逐步擴充

產品原則：

```text
核心學習能力
→ 不依賴 AI / Cloud 才能運作，包含 Kana 核心練習

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

### 1.1 Kana Foundation — Shared Foundational Learning Area（CR-0007）

#### 1.1.1 產品定位、entry 與 learner access

Kana / 50音 的正式產品概念為 `Kana Foundation`，屬 Shared Foundational
Learning Area，不是 JLPT Level。不得建立 synthetic `N0`，也不得由 N5 semantic
ownership 管理；Phase 1 與 N5 一起交付只表達 rollout / implementation relationship。

Kana Foundation 必須具有 independently discoverable entry，不得只能透過 N5
進入。Learner 可 skip Kana Foundation，並可隨時 revisit；Kana completion 不得
成為任何 Available / Partial JLPT content 的 prerequisite。JLPT experiences 可
推薦或 deep-link Kana Foundation，但只能 advisory，不得作為 access gate。
Exact Entry Placement 仍由 A4-D1 決定；本節不設計 Home IA、Level Selector 或
Navigation component。Recommendation / Onboarding Policy 仍屬 A4-D3 OPEN，
不因允許 advisory recommendation 而自行建立強制 onboarding 或推薦規則。

Kana activity 不得隱性修改 `StudyGoal.targetLevel`，primary target ownership 仍依
§15.2.2。Kana progress 是 learner state，不是 availability、unlock 或 target state；
沒有 Kana progress 不代表 learner 不會 Kana。A4-D4 Progress Representation /
Persistence 保持 OPEN，不由此建立 progress schema / table 或 migration。

Kana Foundation 不因本節而自動成為 Content Availability 的 Content Family；
A3-D1 Exact Content Family List 仍 OPEN，§8.5 的 availability 契約保持不變。

#### 1.1.2 Foundation Core scope 與 non-core boundary

Kana Foundation Core 至少包含：

| Core area | 已核准內容範圍 |
|---|---|
| Basic Hiragana | 基本 Hiragana，包含 `ん`。 |
| Basic Katakana | 基本 Katakana，包含 `ン`。 |
| Dakuten | 基本濁音及其 Hiragana / Katakana forms。 |
| Handakuten | 基本半濁音及其 Hiragana / Katakana forms。 |
| Yōon | 基本拗音及適用的濁音／半濁音組合。 |
| Sokuon | `っ / ッ`。 |
| Basic Long-vowel / Prolonged-sound Usage | 至少包含 Katakana `ー` 與初級所需 Hiragana 長母音基本概念。 |

以下不要求屬 Foundation Core：extended foreign-sound combinations、rare
small-kana combinations、historical kana、iteration marks、rare / special Kana
orthography。是否、何時及如何教授，保持 downstream Content / Curriculum
decision；不得把 non-core boundary 改成已核准的 Extended Kana 課程安排。

本表是內容 scope，不是 teaching order、lesson grouping 或 learner completion
requirement。Core scope 已核准；teaching order、lesson grouping、completion
definition、progress percentage、mastery threshold、repetition / correct-count
requirement 與 Extended Kana curriculum placement 均保持 A4-D2 OPEN。

#### 1.1.3 既有 Kana Learning / Practice 契約

CR-0002 的 Kana Content、四種提示／輸入流程、keyboard / touch / stylus、explicit
Submit、辨識／正誤、Clear / Rewrite / Retry / Continue、離線 keyboard fallback
與手寫資料最小化完整保留（§4、§7.4.2、§12.6、§14.1、§24、§27）。Learning
Audio delivery 依 `DEC-P1-001`，Practice / Review feedback 依 `DEC-P1-003`，
Kana handwriting recognition / answer policy 依 `DEC-P1-005`；本 CR 不修改其
provider、模型供應、正規化、候選判定、failure / fallback 或 Feedback contract。
本 CR 不另行指定各內容的 Practice 題型或辨識方式，也不加入
筆順／書寫品質評分、Cloud recognition 或其他 Phase 功能。

### 1.2 A5 Vocabulary / Grammar Reference Index Semantics（CR-0008）

#### 1.2.1 獨立 reference entry 與跨級別存取

Vocabulary Index 與 Grammar Index 為兩個 distinct learner-facing reference indexes，
各自須具有 independently discoverable entry；不需先進 Lesson，也不需 Lesson
completion。Vocabulary Index 與 Grammar Index 均支援 level browse + detail access，
依 N5～N1 JLPT level 組織／篩選。跨級別 capability 不表示 N5～N1 content 已全部
production-ready；開發／內容 rollout 不等於 learner sequential level unlock。

Browsing 不受 `StudyGoal.targetLevel` 限制，亦不隱性修改 primary target；沒有
active StudyGoal 不阻止存取目前可用內容，ownership 依 §15.2.2。A5 不建立
Lesson completion、前級或 Kana completion 的 access prerequisite；Kana Foundation
仍依 §1.1 保持 shared foundational area，不因 reference entry 改變其邊界。

Exact Entry / Reference IA（A5-D1）保持 OPEN。A5-D2 的 Search core semantic
由 CR-0012 於 §1.2.5–1.2.10 精確化；Browse / Sort 及具體 Search interaction /
presentation 仍 OPEN。本節不設計 Reference hub、Home IA、Level Selector、
Navigation component、search / sort UI 或 favorites；Level 組織／篩選能力不決定具體 control。

#### 1.2.2 Canonical content、publication 與 availability

兩個 Index 使用既有 canonical Vocabulary / Grammar logical identity、immutable
revisions 與 ContentVersion；不得建立平行 `ReferenceVocabulary` /
`ReferenceGrammar` content source。Reference entry 不繞過 §8 與
`DEC-P1-007 / 008 / 009` 的 publication lifecycle、provenance 與 Review。
目前正常 browse / detail access 沿用 effective published revision 選取規則；
draft / reviewed 不作正式可用內容，withdrawn 不供新流程選取，歷史 revision
保留與既有 User Learning State 引用責任不變。

Content Availability 沿用 §8.5 的 JLPT Level × Content Family、四個核心狀態
及 access semantics；Available / Partial 可存取，不建立新的 Reference-specific
availability 或 Locked / Unlocked state。不因有 Index entry、單筆 published content
或 level summary 而宣稱完整 coverage；A3-D1～D4 全部保持 OPEN，不由 Index
名稱選定完整 Content Family taxonomy、threshold、ETA 或 representation。

Vocabulary / Grammar detail 的最終 learner-facing field contract 屬 A5-D3 OPEN。
本節不固定 mandatory detail fields，也不改既有 Content Data 必要欄位。新建或
實質修訂內容仍依 03 Author QA → 06 Independent QA → Developer Content Review /
Approval workflow，適用例外依 DEC-P1-009；來源核准、06 PASS 或 Index 可呈現
均不等於 Content Release 或 production integration authorization。

#### 1.2.3 Grammar → applicable learning content

Grammar detail 可導向 applicable learner-facing learning content。此關係必須容許
zero / one / multiple applicable destinations，不假設 `GrammarId → exactly one
LessonId`；不能因某 Grammar 沒有 learning destination 而虛構 Lesson 關聯。
各 destination 的正式 Content lifecycle 與 availability boundary 仍成立，不以
reference link 繞過既有 learner access 規則。

已核准的是上述 cardinality semantic；Relationship Representation（A5-D4）仍 OPEN。
不指定 relationship table / join、欄位、schema、link control 或 destination UI；
不修改 KnowledgeConcept / QuestionConceptMap contract 或其 Phase 1.5 時點。

#### 1.2.4 Reference viewing、learner state 與 offline boundary

Browse / detail view 不自動等同 completion、mastery 或 Assessment evidence。
Reference Viewing / Progress Semantics（A5-D5）保持 OPEN，不由觀看行為推定
已掌握、完成 Lesson、建立正式作答或有效評估證據；本節不建立 known / mastered
policy、Reference progress schema、view tracking / retention 或 mastery 更新規則。
既有 Knowledge mapping、LearningProgress、Assessment / Readiness 責任分界不變。

Reference flow 維持 Local-first / Offline-capable：核心 browse / detail 使用本地
可用的正式內容，不以 Cloud / AI / network 作必要 runtime dependency。Runtime /
device / network capability 與 product availability 依 §8.5.4 分離。本 CR 不決定
Content Update protocol、Cloud contract、schema 或 migration，不改 Phase scope /
order / gates；A5 未決項目依 §38.11 處理。CR-0012 Search 的 Phase 2 placement
另依 §1.2.10 / §29 / §38.5，不追溯改變既有 Reference 或 Phase 1 gate。

#### 1.2.5 Local Canonical Content Search — 定位與 scope（CR-0012）

Local Canonical Content Search 是 learner-facing Learning / Reference discovery
capability，供已知想查的單字／文法、但不知道其 Level、Content Type 或 Index
位置的 learner 使用。V1 提供 single query → Vocabulary + Grammar 的 unified
search experience；不要求 learner 先選 Content Type。

V1 scope 僅限 Vocabulary / Grammar，不包含 Kanji、Kana、Lesson full-text、
ExampleSentence full-text、Question / Assessment content、WrongQuestion 或
Learning History；後續擴張須另作正式決策。Search 本身不是 Assessment、
Mastery、StudyGoal mutation 或 LearningProgress evidence。

預設搜尋跨 N5～N1，JLPT Level 是 result metadata 與 optional filter，不是
search prerequisite。搜尋不受 StudyGoal.targetLevel、current viewed level、
prior-level completion、Kana completion、progress 或 mastery 限制；搜尋或
開啟跨 Level detail 不隱性修改 primary target。跨級別能力不表示所有 Level
content 已 production-ready；target ownership 及 learner access 仍依 §15.2.2。

#### 1.2.6 Search canonical / publication / availability boundary

使用既有 canonical Vocabulary / Grammar logical identity、immutable revision、
ContentVersion、effective published revision 與 provenance；不得建立平行
SearchVocabulary / SearchGrammar canonical source。正常 learner Search 不返回
draft、reviewed but unpublished 或 withdrawn as current result；既有歷史 revision
保留及 User Learning State 引用責任不變，遵守 DEC-P1-007 / 008 / 009。

Search Result 存在不等於整個 Level × Content Family 為 Available。沿用 §8.5
的 Available / Partial / ComingSoon / Unavailable、aggregation 與 access semantics，
不新增 Search-specific availability / unlock state，也不解決 A3-D1～D4。
Search 不繞過 03 Author QA → 06 Independent QA → Developer Content Approval /
Release 與既有 publication / provenance governance。

#### 1.2.7 Deterministic matching 與 relevance ranking

V1 使用 exact、prefix、contains / substring match 與 deterministic normalization。
Normalization 僅用於 search comparison / search key，不修改 canonical Content、
learner-facing display 或 revision。可採適合日文搜尋的 Unicode width、
leading / trailing whitespace、Grammar decoration（如 〜 / ～）normalization，
以及 Hiragana / Katakana equivalent search-key handling；這些是可用方向，
不由本 CR 固定 exact algorithm。若 algorithm 會改變 learner-visible semantic，
須後續 Product Review，不得自行發明未核准規則。

Ranking 優先序固定為：

1. Exact canonical expression / written-form match。
2. Exact canonical reading match。
3. Exact learner-facing meaning / title match。
4. Prefix match。
5. Contains match。

同 ranking class 使用 deterministic stable tie-breaker；不由本 CR 指定其具體
演算法。V1 不使用 StudyGoal-based、mastery-based、personalized、recent-search、
popularity 或 AI relevance ranking；query relevance 不是 recommendation policy。

V1 不要求 fuzzy typo correction、Romaji search、AI semantic matching、Vector DB、
Embedding Store、semantic RAG、remote semantic search 或 LLM ranking。
未來 semantic / concept-oriented retrieval 須另作 Product / Retrieval Architecture Review。

#### 1.2.8 Search Result 與 no-result contract

每筆 V1 result 至少提供 Content Type、canonical learner-facing display item、
JLPT Level、minimal disambiguation preview 與 canonical detail destination。
Vocabulary preview 可使用既有正式 Content 的 written form、canonical reading、
concise learner-facing meaning 等足以辨識 item 的資訊；Grammar preview 可使用
canonical expression / pattern 及 formally available 的 concise learner-facing
meaning / title。以上不新增或鎖定 mandatory Vocabulary / Grammar Content fields，
也不關閉 A5-D3 的最終 detail presentation contract。

No result 僅表示「目前 App 內沒有找到符合目前搜尋條件的正式 canonical
Content」，不代表該日文不存在、不是 JLPT 內容、超過 N1 或教材未來不會提供。
可概念上表達 NO_CANONICAL_MATCH，但不固定 API enum、response schema
或 no-result UI wording / component。

#### 1.2.9 Offline architecture、learner evidence 與 history boundary

Search V1 必須 Local-first / Offline-capable；核心 Search 不要求 Cloud、Backend、
AI Gateway、network、Vector DB 或 Embedding Store。責任鏈依既有分層為
Search Presentation / ViewModel → Search Use Case → Canonical Search Repository
→ Local canonical Content。UI 不直接操作 SQLite；不選定 SQLite query、FTS、
normalized index 或其他 local mechanism。此為 responsibility contract，不建立
table / index、schema 或 migration；若後續需要變更，仍依正式 schema /
migration governance 與 §42.1 的 versioned、保留資料及 upgrade test 契約處理。

單純 query → results → open canonical detail 不自動建立 QuizAnswer、Assessment
evidence、Lesson completion、LearningProgress / Mastery update、WrongQuestion
或 Readiness evidence。V1 不要求保存 Search History、Recent Searches、Frequent
Queries 或 Personalized Search Profile；若未來增加 history / personalization，
須另決 persistence、retention、Reset scope、Privacy 與 learner-state semantics，
不得由此改變現行 §17 Reset 或既有 learning evidence contract。

#### 1.2.10 UI/UX、Phase 與 AI-assisted Retrieval 邊界

Unified Search capability 已核准，但 Home / Learning placement、Reference Hub、
search icon、Sidebar、Bottom Navigation、Top bar 或 exact Navigation component
未決；A1-D1 / A5-D1 與適用 05 UI/UX handoff 仍依 §6.1 / §38.11。
A5-D2 為 PARTIALLY RESOLVED：Search core semantic 已核准並整合本規格，
Browse / Sort 與具體 Search interaction / presentation 仍 OPEN，不視為完整
interaction decision；A5-D1 / D3 / D4 / D5 均保持 OPEN。

Local Canonical Search 是 Phase 2 的 early offline enabling slice，且必須在任何
AI-assisted Retrieval implementation 前完成。Phase 1 → Phase 1.5 → Phase 2
不變；不建立 Phase 1.x，不追溯加入 Phase 1 closure gate。Phase 2 內 semantic
sequencing 依 §29 / §38.5；此 placement 不使 Search 依賴 AI / Cloud / network。

AI-assisted Retrieval 維持 DRAFT / NOT PART OF CR-0012 / NOT AUTHORIZED。
本 CR 不核准其 architecture、cross-material orchestration、retrieval API、
searchOutcome schema、AI structured response extension、Global AI Teacher
destination、global semantic search、embeddings / vector retrieval 或 persistent
history，不把 §10.1 Context-Aware AI Tutor 擴張成 Global AI Tutor / global retrieval。
若未來需要上述能力，須另行正式需求／架構決策；本規格不授權 implementation。

### 1.3 A1 Global Learning IA、JLPT Course 與 Canonical Curriculum（CR-0009）

#### 1.3.1 Global Learning semantic frame

正式 Learning 結構為：

```text
Learning
├─ Foundation
├─ JLPT Courses
├─ Vocabulary
└─ Grammar
```

此為 semantic frame，不固定 final UI、Home IA、Level Selector 或 Navigation
component。Foundation 目前核准的 learning area 僅為 §1.1 的 Kana Foundation，
不屬 N5～N1，不自動核准其他 Foundation content。Vocabulary / Grammar reference
entry 仍依 §1.2；本框架不關閉 A4-D1 / A5-D1 的 exact placement / Reference IA，
也不因 Courses / Vocabulary / Grammar 名稱推定 A3-D1 Content Family taxonomy。

#### 1.3.2 JLPT Level destinations、access 與 target

N5、N4、N3、N2、N1 均為 discoverable 的正式 Level destinations。
Discoverability 不等於 production readiness；不建立 sequential level unlock。
Learner 可依 §8.5 存取 Available / Partial content，不受 primary target 限制。
Level navigation 不修改 `StudyGoal.targetLevel`；只有 explicit learner target-change
action 可改 primary target。§15.2.2 的 ownership、無 active goal 語意與 contextual /
historical target 分界不變，不由本節選定 target UI、selected / viewed state、
initial landing、recommendation 或 persistence；A1-D1～D4 保持 OPEN。

#### 1.3.3 Canonical curriculum 與 Course / Lesson

每個 JLPT Level 具有 Course Area，其教學組織關係為
`JLPT Level → Course → Lessons → Lesson Practice`。
每 Level 至少具有 Canonical Vocabulary Curriculum 與 Canonical Grammar Curriculum，
作為 Reference coverage basis 與 focused Practice content basis。

Canonical Level Curriculum 是 coverage authority；Course / Lessons 是 pedagogical
organization。不得以 Lesson union 作 canonical curriculum completeness authority。
Lesson-scoped Vocabulary / Grammar 引用既有 canonical Vocabulary / Grammar
identity，不建立 parallel Lesson-only knowledge source。
Canonical item 可合法出現在 Reference 及 applicable focused Practice 中而具有
zero Lesson mappings；不強迫每個 item 具有 dedicated Lesson ownership。
可用內容仍遵守既有 publication / revision 與 §8.5 availability 契約。

本節不建立實際 N5～N1 inventories、JLPT classification、exact coverage count、
lesson count / order / topic grouping / prerequisite / completion，也不建立 schema、
table / join 或 migration。實際 Curriculum / Content 依 §8.6 處理，
A1-D5 Course Curriculum / Lesson Sequence 保持 OPEN；Phase 1 不因此要求
N4～N1 production content。

#### 1.3.4 Distinct Practice contexts

Lesson Practice、Vocabulary Level Practice、Grammar Level Practice 是三個正式、
distinct learning contexts；底層 infrastructure 可以共用。Focused Practice 的
content basis 依 §1.3.3，不要求每個 canonical item 先對應 Lesson。

既有 §7.3.1、§14.1 的 Practice / Review mode、stable context identity、immutable
question snapshot、Submit、durable answer、feedback、explicit Continue、resume
與 completion 契約保持不變；context 區分不構成新的 answer type、selection、
scoring、mastery effect 或 storage representation 決策。A1-D6 Practice Collection /
Question Selection Policy 保持 OPEN。

### 1.4 A6 Assessment destination 與 Learner Evidence（CR-0010）

Assessment 是獨立 Global Product destination，與 §1.3 Learning semantic frame
保持分界；不把 Assessment 當成必須先完成 Lesson 才能進入的 Learning 子流程。
N5、N4、N3、N2、N1 均有 Assessment destinations。Discoverability 不等於
assessment availability，不建立 sequential assessment unlock。該次 Assessment
context 與 primary `StudyGoal.targetLevel` 分離；navigation / 選取級別不隱性
修改 primary target，仍依 §15.2.2。A3 availability 契約保持不變，本節不由
Assessment destination 決定 Content Family taxonomy 或各 mode 的實際 rollout。

Diagnostic、Benchmark、Mock Exam 用途保持 distinct（§14）；Learning 與
Assessment 的正式活動均能形成 learner evidence，不把不同 evidence source
視為等價（§13.2）。Learner-facing Learning History、current mastery / weakness
及 adaptive review 的責任分界依 §13.6、§16.1，不能取代 Assessment validity。
本節不固定 Assessment Hub UI、Bottom Navigation / Sidebar 或 timeline，
不決定 mode availability / rollout、evidence weighting、schema 或 Phase start；
A6-D1～D7 依 §38.11 保持 OPEN。

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
Lesson / Vocabulary / Grammar / Kanji / Kana
Quiz / Wrong Question / Progress / Review / Kana Practice
 ↓
仍可正常使用
```

Online Enhancement：

```text
AI Explanation
Context-Aware AI Tutor Q&A（Phase 2；§10.1）
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
│   ├── kana/
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
Phase 1 `singleChoice` Practice / Review 的 session 建立、逐題提交、恢復、
正式完成與結果讀取維持 `Presentation → ViewModel → Use Case → Repository → SQLite`；
Widget 不直接寫入 `QuizAnswer`、更新或完成 `QuizSession`，亦不得以畫面導航判定
持久化成功。詳細資料契約見 §7.3，答題行為見 §14.1。
Kana 手寫辨識依 `Presentation → ViewModel → Use Case → HandwritingRecognitionService`
分層；UI 不直接呼叫 OCR、ML provider、平台 handwriting API 或辨識 SDK。
辨識 provider、library、model、平台 adapter 與 dependency 須在導入前由
Decision Record 決定，不能由 Codex 自行選擇。

## 5. Presentation / ViewModel / Domain / Repository

### Presentation

負責 Widget、Page、Layout、Animation、Responsive UI 與 UI accessibility。

### ViewModel

負責 UI state、使用者操作、載入、錯誤與 loading 狀態，呼叫 Use Case。
Practice / Review 的選取驗證、提交中、durable 保存後回饋、鎖定、恢復及完成失敗狀態
由 ViewModel 呈現；不得將未保存的 evaluation 暫態結果當成正式作答或成功 Result。
Kana Practice 的輸入模式、Submit、辨識 unavailable / error 與鍵盤降級狀態亦由
ViewModel 管理；辨識僅在使用者明確 Submit 後啟動。

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

Phase 1 Practice / Review 的 Use Case 負責建立／恢復 session、評估並逐題保存答案、
驗證完成前提、執行 `completeSession` 及讀取 Final Result；由 Repository 保證
§7.3 的有序題目快照、精確 revision、唯一答案、冪等與持久化狀態。

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

CR-0013 / SR-D01：Phase 1 沿用現有 App Shell「設定」目的地，作為 Settings
family 的可發現入口。這是 bounded Phase 1 placement，不要求新增 navigation
destination 或重組 Shell navigation architecture；不修改 Global Learning IA、
Level Selector、initial landing、Course navigation、Level recommendation 或
StudyGoal target semantics，A1-D1～D4 仍 OPEN。

Settings 與 Lesson 的 Furigana control 共用 §7.4.1 的單一全域 persisted
preference；confirmed value propagation、讀取失敗／retry 與 reading policy
priority 均依該節。SR-D01～03 核准不等於整個 Settings family UI/UX、05 V0.1
或 Global Design System 已批准；production UI 仍須通過 §6.1 適用 handoff gate。

Kana Practice 畫面須提供提示／發音動作、鍵盤與手寫模式、可書寫 Canvas、
清除／重寫、Submit、辨識結果、逐題正誤與正解、重試及明確 Continue。
觸控操作適用手機及具 touch / stylus 能力的 Windows 裝置；非觸控 Windows
不強制以滑鼠模擬手寫。無觸控／觸控筆、辨識或音訊時呈現明確可用性狀態，
鍵盤及視覺提示流程仍可用；正誤提示不只依賴顏色。

Kana Foundation entry 的獨立可發現性、skip / revisit 與 advisory-only deep-link
依 §1.1.1；不得只以 N5 entry 提供存取。本節不固定 entry placement、Home IA、
Level Selector 或 Navigation component；A4-D1 / A4-D3 保持 OPEN（§38.11）。

Vocabulary Index / Grammar Index 的獨立 entry、level browse 與 detail access 依
§1.2；不以 Lesson entry / completion 作前置條件。本節不固定 Reference IA、
entry placement 或 detail fields；A5-D1 / D3 保持 OPEN，A5-D2 僅 Search core
依 §1.2.5–1.2.10 已核准，Browse / Sort 與具體 Search interaction / presentation 仍 OPEN。
適用 production UI 仍須遵守 §6.1，不因 semantic 核准而視為 UI handoff 已完成。

Learning 的 global semantic frame、Level destinations 與 Course relationship 依
§1.3；semantic 核准不固定 final UI。A1-D1～D4、A4-D1 與 A5-D1 仍 OPEN，
不由本節指定 Home IA、Level Selector、initial landing 或 entry placement。

Assessment 的 independent Global Product destination 依 §1.4；Learning History
依 §13.6。本節不由 semantic 核准選定 Hub IA、Navigation component 或 history
timeline，A6-D1 / A6-D5 保持 OPEN；適用 UI 仍依 §6.1。

### 6.1 跨級別 UI/UX entry gate

05 應建立經 Developer 核准、N5～N1 可重用的 Design System baseline，涵蓋
typography、spacing、color roles、surface、card / divider、action hierarchy、
form / selection / feedback、loading / empty / error / retry、responsive、
accessibility、keyboard / focus、touch target 與可重用學習元件。後續級別優先沿用
已核准 baseline 與 interaction pattern；新內容複雜度超出既有規則時，建立
Design System extension，不預設每級各建獨立系統。

新的 learner-facing interaction / feature family，在 production Presentation、
ViewModel interaction、Widget、Navigation、focus、responsive 或 accessibility
行為開始前，須先有足夠穩定且正式核准的 Product Behavior 與 Data / Domain
Contract，並取得 Developer 核准、適用該 family 的 05 UI/UX Review、Design
Pattern、component / state、responsive、accessibility 及 implementation handoff。
05 可先做 audit、benchmark、研究、draft 與探索，但未核准 Draft 不得作最終
implementation handoff 或解除 Codex STOP Condition。若不受待定 UI 行為影響，
Migration、Domain、Repository、Use Case、Service abstraction 與非 UI tests 可先進行。

交付單位為 interaction / feature family，例如 Lesson / Reading、Practice /
Feedback / Result、Wrong Question / Review / Progress、Settings / Reset、Kana
Practice 與後續 Listening / Assessment；不要求每個 Widget 各走完整設計流程，
也不等整個 N5 完成才第一次進行正式 UI/UX。主要 family 實作後進行 05
implementation fidelity review，檢查 pattern、元件重用、視覺階層、responsive、
accessibility、鍵盤／焦點、loading / empty / error、字級縮放與一致性。
偏離已核准 Design Policy 時修正 implementation；若需改 Product Behavior、
Architecture 或 Data Contract，回 01 / Developer 決策，05 不自行改 Requirement。
各 JLPT level 的主要內容與適用功能達可整體檢視程度後，進行 level-wide UI
consistency audit；這是整合與精修，不是該級第一次正式 UI 設計。

### 6.2 教材 Visual entry gate

04 可提前做視覺研究、風格／候選探索與需求分析；探索成果不等於 production
asset authorization。Production-oriented visual asset 原則上在 learner-facing
Content scope 足夠穩定／核准、visual need 已確認，且 05 已提供適用 placement、
container、aspect ratio、responsive 與 accessibility / alt constraints 後，
才進入 04 planning、generation / selection 與 QA。

以穩定 Content batch 為單位完成 visual need review、04 visual batch、Developer
Visual Review，再取得獨立的 Production Integration Authorization，由 Codex 整合。
不要求每課立即生產圖片，也不等整個 App 完成才建立 visual direction。N4～N1
原則上沿用已核准 shared Visual Style / system，新增需求以 extension 處理。
04 Visual approval、05 UI/UX approval 或 03 Content approval，各自不等於 Codex
production implementation / visual integration authorization；asset、mockup、handoff
與 proposal 即使已核准，仍須有 Developer 對適用整合範圍的明確授權。

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
Kana content（Hiragana / Katakana）
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

Vocabulary Index / Grammar Index 是既有 Content Data 的 reference access，沿用
canonical identity、revision 與 release（§1.2.2）；不新增 Reference-specific content
entity 或平行資料來源。Grammar learning destinations 的 zero / one / multiple
semantic 不由本節資料清單推定 relationship schema，representation 仍屬 A5-D4。

CR-0012 Search 沿用上述 Vocabulary / Grammar identity、immutable revision、
ContentVersion 與 effective published content（§1.2.6）。Normalization 是 comparison /
search-key responsibility，不建立 Search-specific canonical entity，也不修改原文。
Local query / index mechanism 與 representation 不由本 CR 指定。

CR-0009 的 Canonical Vocabulary / Grammar Curriculum 為 coverage authority，
Course / Lessons 為 pedagogical organization（§1.3.3）；Lesson-scoped content
引用既有 canonical identities，允許 canonical item 無 Lesson mapping。
此為 Content semantic，不建立新 Entity、平行 Lesson-only source 或 Curriculum /
Course Manifest table / join；不改既有 contentId、revision 或 ContentVersion 契約。

### 7.2 User Learning State

使用者行為與歷史資料：

```text
UserProfile
QuizSession
QuizSessionQuestion（Phase 1 Practice / Review 有序題目快照）
QuizAnswer
Kana Practice attempt（依 Phase 1 schema design）
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
│   ├── Kana content
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
│   ├── QuizSessionQuestion
│   ├── QuizAnswer
│   ├── Kana Practice attempt
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

Learner primary JLPT target 的 authoritative owner 為既有 `StudyGoal.targetLevel`
（§15.2.2），不是 `UserProfile`、`AppSetting` 或 Derived Analytics；navigation /
selected / viewed level 另有其 semantic ownership。此 ownership 契約不指定
StudyGoal 的 SQLite table、persistence repository contract 或導入 Phase；A2-P1
仍 OPEN / DEFERRED（§38.11），不得由本節的資料分層圖推定 persistence timing。

Content Availability 依 §8.5 以 `JLPT Level × Content Family` 判定，不是 User
Learning State。Level-wide derived summary 也不是 learner progress / mastery
或 unlock state；其 persistence / schema / manifest / release metadata 表示仍由
A3-D4 決定，不由本節資料分層新增 Entity、table 或 persisted enum。

Kana Foundation progress 屬 learner state，不是 availability / unlock / target
state；沒有 progress 不推定 learner 不會 Kana（§1.1.1）。其 completion / progress
政策與 representation / persistence 仍由 A4-D2 / A4-D4 決定，不由此新增資料模型。

Phase 1 Practice / Review `singleChoice` 的空 Submit 是 validation event，不是正式
作答 attempt / `QuizAnswer`，也不增加 correct / wrong count。有效提交並完成
evaluation 後的 submitted answer snapshot 不得被同一 feedback state 的改選覆寫。
最後一題的 UI navigation 本身不建立或推定 `QuizSession` completion；必要作答
與 User Learning State 成功保存／確認後，才可依既有 Use Case / Repository
責任完成 session 並進入 Final Result。必要 persistence / completion 失敗時，
不得顯示已完成或假的成功結果，須保留安全的可恢復／重試狀態。本段不新增
schema、migration 或新的資料生命週期政策（CR-0003 原有邊界）；Phase 1
`singleChoice` Practice / Review 的新增持久化契約另依下列 CR-0004 §7.3.1，
若其仍不足以安全表達後續需求，依 Specification Decision 流程處理。

教學 Reading / Furigana alignment、發音來源參照與正式題目的 curated explanation
屬 Content Data；Show Furigana 與 Feedback Sound 開關屬 `AppSetting`。Mock Exam
交卷狀態、確認後完成時間與版本關聯屬 User Learning State；結果仍依既有
Assessment / Derived Analytics 責任分界管理。FeedbackReport 不混入學習證據或
Readiness，跨使用者 FeedbackCluster、ImprovementSuggestion、DeveloperDisposition
待 Cloud-capable Phase 才有 server-side 責任；實際儲存與留存政策依 §38.11 決定。

CR-0010 將 Learning / Assessment 的 historical evidence 與 current Mastery /
WeakPoint / Review Priority 分離（§13.2、§13.6、§16.1）。
Learning History 是 learner-facing projection / view，不要求單一 persistence table；
歷史 evidence 與 AssessmentResult / ReadinessSnapshot 不被後續 current state
retroactively 改寫。此分界不新增 User State、Assessment table、WeakPoint
storage representation 或 migration，也不改下列 Phase 1 durable session 契約。

CR-0011 的 current Tutor Session 採 ephemeral multi-turn context（§10.1.3），
不加入持久化 AiTutorConversation / AiTutorMessage、history UI 或 Cloud history /
cross-device sync。對話不自動成為 Content Data、QuizAnswer 或 learner evidence，
不更新 LearningProgress、WrongQuestion、Mastery、WeakPoint、Readiness 或
AssessmentResult；不得將其混入既有 durable session / answer 或 Derived Analytics。
Server operational metadata 與原文留存限制依 §34，不由 ephemeral 定位推定
provider retention 或新的 persistence / migration requirement。

CR-0012 query / result / detail navigation 是 discovery，不自動建立或更新上述
User Learning State、Derived Analytics 或 Assessment evidence（§1.2.9）。
V1 不要求 Search History / personalization persistence；後續增加須另作
Privacy / retention / Reset / learner-state 決策，不由本節新增資料模型或 migration。

#### 7.3.1 Phase 1 Practice / Review User Learning State（CR-0004）

本契約只適用 Phase 1 `singleChoice` Practice / Review（Learning Mode）。
`QuizSession.mode` 至少區分 `practice` 與 `review`，不得混同 Diagnostic、
Benchmark 或 Mock Exam。最小 persisted lifecycle 只有 `in_progress` 與
`completed`；本次不新增 persisted `abandoned`、`failed`，操作失敗不是
session lifecycle state。新 User Learning State identity 依 `DEC-P1-004`、
`DEC-P1-006` 使用 UUID v7，Domain / Application 為 `String`、SQLite 為
`TEXT`；`createdAt`、`startedAt` 及完成時的 `completedAt` 為明確持久化 UTC
ISO-8601 instant，UI 顯示轉 local timezone。`completedAt` 在 `in_progress`
語意上不存在，不得以 UUID 內含時間取代時間欄位。

建立 session 時須 durable freeze 精確 `ContentVersion`、依序排列的
`QuizSessionQuestion` snapshot、各題 exact immutable `Question` revision 與
ordinal / ordering evidence。既有 session 進行中，即使 current ContentVersion
或 published Question 更新，也不得靜默改用新版；`QuizSessionQuestion` 與
`QuizAnswer` 必須可追溯 exact revision，不能只記 current Question 或沒有
revision evidence 的 logical `contentId`。仍被 User Learning State 引用的舊
revision 依 `DEC-P1-007` immutable history contract 保留可追溯性。

每筆正式 `QuizAnswer` 至少表達 `answerId`、所屬 `QuizSession`、對應
`QuizSessionQuestion` / exact Question revision、提交的 `QuestionOption` identity、
correctness snapshot、`submittedAt` 與 `createdAt`。欄位命名可依既有程式風格
調整，semantic 不可變。每個 session question 最多一筆正式 submitted answer；
首次成功持久化後不得覆寫 option、correctness 或建立第二筆。相同 session / 題目
的重試若提交相同 option，回傳既有 durable snapshot；不同 option 為 conflict，
不得覆寫。此規則不擴張至 Kana / handwriting retry、其他題型或 Review scheduler
中的另一次正式作答。

有效 Submit 的必要順序為：選取驗證 → evaluation → 逐題 durable
`QuizAnswer` persistence → 確認保存成功 → submitted-answer feedback state。
空 Submit 仍依 CR-0003，不是正式 attempt。Evaluation 或保存失敗不得視作
incorrect、播放正誤音效、進入下一題或產生假的成功 state，須提供安全的錯誤／
重試處理。保存成功後才鎖定選項，保留答案 snapshot 並呈現 §14.1 的完整
逐題回饋；不可在同一 feedback state 改選重送。

App restart 後必須能恢復 `in_progress` Practice / Review session。對同一
stable learning context（該 Lesson / Practice activity 的 stable logical identity）
及相同 `QuizSession.mode`，最多只有一個 active `in_progress` session；
start / resume 預設回傳該既有 session。restart、重複呼叫、race 或反覆導航
不得建立第二個 active session。current `ContentVersion` 不屬於 stable learning
context identity；它是建立 session 時固定的 content snapshot。即使 current
published version 已更新，恢復時仍用原有 `ContentVersion`、有序 Question
revisions、ordinal 與 durable answers，不重建快照或因版本不同另開 session。
已 `completed` 的歷史 session 不是 active resume candidate，不阻止 learner
日後在相同 context + mode 建立新的 Practice / Review session。

`QuizSession` 還須保存足以 durable、無歧義重建目前 learner-facing 題目位置
與轉場的 presentation progress evidence。對目前及已呈現的 required question，
至少能區分以下語意狀態：
`awaiting_answer`（目前等待有效提交）、`answered_awaiting_continue`（正式
答案已保存並呈現完整 feedback，等待 learner 明確 Continue）及 `continued`（已
明確離開該題）。這些是必要 semantic，不強制 SQLite table / column 名、
persisted enum、private Repository method 或特定儲存表示；可用等價的持久化
結構，只要恢復結果無歧義。不得單靠哪些 Question 有 `QuizAnswer`，推定
learner 已執行 Continue，也不得把未呈現／未作答題目誤記為正式 answer。

新 session 的第一個 required question 為 `awaiting_answer`。有效 Submit 經
§7.3.1 逐題 durable `QuizAnswer` 保存成功後，目前題目的 progress 必須可
durable 重建為 `answered_awaiting_continue`，才呈現完整 feedback；此時
Continue 尚未發生。一般題由 learner 明確執行 Continue / 下一題，並在
progression durable 成功後，前一題才成為 `continued`、下一個 required
question 成為 `awaiting_answer`。若該 progression 未成功，不得當作已
continued。重啟前未 Continue 時，恢復原題正誤、submitted answer、正解、
curated / stored explanation 及 explicit Continue，不自動跳題或建立第二筆
答案；重啟前已成功 Continue 時，恢復正確下一題，不要求前一題再次 Submit。

最後一題的 durable answer 成功後仍為 `answered_awaiting_continue`，完整
feedback 與「查看本次結果」保持可見；在 learner 明確執行該 action 且正式
`completeSession` 成功之前，session 保持 `in_progress`。若此時重啟，恢復
最後一題完整 feedback 與該 action，不自動完成或顯示 Final Result。若
`completeSession` 失敗，仍為 `in_progress`，最後一題保持
`answered_awaiting_continue`，durable answers 保留；重啟後仍可重試
「查看本次結果」，不得產生假的成功 Result。Presentation progress 不取代
`QuizSession` 作為 completion 的 authoritative evidence。

本 CR 不新增 learner-facing Discard Session、Abandon Session 或 Start Over；
未來需要這些 UX 須另經 Product / Specification Decision。

最後一題仍完成逐題回饋與完整 curated / stored explanation；僅 learner 明確
執行「查看本次結果」才由 Use Case → Repository 呼叫 `completeSession`。
完成前須驗證 session 為 `in_progress`、題目 snapshot 存在、required question
set 完整，且每個 required question 均有 durable formal `QuizAnswer`。成功時
持久化 `status = completed` 與 UTC `completedAt`；失敗時維持 `in_progress`、
保留已保存答案，不進成功 Final Result，並可安全重試。對已 `completed`
session 重試 completion 為冪等成功，不建立第二份完成事實、不複製答案或改寫
`completedAt`。Widget navigation 不構成 completion。

Phase 1 第一版 Final Result 由已完成 `QuizSession`、其有序題目 snapshot 及
durable `QuizAnswer` 讀取／計算；`QuizAnswer` 是原始作答 evidence，
`QuizSession` 是 lifecycle / completion evidence。Result Page 與 Derived
Analytics 均非 authoritative completion state；不另建 authoritative
`QuizResult` persistence table。第一個 B0 Q-B0-01～03 `singleChoice` Practice
core loop 只需所有 required QuizAnswers durable 且 session completed，
不以 `WrongQuestion`、`LearningProgress`、`ReviewItem` 同 transaction 完成為
進入 Final Result 的前提。三者仍是 Phase 1 正式 User Learning State / workflow
requirements，不能移除、延後至 Phase 2 或以 Derived Analytics 取代。

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
音訊來源保留 Reference Audio / TTS abstraction 與必要 metadata；Phase 1
Learning Audio 依 `DEC-P1-001` 使用 Local / OS Japanese TTS，後續增強 provider 未定。
`AppSetting` 保存 Show Furigana 與 Feedback Sound 偏好，重啟後仍有效。Show
Furigana 首次使用預設 ON；Feedback Sound 依 `DEC-P1-003` 預設 ON 且使用者可
關閉。依 §17.1，Reset Learning Data 保留 App Setting，Factory Reset 恢復
預設；若將來增加其他 Settings reset scope，先記錄 Decision Record。

CR-0013 / SR-D02 — 單一全域 Furigana preference：

Settings 與 Lesson 控制同一個 persisted AppSetting.showFurigana；Lesson toggle
直接更新此全域偏好，不建立 temporary per-page override。偏好保存成功後，
所有適用的已掛載 Lesson / Practice inherit consumers 應反映最新 confirmed
value；尚未確認保存成功，不得宣稱新偏好已持久化。App restart 後仍使用
持久化偏好，正常首次初始化的 default ON requirement 不變。

Reading-aid presentation policy 依 DEC-P1-002：
inherit 依全域偏好；show 依正式題目政策顯示 reading；hide 依正式題目政策
隱藏 reading。Explicit show / hide 優先於 global preference。Mock Exam 只能
顯示正式題組定義的 reading aid，不因全域 Show Furigana 額外注入提示。

CR-0013 / SR-D03 — Global preference read failure：

| 情境 | 暫態呈現與 retry | 不得推定／寫入 |
|---|---|---|
| 目前執行期間已有成功確認的 preference value，但無法成功讀取 authoritative persisted value | 暫時沿用最後 confirmed value，提示設定狀態無法更新，提供可理解的 retry | 不宣稱已重新驗證 persisted value，不以讀取失敗覆寫已確認狀態 |
| 冷啟動且沒有任何 confirmed value，無法成功讀取 authoritative persisted value | 一般 inherit 教學文字暫採 surface-only，顯示設定讀取失敗狀態並提供 retry；核心 Lesson / Practice 閱讀仍可使用 | 不視為使用者選擇 OFF，不將 false 寫入 AppSetting，不建立 persisted fallback preference |

Authoritative persisted value 重新讀取成功後，恢復依正式偏好呈現、更新適用
consumers，並清除不再適用的錯誤提示。即使讀取失敗，explicit show 不受一般
fallback 覆蓋，explicit hide 不得洩漏 reading，Mock Exam 原有 reading policy
仍保持。此處 surface-only 是無 confirmed value 時的暫態呈現，不改變正常
首次初始化的 default ON；初次使用、singleton row missing、preference read
failure 與使用者選擇 OFF 是不同資料語意，不得混為一種情況。

本 CR 不新增跨重啟的 last-confirmed cache、DB 欄位或其他持久化機制；
不修改 ReadingText、ReadingSegment、ContentVersion、canonical reading
alignment、Content release 或 ruby renderer implementation contract。分層仍
依 §5，UI 不直接操作 DB；不把 application-scoped coordinator 的具體 class、
public API 或 subscription mechanism 固定成新的 Architecture Contract。

這些資料與 Mock Exam 交卷狀態若需 schema 變更，使用 versioned migration、
migration test 與可保留既有資料的升級路徑，不以刪除／重建資料庫替代一般升級。

Phase 2 AI Tutor 呈現 canonical Content 時沿用已驗證的 ReadingSegment /
reading policy（DEC-P1-002 / 007）。即時 AI 生成的新日文 V1 不自動產生或套用
canonical-style ruby / Furigana；文字讀音說明不等於 validated reading metadata，
也不得寫入 canonical ReadingSegment（§10.1.4）。此分界不降低正式教材的
離線 Reading Aid、預設 ON、使用者偏好或 Assessment 題組政策。

#### 7.4.2 Kana Content 與 Practice Answer（CR-0002）

Kana Content 的產品定位與 Foundation Core scope 依 §1.1，不因 Phase 1 N5
rollout 而將 Kana Foundation 設為 N5-owned content 或 synthetic N0。
本節既有 Content / Answer identity、版本、資料慣例與 Practice 契約保持不變；
不以 core scope 固定 lesson grouping、completion threshold 或新增 schema。

Phase 1 Kana Content 至少表達 kana identity、`hiragana / katakana` script type、
written Kana、validated pronunciation / reading、供發音抽象使用的 reading reference、
content version 與 learning / practice availability。Practice Answer 概念至少追蹤
expected Kana、鍵盤提交或辨識所得 Kana、`keyboard / handwriting` input mode、
correctness、attempt information 與 UTC timestamp。這些是概念責任，不鎖定
Entity、table 或欄位名稱；正式 schema 由 Phase 1 設計並以 versioned migration、
upgrade test 保留既有資料。Identity 使用 UUID v7 / TEXT；date-only 與 UTC
timestamp 分離；nullable 僅用於語意真正可缺值的資料，unavailable / unknown /
not-applicable 優先使用明確 status。這些資料慣例依已核准的 `DEC-P1-004`；
不得自行改選慣例。

此處 Kana learning / practice availability 須與 §8.5 的 product availability
契約一致，不以 Kana completion 或其他 learner state 決定 level access。
Kana 是否對應獨立 Content Family 仍屬 A3-D1，不在此固定 taxonomy；音訊、
recognizer、touch / stylus 的可用性屬 runtime / device capability，另依 §12.6、
§14.1 處理，不能取代 product availability state。

Kana Content 屬 Content Data；作答 attempt 屬 User Learning State，不把原始
作答僅存為 Derived Analytics。手寫 strokes / points 可在辨識處理中暫存，
處理後依最小化原則釋放；Phase 1 不永久保存完整軌跡、上傳至 Cloud 或訓練
使用者手寫模型。若未來要保存樣本，先取得 Privacy / Data Lifecycle Decision。

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
並驗證 Hiragana / Katakana Kana Content 的文字、讀音、script type 與版本
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

Reference Index 的 browse / detail 同樣受上述治理及 `DEC-P1-007 / 008 / 009`
約束（§1.2.2）；不新增 publication shortcut，不複製另一份 Reference content。
03 authoring、06 Independent QA 與 Developer 最終 Content Approval / Release
權限保持不變；既有 immutable revision、來源資格與 withdrawn 選取規則不改。

AI Tutor response 是 supplemental assistance，不是 Canonical Content、Content
Release、Approved Requirement 或 Developer Decision（§10.1）。不得直接修改
Lesson、Question、Correct Answer、Stored Explanation、Content Revision 或產品需求。
發現／回報教材可能錯誤時，仍走正式 Content / Feedback governance；不得繞過
DEC-P1-007 / 008 / 009 的 immutable revision、provenance、03 → 06 → Developer
與 publication 流程。

CR-0012 Search 同樣遵守正式 publication / provenance 與 QA workflow
（§1.2.6），只選 effective published Vocabulary / Grammar；結果不改 canonical
revision，不返回未發布或 withdrawn current result，也不以搜尋可見取代 Release approval。

### 8.5 A3 Content Availability Semantics（CR-0006）

#### 8.5.1 Authoritative scope 與核心狀態

Content Availability 的 authoritative scope 是 `JLPT Level × Content Family`。
Level-wide availability 只能是 derived summary，不能取代各 family 的正式判定。
核心 product availability states 為：

| State | 正式語意 |
|---|---|
| Available | 具備足以支援目前正式 learner flow 的可用 published content。 |
| Partial | 已有 learner-usable published content，但 coverage 不完整；learner 仍可存取。 |
| ComingSoon | 沒有目前 usable content，但具有正式 learner-facing future intent。 |
| Unavailable | 沒有 usable content，且沒有適用的 ComingSoon intent。 |

`Locked / Unlocked` 不得作為 Content Availability state。已 published 不直接
等於整個 family 已 Available；仍須符合目前正式 learner flow 的可用性語意。
Exact Content Family List 與 coverage completion / quantitative thresholds
分別由 A3-D1 / A3-D2 決定；不以此表硬編碼完整 taxonomy 或數量門檻。
ComingSoon 的 learner-facing presentation / ETA policy 保持 A3-D3 OPEN。

#### 8.5.2 Level summary aggregation

至少一個 family 為 Available / Partial，即表示該 JLPT Level 有 learner-usable
content。Level summary 依 relevant families 的狀態，按以下優先序推導：

```text
all relevant families Available
→ Available

otherwise any Available / Partial
→ Partial

otherwise any ComingSoon
→ ComingSoon

otherwise
→ Unavailable
```

本段只固定 aggregation 優先序；relevant families 的正式清單與 coverage 判定
仍依 A3-D1 / A3-D2，不由 summary 擴張為所有 family 的完整可用性宣告。

#### 8.5.3 Learner access 與狀態分離

Available / Partial 的內容可由 learner 存取，不受 `StudyGoal.targetLevel` 限制。
StudyGoal、target、progress、mastery、prior-level completion、Kana completion
或其他 learner state 均不得決定 Content Availability。Primary target ownership
與無 active StudyGoal 的語意維持 §15.2.2；navigation 不隱性修改 primary target。
N5→N1 是 development / content rollout 順序，不是 learner unlock 順序，
不要求 learner 先完成前級或 Kana 才可使用其他已可用內容。

#### 8.5.4 Content lifecycle、版本與 runtime boundary

既有 `draft / reviewed / published / withdrawn` lifecycle 保持獨立，依
`DEC-P1-007` 與正式 Content publication governance 處理。判定目前正常 learner
flow 的 usable published content 時，沿用既有 effective published / withdrawn
選取規則；不因 availability state 繞過 Content review、publication eligibility
或 withdrawal。`contentVersion`、immutable revision、provenance、歷史引用及
§7.3.1 原 Question revision 的 session / resume 契約均不變。

Runtime / device / network / provider / local download capability state 與 product
availability 分離；例如 Audio、recognizer 或網路不可用，不得據此把 product
availability 改成 Unavailable。個別能力的 failure / unavailable state 與離線
fallback 仍依既有 §12.6、§14.1 等契約處理，不因本節新增 Cloud dependency。

Search Result presence 不取代本節 product availability 判定（§1.2.6）；Search
不建立新的 availability state，不由匹配結果推定 family / Level coverage 完整。
Search 的 offline runtime responsibility 與 capability 分離仍依 §1.2.9。

#### 8.5.5 下游契約與未決邊界

本節是 A5 / Level Selector / future Reading & Listening availability 的上游
semantic contract；A5 core semantic 另依 §1.2，A1 global semantic frame 依 §1.3；
不由本節核准 Level Selector、Home IA 的具體 UI 或其他下游 feature design。Persistence / schema / manifest / release metadata representation 仍屬
A3-D4 OPEN；本節不建立 DB table、persisted enum 或 migration，不決定 Cloud
contract 或 Content Update protocol，不改 Phase scope。A3-D1～D4 依 §38.11
保持 OPEN，不得由 Codex 代決或硬編碼。

### 8.6 A1 Canonical Curriculum / Content Governance（CR-0009）

01 / Developer 定義產品與 curriculum ownership boundary；03 負責 N5～N1
Vocabulary / Grammar curriculum research、canonical curriculum candidate、
Course Manifest、Lesson sequence / mapping candidate、learner-facing Content
及 Author QA。06 負責 Independent QA，Developer 負責 final Curriculum /
Content Approval。03 若發現需要改變 A1 product architecture，交回 01 / Developer。

實際 inventories、classification、coverage count 與 lesson / Practice 詳細內容
須由上述流程處理，不由 02 Candidate integration 自行決定。
沿用 `DEC-P1-007 / 008 / 009` 的 canonical identity、immutable revisions、
ContentVersion、publication lifecycle、provenance、來源資格、Author QA /
Independent QA 與 Developer approval；不以 Curriculum / Course 名稱繞過
publication。03 的 curriculum authoring 職責不移除 `DEC-P1-008` 既有 Codex
技術 Curriculum / Manifest proposal 角色；proposal 不等於正式 Curriculum 批准。

CR-0010 的 Assessment Content 仍依 03 原創 authoring / Author QA → 06
Independent QA → Developer final Content Approval，沿用 `DEC-P1-007 / 008 / 009`
的 publication、immutable revision 與 provenance。JLPT 公開資料是 Reference Source，
不是 Copy Source；不因官方資料公開而授權複製題庫或繞過 Content governance。

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

Context-Aware AI Tutor Q&A 亦由 AiService / Repository abstraction 承接，
Presentation / ViewModel 只透過 Use Case 呼叫，不直接組裝 Provider 呼叫或存取
平台／資料庫。Tutor 的正式 request boundary：

```text
Flutter
 ↓
Presentation / ViewModel
 ↓
Use Case
 ↓
AI Service / Repository abstraction
 ↓ HTTPS
ASP.NET Core AI Gateway
 ↓
AI Application Use Case
 ↓
Prompt / Context Builder
 ↓
Provider Adapter
 ↓
AI Provider
```

Context assembly 使用 deterministic canonical identity（§10.1.2），不得只傳
畫面文字而失去 revision；回應須經 schema validation（§10.1.6）。精確 API /
DTO / method naming 由 Phase 2 Architecture / implementation design 決定，
本節不新增固定 endpoint、provider-specific client contract、Vector DB 或
Embedding Store；永久 Provider secret 不放 Flutter App。

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

#### 10.1.1 Context-Aware AI Tutor Q&A — 定位與 entry（CR-0011-D1）

Phase 2 V1 提供 learner-facing Context-Aware AI Tutor Q&A，讓 learner 閱讀
正式教材或 Practice curated explanation 後，直接針對目前 learning context
以文字追問，不必重新複製或描述正在學習的教材。Tutor 定位為 Supplemental
Learning Assistance；正式教材與 curated / stored explanation 持續為
authoritative learning baseline，不被 Tutor response 取代。

支援 contextual entry：Lesson（主要入口）、LessonSection、Vocabulary、Grammar、
ExampleSentence，以及 §10.1.5 的 Practice / Review post-feedback。
本 CR 不決定 Global AI Tutor destination、AI Teacher home tab、通用無 context
chat 或 final Global IA；若未來需要，另行 Product / UI/UX Decision。
適用 Presentation implementation 仍依 §6.1 的 UI/UX entry gate。

#### 10.1.2 Canonical context 與 knowledge boundary（CR-0011-D2）

回答採 Canonical-first + Supplemental Japanese Knowledge，優先 current canonical
App Content；必要時可用一般可靠日語知識補充更簡單的解釋、相似文法比較、
額外原創例句、使用原因或 learner error explanation。不得把 supplemental
knowledge 偽裝成 canonical App Content。

Tutor context 使用 canonical identity 與精確 revision / release，例如
contentId、contentRevisionId、contentVersionId、contextType；必要時附
selectedText、surrounding context、related Grammar / Vocabulary 或 stored
explanation。沿用 DEC-P1-007 的 logical identity、immutable revision 與
ContentVersion 區別，不只依當下畫面文字，也不新增平行 canonical source。
上述名稱表達責任，不在本 CR 固定 API schema 或新增資料表。
V1 以 deterministic canonical context identity 組裝 context，不要求 Vector DB、
Embedding Store 或 full semantic RAG；跨教材 retrieval / global semantic search
須另行評估與核准 retrieval architecture。

#### 10.1.3 Multi-turn / ephemeral Tutor Session（CR-0011-D3 / D4）

支援 current Tutor Session 內 multi-turn conversation，綁定啟動時的 learning
context / content revision；navigation 到另一教材不得無聲轉換原 conversation
的教材 context。Canonical context 實質變更時，建立新的 Tutor context / session。

Multi-turn context 可在 current Tutor Session 存續，但 V1 不要求離開後回看歷史。
不新增 AiTutorConversation / AiTutorMessage persistent history、Tutor history UI、
Cloud chat history 或 cross-device chat sync。Local-only Tutor History 仍為未來
獨立需求；ephemeral 不授權永久 server-side application history，亦不推定
provider 的實際 retention（§34）。本 CR 不建立 session history schema / migration。

#### 10.1.4 Language / Furigana boundary（CR-0011-D5）

解釋使用繁體中文（臺灣，zh-TW），日文例句使用日文。Canonical Content 既有
validated reading metadata 沿用 ReadingSegment / reading policy（§7.4.1）。
即時 AI 新日文 V1 不自動產生或套用 canonical-style ruby / Furigana。
可用文字說明「『旅行』讀作『りょこう』」，但該 AI response 不等於
Canonical ReadingSegment 或 validated Content reading metadata。若未來加入
AI-generated ruby / reading aid，須另定不同於 canonical reading 的 semantic /
trust boundary，不由全域 Show Furigana 偏好自動擴張。

#### 10.1.5 Practice / Review post-feedback（CR-0011-D6）

Tutor entry 只能在既有正式逐題 feedback sequence 完成後提供：

```text
Valid Submit
 ↓
Durable QuizAnswer
 ↓
Correct / Incorrect feedback
 ↓
User answer
 ↓
Correct answer
 ↓
Stored curated explanation
 ↓
問 AI 老師
```

沿用 §7.3.1、§14.1 的保存確認與回饋／Continue，不以 Tutor 取代 stored
explanation、解除 submitted-answer lock、自動跳題或完成 session。
正式 Submit 前不得透過 Tutor 洩漏正解、explanation 或 scoring information。
回答可用的最小 context 包含 question canonical identity、submitted answer、
correct answer、stored explanation 與 related canonical learning context。

Tutor interaction 不是 QuizAnswer、scoring / Result mutation、WrongQuestion、
Mastery 或 Assessment evidence。此入口不新增 Kana retry 或其他 answer type
的作答／保存契約；既有 Practice contract 保持不變。

#### 10.1.6 Structured response 與 insufficient context

Response 不只依賴無約束自由文字 transport，須有可 schema validate 的 structured
response，至少表達 answer、examples、適用時的 related concepts / references、
answer basis 與 limitation / insufficient context。Answer basis 至少可區分：

- CONTENT_GROUNDED。
- CONTENT_PLUS_SUPPLEMENTAL_KNOWLEDGE。
- INSUFFICIENT_CONTEXT。

Transport / runtime 可另表達 UNAVAILABLE；不可用不等於 context 不足。
資料不足可明確表示無法可靠回答，不要求模型猜測；不得將 invalid response
當成有效的可靠回答。精確 API schema 留待 Phase 2 Architecture /
implementation design，不改上述 product semantics（§38.11）。

#### 10.1.7 Online / failure / evidence / Assessment boundary

Tutor 是需 network / AI Gateway 的 online enhancement。系統至少處理 offline、
gateway unavailable、timeout、rate limited、provider unavailable、invalid response
與 insufficient context；Tutor failure 不破壞 canonical learning flow 或核心
learning state。Lesson、Vocabulary、Grammar、Furigana、Practice、stored
explanation 與 core offline learning 仍可使用。Retry / timeout 參數於 Phase 2
Architecture / implementation decision 決定，沿用 §9.2 Gateway responsibility。

V1 conversation 不自動更新 LearningProgress、建立 WrongQuestion、更新
LearnerKnowledgeMastery / WeakPoint、改變 Readiness 或產生 AssessmentResult。
未來若使用對話作 learner evidence，須先建立正式 evidence semantics；
§13 的 Learning / Assessment evidence 不因此包含 Tutor chat。

Active Diagnostic、Benchmark、Mock Exam 期間 Tutor 預設 DISABLED，不提供
破壞 assessment validity 的 assistance。Assessment 完成後 Result / Review 的
Tutor permission 由該 Assessment phase 的正式 policy 另決；既有 Mock 的
AI review assistance 能力不表示已核准該 Tutor permission（§14.6、§38.11）。
Data minimization 與 server / provider retention 依 §34。

#### 10.1.8 V1 non-goals 與治理限制

V1 為 text input，不授權 voice conversation / live voice teacher、image /
screenshot Q&A、AI grading learner knowledge from conversation、automatic
mastery updates、Cloud conversation sync、cross-device Tutor history、global
semantic search、AI-generated canonical Content publication 或把即時 Furigana
自動視為 canonical metadata。Global AI Chat 與 persistent history 不在 V1 scope。

Response 不等於 Canonical Content、Content Release、Approved Requirement、
Assessment Evidence 或 Developer Decision。AI 不直接修改正式教材、題目、
答案、stored explanation、revision 或 Product Requirement；疑似教材問題仍依
§8.4 / §33.1 走正式 Content / Feedback governance。CR-0011 不授權自動
Product / Content change，也不授權提前開始 Phase 2 implementation。

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

Phase 1 Kana 聽音作答沿用 `DEC-P1-001`：經 Audio / Speech Service 抽象使用
Local / OS Japanese TTS 與已驗證的 contextual reading；日語 voice 不可用時顯示
狀態與安裝／啟用指引，不阻斷視覺提示的 Kana Practice。核心練習不依賴
Remote TTS、Cloud 或 AI API；Audio unavailable 不代表 Kana Content 不可用。
本節 Audio runtime capability 與 §8.5 product availability 為不同狀態維度。

## 13. 學習進度、Knowledge Mastery、錯題與 Review

### 13.1 LearningProgress

LearningProgress 保留整體學習歷史：

§7.3.1 第一個 B0 Practice core loop 不以 `LearningProgress` 與 session completion
同 transaction 完成為前提；本節的進度功能與 Phase 1 gate 均仍須實作與驗證。

```text
firstLearnedAt
lastReviewedAt
reviewCount
correctCount
wrongCount
masteryScore
nextReviewAt
```

Reference browse / detail view 不自動等於 completion、mastery 或 Assessment
evidence（§1.2.4）；A5-D5 保持 OPEN，不由此新增 Reference progress / exposure
追蹤政策，亦不修改下列既有 Knowledge Mastery、Review 或 Coverage contract。

LearningProgress 中的歷史學習／作答與後續 current mastery、weakness、
review priority 不視為同一事實；learner-facing history view 依 §13.6。
既有 Reference browse / detail 不自動成為 completion / mastery / Assessment
evidence 的邊界不變，不由 CR-0010 新增 viewing / exposure policy。

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

Learning 與 Assessment 均形成 learner evidence，但不同 evidence source 不視為
等價；Practice / Review、Diagnostic、Benchmark、Mock Exam 的用途、validity
及 context 必須保持可區分，不以單一未決權重合併。Historical evidence 與
current `LearnerKnowledgeMastery` / WeakPoint / Review Priority 分離，
不以後續 state 改寫原 evidence；A6-D6 Cross-mode Evidence Weighting 與既有
MasteryPolicy、ReadinessPolicy、Data Confidence 仍依 §38.11 待決。

CR-0011 的 AI Tutor conversation 屬 supplemental assistance，不是上述正式
learning / assessment 作答證據。V1 不因問答更新 LearningProgress、
WrongQuestion、LearnerKnowledgeMastery、WeakPoint、Readiness 或
AssessmentResult（§10.1.7）；A6-D6 不得被用來繞過此邊界，對話 evidence
若未來需要，須先另行正式決策。

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

`QuizAnswer` 為正式原始作答證據；§7.3.1 的第一個 B0 Practice core loop
不以 `WrongQuestion`、`LearningProgress`、`ReviewItem` 與完成操作同 transaction
寫入為 prerequisite。此分段交付不刪除本節錯題、Review 與進度的 Phase 1 要求。

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

WrongQuestion 是錯題相關紀錄，不等於以 KnowledgeConcept 為核心的 WeakPoint。
Remediation 不要求 learner 永遠重做同一題，可使用適用的 concept-level learning /
practice；不由此決定 Practice collection、選題或新增 activity contract。
WeakPoint resolution 不等同自動刪除 WrongQuestion；WrongQuestion learner-facing
lifecycle 仍屬 A6-D7，不移除本節既有功能或 §17 Reset scope。

Adaptive Review 優先 weak / improving / low-confidence concepts；high mastery
降低重複優先度，但不永久排除該 concept。WeakPoint resolved 預設退出 active
weakness queue，後續新 negative evidence 可 reopen（§16.1）。
本段不固定 suppression 門檻、evidence count、spaced repetition algorithm 或
review interval；A6-D3 / A6-D4 與既有 policies 仍 OPEN。
Adaptive learning 不得改變 fixed Benchmark / Mock Exam 的題組與 validity。

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

### 13.6 Learner-facing Learning History（CR-0010）

產品提供 learner-facing Learning History，呈現 Learning / Assessment 的歷史
evidence 與結果。History 是 projection / view，不要求單一 persistence table，
也不是 current Mastery、WeakPoint 或 Review Priority 的 authoritative replacement。
既有 Reference viewing semantic 不因 history 而擴張。

後續 learning / assessment 可更新 current state，但不得 retroactively 改寫
historical evidence、AssessmentResult 或 ReadinessSnapshot；例如 weakness
resolved / reopen 不改寫當時的作答、評估結果或準備度 snapshot。
本節不決定 timeline UI、欄位、filter 或 history persistence，A6-D5 保持 OPEN。
保留歷史不建立新的永久 retention policy，也不豁免 §17 已核准的明確 Reset /
Delete scope；不得把 resolution 自行視為刪除歷史的操作。

## 14. Assessment Engine

Assessment 依用途區分為 Practice、Diagnostic、Benchmark 與 Mock Exam：

Assessment 的獨立 entry 與 N5～N1 destinations 依 §1.4；discoverability 不代表
各 mode / level 的題組已可用，不建立 sequential assessment unlock。
Assessment context 不取代 primary StudyGoal target。Diagnostic 是 baseline、
Benchmark 是可重現比較、Mock Exam 是模擬作答；下列各自 feedback / validity
契約不變，不因 Hub、Learning History 或 adaptive review 混用模式。
A6-D2 mode availability / rollout、Assessment question-set / validity /
Presentation Policy 與 Mock Exam execution 仍待正式決策，不擴張 Phase 1 題組範圍。

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
時長、音量、動畫與 haptic 依適用階段 Decision Record；Phase 1 依
`DEC-P1-003` 以兩個短的 packaged local sounds 分別提示正誤、預設 ON、
可於 Settings 關閉，並等待使用者明確 Continue。Phase 1 正式離線題目使用
curated / stored explanation；AI 只能於後續 Phase 增強。

Phase 1 `singleChoice` Practice / Review 的 Submit control 保持可操作。未選取
答案就按 Submit 時，顯示 accessible validation message「請先選擇一個答案。」，
並將焦點導向可理解的 option group / validation context；不自動選取任何
選項。此操作不是答錯：不執行 evaluation、不建立正式作答 attempt /
`QuizAnswer`、不增加 correct / wrong count、不播放正誤音效、不顯示
correctness、正解或詳解，亦不
進入下一題。使用者完成有效選取後，validation state 應可清除。

有效答案經 explicit Submit、成功 evaluation 與 §7.3.1 逐題 durable
`QuizAnswer` 保存確認後，才建立本次 submitted-answer feedback state；
該題選項鎖定至使用者執行 explicit Continue（最後一題為
「查看本次結果」）；保留 submitted answer snapshot，不能改選覆寫或在同一
feedback state 直接重新 Submit。使用者答案與正解保持可區分，鎖定後
內容仍須可閱讀且無障礙。Evaluation / persistence
error 不視為 incorrect answer。此鎖定僅限 Phase 1 `singleChoice` Practice /
Review，不套用 Kana / handwriting retry、其他 answer type 或 Review scheduler
中的另一次正式作答；未來若加入同題 explicit retry，須先另定 attempt identity、
保存與評分語意，不得僅解除 UI lock。

最後一題仍須完成一般逐題的正誤、使用者答案、正解及完整 curated / stored
detailed explanation，不自動跳過或直接進入 Result。完整 feedback 呈現後，
提供明確 learner action「查看本次結果」；只有使用者執行該 action，且 §7.3
所述必要 evaluation、保存與正式 session completion 成功後，才進入既有
Final Result flow。UI navigation 不得自行製造完成狀態；必要操作失敗時依
既有 error handling contract 保留安全狀態，不顯示假的成功 Result。
`completeSession` 須依 §7.3.1 驗證題目快照與 durable answers，成功後的
Final Result 由已完成 session、快照及答案讀取／計算。若 CR-0004 契約仍不足以
安全實作其他 schema / contract 需求，須 STOP / CHAT_HANDOFF，不得自行擴充。

重啟後的 Practice / Review 題目位置與回饋須依 §7.3.1 的 durable presentation
progress 恢復：已保存答案但尚未明確 Continue 的題目仍顯示完整 feedback；已
Continue 的一般題回到下一個未作答題；最後一題尚未成功 `completeSession`
時仍顯示 feedback 與「查看本次結果」，不得僅因所有答案已有記錄就跳 Result。

Kana Practice 是 Learning / Practice Mode，不是 Mock Exam。Phase 1 同時支援
Hiragana / Katakana 的四種流程：聽發音或顯示學習提示／目標，各自接鍵盤
輸入或觸控／觸控筆手寫 Kana。鍵盤 expected answer 為正式 Kana；平台 IME
可將 Romaji 轉換成 Kana，但未轉換的直接 Romaji 不視為正解。手寫時可清除、
重寫；明確 Submit 後才由 `HandwritingRecognitionService` 回傳 Kana candidate
或 unavailable / error，正常辨識時與 expected Kana 比對。提交後顯示
辨識／提交內容、正誤、正解及離線 curated explanation 或學習提示，可重試；
沿用 `DEC-P1-003` 的可關閉音效、無障礙回饋及使用者明確 Continue，不能自動
跳題。辨識失敗或裝置無 touch / stylus 時鍵盤模式仍可完成練習。Phase 1
只判定所寫 Kana，不做筆順、角度、速度、書法美觀或 AI 品質評分。

CR-0009 的 Lesson Practice、Vocabulary Level Practice、Grammar Level Practice
contexts 依 §1.3.4；三者可共用 infrastructure，但不混淆其 learning context。
本節既有單題回饋、durable answer / resume / completion、Kana retry 與
Assessment 分界保持不變；不由 context 名稱決定 Practice collection、題型、
題數、selection、scoring 或 mastery effect，A1-D6 仍 OPEN。

Practice / Review 的 reading-aid presentation 沿用 DEC-P1-002 與 §7.4.1：
適用的已掛載 inherit consumers 依全域 confirmed preference 呈現；
讀取失敗／retry 不覆蓋 explicit show / hide，亦不改 Mock Exam 正式題組政策。
此為呈現偏好契約，不修改上述逐題 feedback、§7.3.1 durable session、
resume / Continue / completion 或 Final Result 契約。

Phase 2 Practice / Review contextual Tutor 依 §10.1.5，只有 Valid Submit、
durable QuizAnswer 與正誤、使用者答案、正解及 stored curated explanation 完整
呈現後提供「問 AI 老師」。未提交不得揭答；Tutor 不替代逐題回饋、改分、
改 Result、auto advance 或寫入正式 learner evidence。原有 Kana / handwriting
retry、singleChoice lock、explicit Continue / Final Result 與 resume 契約不變。

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

上述「第一次進入目標等級時，可進行 Diagnostic」描述 initial / baseline use case，
不表示 learner lifetime 或該 JLPT Level 僅能執行一次 Diagnostic。
未來可允許 learner 重新執行 Diagnostic，以刷新適用的 baseline / learner evidence；
是否提供 repeat、repeat trigger、cooldown、frequency、題組重用／更新方式等，
仍屬 downstream Assessment policy，依 §38.11 A6-D2 保持 OPEN，不由 CR-0010 固定。

本流程選擇的 JLPT level 是該次 Assessment 的 context，不因進入或選取級別
隱性更新 learner primary `StudyGoal.targetLevel`（§15.2.2）。

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

`AssessmentSession.targetLevel` 只代表該次 Assessment 所適用的 JLPT level；
不得作為 learner current primary target 的 authoritative source（§15.2.2）。
Assessment level 不構成 learner unlock 或 content availability state。

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

Historical AssessmentResult 不因後續 Mastery、WeakPoint resolution / reopen、
Review Priority 或其他 current state retroactively 改寫（§13.6）。
Adaptive learning 不得改變 fixed Benchmark / Mock 題組、scoring reproducibility
或 validity；A6-D6 evidence weighting 不豁免各模式既有有效性邊界。

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

Context-Aware AI Tutor 依 §10.1.7：active Diagnostic / Benchmark / Mock 預設
DISABLED，不得洩漏答案或提供破壞 validity 的 assistance；完成後 Result /
Review 是否允許 Tutor，仍待適用 Assessment phase 的正式 policy（§38.11）。
§14.4 既有交卷後 AI Review assistance 不自動授權 Tutor entry；不改各模式
feedback、固定題組／scoring 版本、knowledge mapping 或有效性契約。

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

`ReadinessSnapshot.targetLevel` 只代表該 snapshot 所適用的 JLPT level，
不取代 `StudyGoal.targetLevel` 作為 learner current primary target 的 authoritative
source（§15.2.2）；不得從某一級別 snapshot 的存在反推目前 primary target。

Historical ReadinessSnapshot 表達當時的評估／policy context，不被後續 Mastery、
WeakPoint 或 Review Priority retroactively 改寫（§13.6）。
此契約與 Derived Analytics 可由 evidence 重算並存；更新 current estimate 不等於
改寫舊 snapshot。不由 A6 semantic 決定 evidence weights、Data Confidence、
Readiness threshold，Readiness 仍不是官方分數或通過機率。

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

#### A2-Core — Learner Target Ownership（CR-0005）

沿用上述既有 `StudyGoal` 與 `targetLevel` 概念，不建立新的 domain model。
`StudyGoal.targetLevel` 是 learner primary JLPT target 的 authoritative owner，
表示主要 learning target 與 exam-preparation target。`AppSetting` 與 `UserProfile`
不得成為 `targetLevel` 的 authoritative owner。

`targetLevel` 不是 learner unlock state、content availability state，亦不是目前
navigation / selected / viewed level state。`selectedLevel / viewedLevel` 與
`StudyGoal.targetLevel` 必須保持不同 semantic ownership；learner 瀏覽、學習
或 navigation 到其他 JLPT level，不得因此隱性修改 `StudyGoal.targetLevel`。
本契約不指定 selected / viewed level 的具體 UI control 或儲存設計。
CR-0009 進一步固定：只有 explicit learner target-change action 可改 primary
target（§1.3.2）；Level destination / Course / Reference navigation 均不構成該 action。

Learner 可存取所有目前已有 available content 的 JLPT level，不受
`StudyGoal.targetLevel` 限制。沒有 active `StudyGoal` 表示尚未設定 primary JLPT
target，不得因此阻止使用 available content；不得從瀏覽級別或其他 record
的 `targetLevel` 猜測 learner 已設定 primary target。

`AssessmentSession`、`ReadinessSnapshot`、`StudyPlan` 及其他 contextual /
historical records 的 `targetLevel`，只代表該 record 所適用的 JLPT level，
不得成為 learner current primary target 的 authoritative source。資料／分析記錄
與目前 primary target 的責任分界依此契約，不新增其他 records 的 schema。

A2-P1 StudyGoal Persistence Timing 與 A2-R1 Reset Semantics 均仍 OPEN / DEFERRED
（§38.11）。CR-0005 不指定 Phase 1 是否建立／persist StudyGoal、導入 Phase、
SQLite table / schema、migration timing、persistence repository contract 或重啟
持久化實作時點；亦不決定 StudyGoal 的 Reset、刪除或 retention lifecycle。
Ownership 確立不等於上述事項已獲核准。

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

上述 N5 是 Readiness 呈現範例，不是 learner target 的預設值或 owner；目前
primary target 仍依 §15.2.2，不從首頁呈現或 viewed level 反推。
本次 CR-0005 不決定 Home / Global IA 或 targetLevel control design。

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

CR-0010 的 WeakPoint lifecycle semantic 為 active → improving → resolved，
並可因新 negative evidence reopen。這些是 concept-level weakness 的產品語意，
不鎖定 persisted enum、table 或 storage representation。
Single correct answer 不足以自動 resolution；resolved 預設退出 active weakness
queue，但不刪除 historical evidence，亦非永久不再 review。
Resolved 後的新 negative evidence 可重新開啟 weakness；不由本段指定 exact
threshold、evidence counts、confidence 或 transition algorithm，A6-D3 仍 OPEN。

Historical evidence、current Mastery / WeakPoint 與 Review Priority 保持分離；
WrongQuestion 不等於 WeakPoint。Remediation 可針對 concept，不要求永遠重做
同題（§13.3）。Resolved / reopen 不 retroactively 改寫 AssessmentResult /
ReadinessSnapshot，也不自行決定 WrongQuestion lifecycle 或 Reset。
本節 existing KnowledgeConcept / QuestionConceptMap 與 WeakPointPolicy 契約不變。

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

`StudyPlan.targetLevel` 只代表該 plan 所適用的 JLPT level，不是 learner current
primary target 的 authoritative source；生成或查看 plan 不隱性修改
`StudyGoal.targetLevel`（§15.2.2）。本段不改 Study Plan 排程政策。

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

本表不決定 `StudyGoal` 的 Reset / deletion lifecycle。A2-R1 仍 OPEN / DEFERRED
（§38.11）：Reset Learning Data 是否保留 StudyGoal、Factory Reset 是否刪除、
其 reset scope 與 deletion lifecycle 尚未核准；不得以「清除所有學習狀態」、
App Setting 保留／恢復預設或 target ownership 推定 StudyGoal 的處置。
其他既有 Reset scope 保持不變。

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
§17.1 的「重置測驗紀錄」包含 §7.3.1 Practice / Review session、其題目快照
與答案關聯，仍須在 transaction 中遵守既有 Reset scope；Content Data 及仍被
其他 User Learning State 引用的 immutable revision 不得因測驗紀錄重置而誤刪。

CR-0010 的 Learning History projection、WeakPoint resolved / reopen 不新增
Reset / Delete scope 或 retention policy；resolution 本身不刪 historical evidence，
不等同「清除錯題」或「清除學習歷程」。上述既有明確 Reset 仍依 §17.1–17.2；
WrongQuestion learner-facing lifecycle 由 A6-D7 決定，不由 current weakness
變化推定 persistence deletion，不改 A2-R1。

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

Phase 2 Context-Aware AI Tutor 的處理鏈依 §9.3：Gateway 的 AI Application
Use Case 透過 Prompt / Context Builder 組裝 canonical revision-bound minimal
context，再由 Provider Adapter 呼叫 AI Provider，並驗證 structured response。
保留 Gateway 的 rate / usage / cost control、timeout / retry 與不記錄敏感原文
責任；本 CR 不新增固定 Tutor endpoint、帳號、PostgreSQL 或 Cloud history。
Operational metadata 與 prompt / response 留存限制依 §34 / §38.11。

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

新的 learner-facing interaction family 進入 production UI 前，依 §6.1 核對
正式 Product / Data Contract 與適用的 Developer-approved 05 handoff；UI 以
interaction family 交付並接受 fidelity review，級別整合時做 consistency audit。
04 production visual 依 §6.2 核對穩定 Content、visual need 與 05 placement 等
約束，按穩定批次交付；04 Visual Review 與後續 Codex integration 授權分開。
未核准 Draft、Work output 或 local handoff 不能被本節自動提升為正式依據；
任務授權與 Source of Truth 仍依 `AGENTS.md`。

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
singleChoice empty Submit validation / no attempt、count、sound 或答案揭露
singleChoice submitted-answer snapshot / lock / no same-state re-Submit
Practice / Review completion requires evaluated and saved state; persistence error is not incorrect
Practice / Review session mode / lifecycle / UTC timestamps / UUID v7 identity
immutable ordered session question snapshot / exact ContentVersion and Question revisions
one durable immutable QuizAnswer per session question / QuestionOption identity / correctness snapshot
same-option Submit retry idempotency / different-option conflict / no duplicate answer
in_progress restart resume with original question set and durable answers / no duplicate session
stable logical context + mode 的單一 active session / completed history 不阻止新 session
durable presentation progress 的 awaiting_answer / answered_awaiting_continue / continued
completeSession preconditions / completedAt / idempotent completion / failure recovery
Final Result source = completed QuizSession + snapshot + durable QuizAnswers
User Learning State migration fresh / upgrade / reopen / Content Data preservation / FK constraints
Kana script / expected-answer evaluation / IME-converted Kana vs direct Romaji
Kana handwriting candidate / unavailable / error / keyboard fallback
Kana attempt identity、UTC timestamp、status 與 migration upgrade
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
singleChoice empty Submit message / focus / selection 後清除 validation
singleChoice post-submit readable locked options / distinct user and correct answer
last-question full feedback / explicit「查看本次結果」action
Practice / Review 保存失敗時不顯示成功 feedback 或正誤音效；恢復後呈現原題目與作答
completed session 才能顯示 Final Result；完成失敗仍可安全重試
restart before / after Continue 恢復對應 feedback 或下一題；最後一題不自動 Result
Kana Practice keyboard / handwriting canvas / clear / rewrite / submit / retry / continue
Kana touch / stylus availability and accessible feedback on supported platforms
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

Phase 1 `singleChoice` Practice / Review integration 須驗證：空 Submit 不建立正式
作答或計數、不播放回饋音效、不揭露答案且不換題；有效 Submit 後選項鎖定、
作答 snapshot 不被改選或重送覆寫；最後一題仍顯示完整逐題回饋，使用者明確
點選「查看本次結果」才進入 Final Result。Evaluation、必要 persistence 或
session completion 失敗時不得顯示 incorrect 或假的成功 Result，須保留安全
可恢復狀態。此回歸只針對 Phase 1 `singleChoice`；Kana retry 與 Mock Exam
既有政策不受影響。

CR-0004 的 Phase 1 `singleChoice` integration 另須驗證：建立 session 時固定
有序題目快照、ContentVersion 與 exact Question revisions；Content 更新後舊
session 不換題；逐題保存成功前無成功回饋；同選項 retry 回傳原 answer，不同
選項 conflict；重啟後恢復同一 `in_progress` session 與原 durable answers；
最後一題仍完整回饋，只有明確「查看本次結果」後且 required answers 全數
durable 才完成；answer / completion failure 不產生假 Result，完成重試不改
`completedAt`。Final Result 須可由已完成 session、快照及 answers 重建。
資料庫測試含舊 production schema 升級、新安裝、重開、Content Data 保留、
ID / FK / 唯一性、不變性、冪等與失敗恢復；記錄實際工作樹及驗證環境。

Resume progress 至少驗證七種情境：

1. Q1 answer durable 後、Continue 前重啟：恢復 Q1 完整 feedback，仍須明確 Continue。
2. Q1 明確 Continue 且 progression durable 後、Q2 作答前重啟：Q2 為目前未作答題，Q1 不重送。
3. 最後一題 answer durable 後、「查看本次結果」前重啟：恢復最後一題 feedback 與該 action，session 仍 `in_progress`。
4. 最後一題 `completeSession` 失敗後重啟：保留答案與 feedback，可重試完成，不顯示假 Result。
5. 相同 stable learning context + mode 已有 `in_progress` session：重啟、重複呼叫、race 或反覆導航均回傳同一 active session，無 duplicate。
6. 同一 context + mode 只有歷史 `completed` session：再次開始可建立新的 session。
7. 舊 session 進行中 current ContentVersion 更新：恢復原 ContentVersion、有序 Question revisions 與 progress，不換題，也不因新版而另開 session。

新的 learner-facing interaction family 須核對 §6.1 的正式 05 handoff、狀態、
responsive、accessibility 與實作 fidelity；production visual integration 須核對
§6.2 的 Content、visual need、placement / container / aspect ratio、responsive、
alt 約束，以及 Developer Visual Review 後的獨立 integration authorization。

Phase 1 Kana integration 須在離線狀態驗證 Hiragana / Katakana 的聽音→鍵盤、
聽音→手寫、視覺提示→鍵盤、視覺提示→手寫流程；手寫僅於 Submit 後辨識，
可清除／重寫，成功時顯示 candidate 與正誤，失敗或不可用時顯示明確狀態
並保留鍵盤作答。日語 TTS 不可用時仍能完成視覺提示流程；無 touch / stylus
的裝置不阻斷鍵盤流程。逐題回饋、可關閉音效、離線詳解、重試與手動下一題
依 `DEC-P1-003` 驗證；Widget 不直接呼叫辨識 SDK／平台 API。需要 schema
變更時包含舊資料保留與 upgrade test；相關 Unit / Widget / Integration Test
及適用裝置／平台檢查須記錄實際 evidence。

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

### 24.1 CR-0005 Target Ownership 驗證

對適用的 Domain / Use Case、資料來源及 learner-facing level interaction，驗證
§15.2.2 的 ownership 與 access semantics；不因以下測試方向自行導入尚未核准
的 StudyGoal persistence、UI design、schema、migration 或 Reset 行為：

- primary learning / exam-preparation target 的 authoritative owner 是
  `StudyGoal.targetLevel`；`AppSetting`、`UserProfile` 及 contextual / historical
  records 不可作替代 authoritative source。
- selected / viewed / navigation level 與 primary target 分離；瀏覽、學習或導航
  到其他 JLPT level 不隱性修改 primary target。
- 不同 primary target 的 learner 均可存取所有目前已有 available content 的
  JLPT level；target 不作為 unlock 或 content availability state。
- 無 active StudyGoal 時，primary target 為尚未設定，available content 仍可用；
  不從 navigation 或 historical record 猜測 target。
- `AssessmentSession.targetLevel`、`ReadinessSnapshot.targetLevel`、
  `StudyPlan.targetLevel` 各自表達 record 的適用級別，不覆蓋 learner current
  primary target，既有 Assessment / Readiness / Study Plan 責任仍成立。

適用的 Unit / Widget / Integration evidence 依實際授權的交付範圍記錄；
A2-P1 / A2-R1 未決項目不能被寫成已實作或已驗證。這些方向不新增 Phase 1
StudyGoal table、重啟持久化或 Reset gate；不改既有 §24 與 §38 階段驗證要求。

### 24.2 CR-0006 Content Availability 驗證

對適用的 Content / Domain 與 learner flow，驗證 §8.5 的 semantic contract：

- authoritative scope 為 JLPT Level × Content Family；level-wide 狀態只作 derived
  summary，不作獨立 authoritative state；Locked / Unlocked 不屬 availability。
- 四個核心狀態符合 §8.5.1：Available 足以支援目前正式 learner flow；Partial
  有 usable published content 且仍可存取；無 usable content 時，依正式
  learner-facing future intent 區分 ComingSoon 與 Unavailable。
- Level summary 覆蓋「all Available」、「有 Available / Partial 且非 all
  Available」、「無 usable family 且有 ComingSoon」、「其餘 Unavailable」的
  優先序；混合 usable family 與 ComingSoon 時仍為 Partial。至少一個 family
  Available / Partial 即有 learner-usable content，不宣稱所有 family 完整。
- 不同 targetLevel、無 active StudyGoal、progress / mastery、prior-level 或
  Kana completion 不改變 availability；Available / Partial 的內容仍可存取。
- draft / reviewed / withdrawn 不因 availability 被當成目前正常 learner flow
  的 usable published content；published 不自動代表 family Available。
  ContentVersion、immutable revision、provenance 及既有 session revision 綁定不變。
- Audio / recognizer / device / network / provider / local download capability
  的 unavailable 不改寫 product availability；既有 Local-first / offline fallback
  保持成立。Development rollout 不被實作為 learner sequential unlock。

本節為 semantic testing / acceptance 方向，不代表本次已執行或通過 runtime
tests；適用 Unit / Widget / Integration evidence 依正式授權範圍記錄。A3-D1～D4
仍 OPEN，不據此自行決定 family 清單、coverage threshold、ComingSoon UI / ETA、
storage representation、schema、migration、Cloud 或 Content Update protocol。
不新增 Phase gate，不以這些方向提前授權 A5 / Level Selector implementation。

### 24.3 CR-0007 Kana Foundation 驗證

對適用的 Content / Domain、entry 與 learner interaction，驗證 §1.1 的契約：

- Kana Foundation 為 shared foundational area，不是 JLPT Level、synthetic N0
  或 N5-owned learning area；Phase 1 與 N5 的交付關係不作 semantic ownership。
- independently discoverable entry 不能僅透過 N5；learner 可 skip 並隨時 revisit。
  對 Available / Partial JLPT content，未完成或沒有 Kana progress 不構成 gate。
- JLPT experience 的 Kana recommendation / deep-link 只能 advisory，不要求先
  完成 Kana；Kana activity 不隱性修改 primary `StudyGoal.targetLevel`。
- Kana progress 不被當成 availability / unlock / target state；無 progress 不推定
  learner 不會 Kana，也不以此決定 content access。
- Foundation Core content scope 覆蓋 §1.1.2 的七項範圍與 `ん / ン`、`っ / ッ`、
  Katakana `ー` 及初級 Hiragana 長母音概念；coverage 不等於 learner completion。
- non-core 項目不被暗中加入 Foundation Core 必須內容或已核准的 Extended
  curriculum placement；A3-D1 未因 Kana Foundation 而被選定。
- 既有 CR-0002 的四種練習流程、expected Kana、Submit 後辨識、正規化／候選、
  Retry、可關閉音效、stored explanation、manual Continue 與 offline failure /
  keyboard fallback，仍依原 Spec 及 `DEC-P1-001 / 003 / 005` 驗證。

這些是適用的 testing / acceptance 方向，不代表本次已執行 runtime tests；既有
§24 Kana 測試與 §42.3 regression 不降低。A4-D1～D4 尚未決定前，不自行固定
entry UI、curriculum sequence、completion / progress / mastery threshold、
recommendation / onboarding 或 persistence。本節不建立 schema / migration、
access gate、新 Phase scope 或 production implementation authorization。

### 24.4 CR-0008 Reference Index 驗證

對適用 Content / Domain、reference entry 與 learner flow，驗證 §1.2 的契約：

- Vocabulary Index 與 Grammar Index 為 distinct indexes，各有獨立可發現 entry；
  未進入或未完成 Lesson 仍可 browse 並存取可用 detail。
- 兩個 Index 均具 N5～N1 level 組織／篩選能力；不同 primary target 或無 active
  StudyGoal 不阻止 browse，且瀏覽不修改 target、不建立 sequential unlock。
- capability 不誤報 N4～N1 已有 production content；Available / Partial 存取仍
  符合 §8.5，不新增 Reference availability / unlock state，不由 index 名稱解決 A3-D1。
- browse / detail 使用原 canonical Vocabulary / Grammar identity 與 revisions；
  無平行 Reference content source，effective published / withdrawn 選取與
  immutable history、ContentVersion、provenance / publication eligibility 保持一致。
- Grammar learning destinations 覆蓋 zero、one、multiple 三種語意；不假設每個
  GrammarId 恰好對應一個 LessonId，也不虛構 destination 或繞過 publication。
- browse / detail view 不自動完成 Lesson、不產生 mastery 或 Assessment evidence；
  不暗中導入 known / mastered、view tracking 或 Reference progress policy。
- 本地正式內容的核心 browse / detail 可 offline 使用，不新增 Cloud / AI runtime
  dependency；runtime capability 與 product availability 保持分離。
- Reference learner-facing content 的新建／實質修訂仍遵守 03 → 06 → Developer，
  不以 Index presentation、來源 approval 或 06 PASS 取代 Content Release approval。

上述為適用 Unit / Widget / Integration testing / acceptance 方向，不表示本次
已執行 runtime tests。A3／A4 與 A5 仍未決項目不得由測試 fixture 暗中選定；
Search core 驗證另依 §24.8；不固定 UI placement、Browse / Sort 或具體 Search
interaction / presentation、mandatory detail fields、relationship schema、
progress persistence 或新 migration，不擴張 Phase 1 production content 或 gate。

### 24.5 CR-0009 Learning IA / Canonical Curriculum 驗證

對適用的 Content / Domain 與 learner flow，驗證 §1.3、§8.6 的 semantic contract：

- Learning 區分 Foundation、JLPT Courses、Vocabulary、Grammar；目前 Foundation
  area 僅為 Kana Foundation，仍與 N5～N1 分離，不暗中新增 Foundation curriculum。
- N5～N1 均為 discoverable destinations，未有 production content 不被誤報 ready；
  不建立 sequential unlock，Available / Partial access 仍依 A3。
- Level / Course / Reference navigation 不修改 `StudyGoal.targetLevel`；
  primary target 只有 explicit learner target-change action 可改，ownership 仍依 A2。
- 每 Level 有 Course Area、Canonical Vocabulary / Grammar Curriculum；Reference /
  focused Practice 使用 canonical curriculum 作 content basis，coverage authority
  不由 Lesson union 取代，Course / Lessons 僅作 pedagogical organization。
- Lesson-scoped Vocabulary / Grammar 沿用 canonical identity / revision，沒有平行
  Lesson-only source；zero Lesson mappings 的 canonical item 可供 Reference 及
  applicable focused Practice 使用，不虛構 dedicated Lesson ownership。
- 三個 Practice contexts 可區分且 infrastructure 可共用；既有 singleChoice
  Submit / durable feedback / Continue / resume / completion、Kana 與 Mock Exam
  分界均保持，不由 context 區分新增 selection / scoring 或 mastery policy。
- Curriculum / Content 維持 03 Author QA → 06 Independent QA → Developer final
  approval；published / withdrawn、immutable history、provenance 不被繞過。

上述為 testing / acceptance 方向，本次不代表已執行 runtime tests。A1-D1～D6 與
A2～A5 未決項目不得由 test fixture 代決；不固定 UI、實際 inventories、
classification、coverage count、lesson sequence / completion、Practice 題型／題數，
不新增 schema / migration，也不擴張 Phase scope / gate。

### 24.6 CR-0010 Assessment / History / Adaptive Weakness 驗證

對適用的 Domain / learner flow，驗證 §1.4、§13–16 的 semantic contract：

- Assessment 為獨立 Global Product destination，具有 N5～N1 destinations；可發現
  不等於各 mode / level 可用，不 sequential unlock，不改 primary StudyGoal target。
- Diagnostic baseline、Benchmark reproducibility、Mock pre-submit suppression、
  confirmed submission 與 validity 保持；adaptive review 不改 fixed assessment。
- Learning / Assessment 皆形成 evidence，但不同 source 不被默認等價；原始歷史、
  current Mastery、WeakPoint 及 Review Priority 可區分，保留 context / validity。
- WrongQuestion 不等於 concept-level WeakPoint；remediation 不強迫永遠同題，
  也不因 WeakPoint resolved 自動刪錯題或更改其未決 lifecycle。
- active / improving / resolved / reopen semantic 成立；single correct answer
  不自動 resolution，resolved 預設退出 active weakness queue、保留歷史，
  新 negative evidence 可 reopen，不永久排除 review。
- Adaptive Review 優先 weak / improving / low-confidence concepts；high mastery
  降低重複優先度但非永久排除，不由 fixture 硬編碼 counts / weights / intervals。
- Learner-facing Learning History 是 projection / view；後續 current state 不改寫
  historical evidence、AssessmentResult、ReadinessSnapshot，不新增單一 history table。
- Assessment Content 保持 03 → 06 → Developer、immutable published revision /
  provenance；JLPT 公開資料是 Reference Source，不作 Copy Source。
- 既有 §7.3.1 durable answer / resume / completion、Practice / Review feedback、
  KnowledgeConcept / QuestionConceptMap、A1～A5、§17 Reset 與 Phase gates 保持。

上述是 testing / acceptance 方向，不代表本次已執行 runtime tests。
A6-D1～D7 及既有 Mastery / WeakPoint / Readiness / confidence / question-set /
validity / presentation / scheduling policies 不由此代決；不設計 UI、threshold、
spaced repetition、schema / migration，也不授權任何 Phase start。

### 24.7 CR-0011 Context-Aware AI Tutor 驗證

Phase 2 適用 Unit / Widget / Gateway / Integration tests 覆蓋 §9.3、§10.1、
§14.1 / §14.6、§18.2、§34 與 §29.3：

- Lesson 主要 contextual entry，以及 LessonSection、Vocabulary、Grammar、
  ExampleSentence 與 Practice / Review post-feedback contexts；learner 不必重複
  複製教材，不生成 global/contextless AI destination 或改 final Global IA。
- Context 帶 canonical identity、精確 revision / release；deterministic assembly
  不只傳 screen text，不把 supplemental knowledge 當 canonical Content。
- CONTENT_GROUNDED、CONTENT_PLUS_SUPPLEMENTAL_KNOWLEDGE、
  INSUFFICIENT_CONTEXT 可區分；structured response 可 schema validate，含
  answer、examples、適用 concepts / references、basis、limitation；不猜不足資料，
  invalid response 不被當成有效回答，runtime UNAVAILABLE 與不足 context 分離。
- Current Session multi-turn 綁啟動 context / revision；跨教材 navigation 不靜默
  rebind，實質 context 變更建立新 context / session；V1 無 persistent conversation /
  message history、history UI、Cloud 或 cross-device chat sync。
- zh-TW explanation / Japanese examples；canonical validated ReadingSegment 政策
  保留，即時 AI 新日文不自動套 ruby / Furigana，文字讀音不寫成 canonical metadata。
- Valid Submit、durable QuizAnswer、完整 feedback 與 stored explanation 前不提供
  Practice / Review Tutor 揭答入口；之後可追問但不改 submitted answer、scoring、
  Result、Continue / completion / resume，也不替代 offline curated explanation。
- Active Diagnostic / Benchmark / Mock 預設禁用 Tutor，無有效性破壞；post-result /
  Review permission 依正式 policy，未決政策不以測試 fixture 自行批准。
- Tutor conversation 不自動更新 LearningProgress、WrongQuestion、Mastery、
  WeakPoint、Readiness 或 AssessmentResult；canonical revision、answer、
  explanation 與 historical evidence / results 不被改寫。
- UI → ViewModel → Use Case → AI abstraction → HTTPS Gateway → AI Application
  Use Case → Prompt / Context Builder → Provider Adapter；client 無永久 Provider
  secret，也不直接呼叫 Provider。
- 僅送目前問題必要 context，不預設完整 Learning History、WrongQuestion、
  Assessment history、WeakPoint、無關歷史或個人資料；log / metadata / retention
  依正式 policy，不假定可永久保存完整 prompt / response。
- Offline、gateway unavailable、timeout、rate limited、provider unavailable、
  invalid response、insufficient context 不破壞 canonical learning state；
  Lesson / Vocabulary / Grammar / Furigana / Practice / stored explanation
  及 Phase 1 + Slice A 離線核心回歸可運作。
- V1 不引入 voice / image Q&A、persistent / Cloud Tutor history、conversation
  grading、AI 自動 publication / Product change 或強制 Vector DB / full RAG。

以上是適用 Phase 的測試／驗收要求，不代表本次已執行 implementation tests。
精確 API、timeout / retry、必要 privacy policy 與 Assessment post-result Tutor
permission 依 §38.11；不由驗證需求推定 production authorization 或 Phase start。

### 24.8 CR-0012 Local Canonical Search 驗證

對適用 Domain / Use Case、Repository、Presentation 與 learner flow，驗證
§1.2.5–1.2.10、§29 / §38.5 的契約：

- Single query 搜尋 Vocabulary + Grammar，不要求先選 Content Type；V1 不暗中
  擴張為 Kanji、Kana、Lesson / ExampleSentence full-text、Question / Assessment、
  WrongQuestion 或 Learning History 搜尋。
- Vocabulary written form、canonical reading、learner-facing meaning 及 Grammar
  expression / formally available meaning / title 的 exact match，以及 prefix、
  contains、deterministic normalization，均符合正式核准的 comparison semantics；
  canonical text / revision 不因 normalization 改寫，未決 algorithm 不由 fixture 代決。
- 預設跨 N5～N1，Level 為 metadata / optional filter；不同 target / viewed level、
  prior-level / Kana completion、progress / mastery 不限制查詢或存取，不修改 target；
  不把跨級能力或單筆 result 誤報為所有級別或 family production-ready / Available。
- Ranking 五類順序與同 class stable tie-breaker 可重現，不採 target / mastery /
  personalized / recent / popularity / AI ranking。
- 只選 effective published revision；draft、reviewed but unpublished、withdrawn
  current result 被排除。Result / canonical detail 可追溯原 logical identity、
  immutable revision、ContentVersion；不新增平行 content source、不改歷史引用。
- Result 的五項 minimum information 與 canonical detail navigation 成立；
  preview 不新增 mandatory Content fields，不繞過 A5-D3 或 publication。
- No result 僅表示目前 query / 條件沒有 formal canonical match，不誤導為日文
  不存在、非 JLPT、超過 N1 或無 future content。
- 無 network / Cloud / Backend / AI Gateway 時核心 Search 仍可 offline 使用；
  UI 不直接操作 DB，分層責任成立，不由測試要求特定 engine / index / schema。
- Query / result / detail navigation 不自動建立 QuizAnswer、Assessment evidence、
  Lesson completion、LearningProgress / Mastery update、WrongQuestion 或 Readiness；
  不暗中新增 Search History / personalization、retention 或 Reset policy。
- Exact UI placement / interaction 依適用 formal 05 handoff，不由 core semantic
  固定；§10.1 contextual Tutor 不被擴張為 Global AI Chat / retrieval。
- Search 於 Phase 2 early offline enabling slice 驗收，不能作新增 Phase 1 closure
  prerequisite；future AI-assisted Retrieval 維持 DRAFT / NOT PART OF CR-0012 /
  NOT AUTHORIZED，不以 sequencing 作為 implementation approval。

上述是未來適用 Unit / Widget / Integration testing / acceptance responsibility，
不是本次執行結果。若後續正式 schema 變更獲准，另依 §42.1 驗證保留資料、
versioned migration 與 upgrade；本節不新增 schema / migration 或提前授權 Phase start。

### 24.9 CR-0013 Settings entry / Global Furigana 驗證

對適用的 preference Use Case / Repository、ViewModel / Presentation 與
Lesson / Practice consumers，驗證 §6、§7.4.1 及 §14.1：

- SR-D01：Phase 1 沿用既有 Shell「設定」目的地提供可發現入口；沒有因本
  bounded placement 新增 destination、重組 Global IA 或改 target / Course /
  Level navigation。A1-D1～D4 保持 OPEN，§6.1 family handoff gate 仍適用。
- SR-D02：Settings 與 Lesson 讀寫同一個 AppSetting.showFurigana；Lesson
  toggle 更新全域值，不產生 per-page override。保存成功後，所有適用的
  已掛載 Lesson / Practice inherit consumers 反映最新 confirmed value；
  尚未確認保存成功時不宣稱已持久化。重啟沿用 persisted preference。
- SR-D03 / 有 confirmed value：read failure 暫時保留本次執行期間最後確認值，
  有設定狀態無法更新提示與可理解 retry；失敗不覆寫 confirmed state，
  不冒稱 persisted value 已重新驗證。
- SR-D03 / 冷啟動無 confirmed value：一般 inherit 教學文字暫為 surface-only，
  顯示 read error / retry，Lesson / Practice 仍可閱讀；不當成使用者 OFF，
  不寫 false、不建立 persisted fallback 或跨重啟 last-confirmed cache。
- Recovery：成功重新讀取 authoritative persisted value 後，恢復正式偏好、
  更新適用 consumers，清除已不適用的錯誤提示。
- Policy isolation：inherit / show / hide 依正式 policy；explicit show 不被一般
  fallback 蓋過，explicit hide 不洩漏 reading；Mock Exam 不因全域偏好或
  failure fallback 增加正式題組未定義的 reading aid。
- 正常首次初始化 default ON 不變；初次使用、singleton row missing、
  read failure、使用者選擇 OFF 不混同。ReadingText / ReadingSegment、
  ContentVersion / alignment / release 不變，既有 renderer contract 保留。
- §17 與 DEC-P1-002 的 Reset Learning Data 保留 AppSetting、Factory Reset
  恢復預設不變；A2-R1 仍 OPEN，不以本 CR 決定 Reset execution 或 Content
  deletion option。Audio / Feedback Sound、durable Practice / resume / Result
  與既有 acceptance requirements 不因本次 preference 契約而改變。

上述為適用 Unit / Widget / Integration 驗證責任，不代表本次已執行 runtime
tests。不得以 fixture 選定未核准的 API、coordinator、subscription、DB / migration
或 SR-D04～08；production implementation 與 Phase start 仍須另行正式授權。

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
- Practice / Review `singleChoice` 逐題 durable answer、固定 revision 題目快照、
  依 stable context + mode 的單一 active session 與 durable presentation progress
  重啟恢復、正式 session completion 與可重建 Final Result（§7.3.1）
- Shared Kana Foundation（core scope 依 §1.1.2）的 Hiragana / Katakana Learning 與 Keyboard Practice；在支援裝置上提供
  touch / stylus 手寫 Canvas、離線辨識抽象及鍵盤 fallback
- Kana 聽音或視覺提示後，以鍵盤或手寫作答；明確 Submit、清除／重寫、
  逐題回饋、重試與手動 Continue，音訊或辨識不可用不阻斷核心學習

不做：

- 登入
- 雲端同步
- PostgreSQL
- 複雜 AI 個人化
- AI Speaking Evaluation
- 正式筆順、筆畫角度、書法美觀、速度或 AI handwriting quality score
- Cloud handwriting recognition / sample upload、Mock Exam handwriting mode

但是資料模型要預留未來 AI / Speaking / Cloud 所需欄位與 migration 策略。
Phase 1 的教材、reading、詳解與離線測驗不依賴遠端 AI / TTS；音訊 unavailable
時仍可完成 Lesson 與 Quiz。Furigana／音訊的具體 implementation parameter
依 §38.11 在適用開發前決定，不得因此擴張為 N1～N5 全部教材或 Mock Exam。
Kana 辨識 provider / library / model、平台 adapter 與 dependency 在導入前須有
Decision Record；Phase 1 不得用 Cloud / AI API 作為核心手寫練習依賴。
第一個 B0 `singleChoice` Practice core loop 可依 §7.3.1 分段交付，但
`WrongQuestion`、`LearningProgress`、`ReviewItem` 及本節其他項目仍須在完整
Phase 1 gate 前完成；任何 B0 core loop 完成不等於 Phase 1 COMPLETE。

本節 N5 是開發／內容 rollout 範圍，不是 learner 按 N5→N4→N3→N2→N1
依序解鎖的政策。Learner level access 與 primary target 分離依 §15.2.2。
CR-0005 不因 ownership 確立而要求 Phase 1 現在建立／persist StudyGoal；A2-P1
與 A2-R1 仍依 §38.11 待決，不改本節功能範圍或 §38.3 gate。

CR-0006 的 Content Availability 依 §8.5；N5 core rollout 不構成 learner unlock，
也不以 Kana completion 作為 level access 前置條件。本 CR 不要求 Phase 1
完成 N1～N5 全部 family，不決定 availability schema / migration，不改 Phase
順序、功能範圍或 gate；A3-D1～D4 保持 OPEN（§38.11）。

本節與 N5 一起交付的 Kana Foundation 是 §1.1 的 Shared Foundational Learning
Area，不由 N5 semantic ownership 管理；N5 rollout 標籤不代表 Kana 是 JLPT Level。
Foundation Core 是內容 scope，不是 learner completion gate；skip / revisit 與
Available / Partial JLPT content 存取保持獨立。A4-D1～D4 OPEN，不因此新增
entry placement、completion threshold、progress schema 或 migration，既有
Phase scope / order / gate 不變。

本節既有單字／文法的 reference access 依 §1.2：Vocabulary Index 與 Grammar
Index 不依賴 Lesson entry / completion，browse 不修改 primary target。N5～N1
level 組織／篩選是跨級別 capability，不要求 Phase 1 生產 N4～N1 content；
Reference 仍用 canonical published content、A3 availability 與離線資料。
A5-D1 / D3 / D4 / D5 保持 OPEN；A5-D2 Search core 由 CR-0012 精確化，
Browse / Sort 與具體 Search interaction / presentation 仍 OPEN（§38.11）。
本節不指定最終 UI、detail contract、relationship / progress representation、
schema 或 migration；Search placement 在 Phase 2，不加入本 Phase 1 scope / gate。

CR-0009 的 Learning / Level / Course / Canonical Curriculum 與 Practice context
semantics 依 §1.3；N5 仍為 Phase 1 production content 範圍。N5～N1 discoverable
destinations 與 per-Level curriculum capability 不代表 N4～N1 production-ready，
不要求 Phase 1 一次完成各級 content。Actual curriculum / UI / Practice policies
依 §8.6 與 §38.11，不新增 Phase、改變 order、scope 或 §38.3 完成閘門。

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
Slice A regression 亦涵蓋 Phase 1 Kana keyboard / handwriting Practice、
音訊及 recognizer 降級、原始作答與 migration；不擴張 Assessment Engine。

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

CR-0010 的 historical evidence / current state、concept-level weakness 與 history
projection boundary 依 §13–16；本階段仍僅依既有 scope 建立基礎模型與最小框架。
A6 不新增 table / migration、完整 adaptive policy 或提前授權 Phase 1.5 start；
既有 §38.4 gate 不變。

## 29. Phase 2 — Local Canonical Search + AI Gateway + AI 題庫

本階段先完成 Local Canonical Search 的 early offline enabling slice（§1.2.5–1.2.10）。
Phase 2 內 semantic sequencing 為：

```text
Local Canonical Search
→ AI Gateway / applicable AI capability
→ Context-Aware AI Tutor
→ future AI-assisted Retrieval
```

最後一項仍是 DRAFT / NOT PART OF CR-0012 / NOT AUTHORIZED；列出相對先後
不授權其 implementation，也不擴張 CR-0011 Tutor。Search 必須在任何
AI-assisted Retrieval implementation 前完成；核心 Search 不依賴後面的 AI /
Gateway / Cloud / network。Phase 1 → 1.5 → 2 不變，不新增 Phase 1.x。

### 29.1 技術

```text
Flutter
SQLite
ASP.NET Core AI Gateway
OpenAI Provider
```

### 29.2 功能

```text
Local Canonical Search（Vocabulary / Grammar，offline enabling slice）
AI Question Generator
AI Explanation
Context-Aware AI Tutor Q&A（§10.1）
AI Example Generator
Question Validator
Question Cache
Question Versioning
Usage Limits
```

Early offline enabling slice：single query → local published Vocabulary / Grammar
results → canonical detail；依 §24.8 驗證 matching / ranking、cross-level access、
publication / availability 分界、no-result 與 no learner-state mutation，Gateway /
network 關閉時仍可完成。Search 驗收不取代下列既有 AI Slice B 或 Tutor 驗收。

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

Slice B 另涵蓋 contextual Tutor：canonical learning context → text question →
Gateway / structured response → grounded / supplemental / insufficient-context
explanation → current ephemeral Session follow-up；Practice / Review 則由完整
durable post-feedback 與 stored explanation 後進入（§10.1.5）。
驗證 context / revision binding、language / reading boundary、無 evidence mutation、
資料最小化及 §10.1.7 failure states；不新增 chat history schema、Cloud 或 global
AI destination。Tutor 關閉／失敗仍回歸 Phase 1 + Slice A 離線核心；正式驗收依
§24.7、§38.5，不因本 Spec promotion 而授權 Phase 2 start。

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

CR-0010 的 Assessment destination / context 與 historical result boundary 依
§1.4、§14.5、§15.2；actual mode availability / rollout 由 A6-D2 決定，不由
N5～N1 discoverability 宣稱全級 production-ready。A6 不提前啟動 Phase 2.5，
不改本階段 fixed Benchmark / Mock validity、既有 scope 或 §38.6 gate。

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

本階段的 adaptive weakness / review 與 learner-facing History 遵守 §13.2–13.6、
§16.1 的 evidence / current state / resolution boundary；A6-D3～D7 與既有
MasteryPolicy、WeakPointPolicy、ReadinessPolicy、Data Confidence、Study Plan
scheduling 須於適用實作前決定。A6 不固定 spaced repetition / interval /
weighting，也不改 Phase order、scope 或 §38.8 gate。

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
完整手寫 strokes / points（未經核准不得持久化或記錄）
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

CR-0011 Tutor 僅傳回答當前 learner 問題所需的最小 canonical context 與
current-session 必要問答資料。V1 不預設傳送完整 Learning History、全部
WrongQuestion、完整 Assessment history / WeakPoint state、無關 learner history
或個人資料；擴大 personalization context 須另行 Decision。

Current Tutor Session 採 ephemeral（§10.1.3），V1 不要求永久 server-side
application conversation history。Gateway 可依正式 policy 保存必要 operational
metadata，例如 model/version、token / usage、cost、latency、error status、
request classification；此權限不等於可永久保存完整 learner prompt / response。
不得因一般 AI cache / usage logging 而推定 Tutor 原文永久留存獲准。
實際 provider retention、debug logging、privacy policy 若需額外正式決策，
於 Phase 2 Architecture / Privacy Review 處理（§38.11）；本 CR 不設定留存時長、
保證 provider zero retention 或建立新的 account / Cloud deletion contract。

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
Phase 1 — Core Offline Learning（含 Hiragana / Katakana Practice）
Phase 1.5 — Vertical Slice A + Knowledge / Assessment 基礎資料模型
Phase 2 — Local Canonical Search + AI Gateway + AI 題庫（Vertical Slice B）
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

完成閘門：離線完成課程、測驗、結果、錯題、進度及 Review；重啟後資料仍在；Reset scope 不誤刪 Content Data。N5 教學 reading / Furigana 預設 ON、關閉與持久化可驗證；context-sensitive 發音能力、Audio unavailable fallback、Practice / Review 逐題正誤／可關閉音效／答案／離線詳解可驗證；Reset Learning Data 不誤改設定。Hiragana / Katakana 的鍵盤及支援裝置上的手寫四種提示／輸入流程可離線完成；Submit 後辨識、正誤、重試、手動 Continue、音訊／辨識／觸控不可用時的鍵盤及視覺提示 fallback 均可驗證；不含進階筆順／品質評分。適用 Unit / Widget / Integration Tests、`dart format`、`flutter analyze` 通過；需要 schema 變更時升級測試通過。

其中 Phase 1 `singleChoice` Practice / Review 的題目快照、逐題 durable answer、
同 context + mode 單一 active session、Continue 前後及最後一題的 durable
progress 恢復、提交與完成冪等、明確「查看本次結果」及可重建 Final Result 依
§7.3.1、§14.1、§24 驗證；新 migration 須驗證舊資料升級及 Content Data 保留。
這不降低前段錯題、進度、Review、Kana 等完整 Phase 1 gate。新的 learner-facing
family 與 production visual 須依 §6.1–6.2 確認適用的正式 handoff 與獨立授權。

本節既有 Furigana / Settings 驗收，依 CR-0013 的 §7.4.1 / §24.9 檢查全域
confirmed preference propagation、read failure / retry / recovery 及 reading policy
isolation；Settings bounded entry 依 §6。這是已核准語意的驗證範圍精確化，
不新增獨立 Phase gate、不更改 Phase completion definition，§6.1 仍適用。

### 38.4 Phase 1.5 — Vertical Slice A 與基礎模型

完成第 28 節 Slice A，建立 `KnowledgeConcept`、`QuestionConceptMap`、`LearnerKnowledgeMastery`、`AssessmentSession`、`AssessmentAnswer`、`AssessmentResult` 與 `ReadinessSnapshot` 的必要 schema。此階段不要求完整 Assessment UI 或 Readiness 結論。

完成閘門：Slice A 可從啟動跑到 Reset；正式題目有主要 KnowledgeConcept mapping；migration 可升級 Phase 1 資料；原始作答可重建 Derived Analytics；reading metadata、Furigana ON / OFF、設定持久化、Audio 獨立、逐題回饋／詳解及 Reset 設定範圍納入資料庫與 Slice A 回歸；Kana keyboard / handwriting、音訊與 recognizer 降級及資料升級亦納入 Phase 1 回歸，不提前擴張 Assessment Engine。

### 38.5 Phase 2 — Local Canonical Search、AI Gateway 與題庫

先完成 §29 的 Local Canonical Search early offline enabling slice，semantic
sequencing 依 §29；在任何 AI-assisted Retrieval implementation 前完成 Search。
其完成閘門依 §24.8：single query 跨級 Vocabulary / Grammar、deterministic
matching / ranking、published-only canonical results / detail、no-result、offline
operation、target / learner evidence 不變均可驗證，適用 Unit / Widget /
Integration evidence 完成；UI implementation 前仍核對 §6.1 formal handoff。
此 Search gate 僅適用 Phase 2，不追溯加入 Phase 1 / Phase 1.5 gate。
不固定 engine / schema / UI placement，亦不降低下列既有 AI / Tutor 完成閘門。
AI-assisted Retrieval 仍 DRAFT / NOT PART OF CR-0012 / NOT AUTHORIZED。

完成第 29 節 Gateway、AI 題目/解釋、Validator、Cache、Versioning 與 Slice B。

完成閘門：Provider Secret 不在 App；題目通過 JSON Schema、規則、答案一致性與去重後才可使用；Gateway 不可用時 Phase 1 / Slice A 的 reading、Lesson 與 curated explanation 仍可離線運作；動態 AI 題不能充當固定 Assessment 題組；後端與 Flutter 相關建置/測試通過。

同階段依 §10.1、§24.7 與 §29.3 完成 Context-Aware AI Tutor Q&A V1：
contextual entries 與 post-feedback eligibility、revision-bound ephemeral multi-turn、
canonical-first / explicit answer basis、zh-TW / Japanese 與 canonical reading
分界、Gateway structured response、failure isolation 與 data minimization。
Tutor 不寫入 learner / Assessment evidence，不改教材、答案、結果；active
Assessment 預設禁用，post-result permission 不由本階段自動批准。
適用 architecture / privacy 決策完成後驗收；不需 persistent Tutor history、
Vector DB、Cloud、voice / image Q&A。Phase 1 → 1.5 → 2 的順序不變，
本 Spec promotion 不授權 Phase 2 implementation。

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

§6.1 的 UI/UX handoff 不阻止與待定 learner-facing UI 行為獨立的 migration、
Domain、Repository、Use Case、Service abstraction 與非 UI tests；進入新
interaction family 的 production ViewModel interaction / Widget / Navigation / focus /
responsive / accessibility 前，須核對正式 contract 及適用的 Developer-approved
05 handoff。§6.2 的 04 探索或 Visual approval 不自動授權 Codex 整合 production
asset；取得獨立 integration authorization 後才進行適用範圍的整合。
實作 §7.3.1 的 resume 時，context identity、active-session uniqueness 與
presentation progress 均須符合其 durable semantic；不得以 current
ContentVersion 作 resume key，或只以答案存在推斷 Continue 已發生。

每個 Slice 使用可 review 的分支/commit 群組。Schema 變更必須同一交付包含 migration 與資料庫測試。Commit 類型使用 `feat:`、`fix:`、`refactor:`、`test:`、`docs:`、`chore:`。

### 38.11 待決策登錄表

下列項目含 V2.2 未具體定義的參數與 CR-0001、CR-0002 新增需求的未決參數，
以及 CR-0005 的 A2-P1 / A2-R1、CR-0006 的 A3-D1～D4 與 CR-0007 的
A4-D1～D4、CR-0008 的 A5-D1～D5、CR-0009 的 A1-D1～D6，以及
CR-0010 的 A6-D1～D7 Open Decisions，以及 CR-0011 的適用架構／政策未決細節。
CR-0012 僅部分解決 A5-D2 的 Search core semantic，其餘未決範圍依下表保留。
開始相應功能前，以 Decision Record 記錄決策、理由、日期及適用的
policy/version；不得散落硬編碼。

| 項目 | 需決定的內容 | 最晚決策階段 |
|---|---|---|
| KnowledgeConcept identity | identity 格式沿用 CR-0002 已確認的 UUID v7 / TEXT；內容改版後是否沿用 concept ID 仍待決 | Phase 1.5 |
| QuestionConceptMap | 權重範圍、合計規則、主要概念限制 | Phase 1.5 |
| MasteryPolicy | 加權公式、最低證據量、狀態切換條件 | Phase 1.5/2.5 |
| Assessment 題組 | 各模式/級別題數、題型、抽題規則 | Phase 2.5 |
| Assessment validity | 超時、跳題、缺題、重複作答門檻 | Phase 2.5 |
| ReadinessPolicy | Section safety threshold、狀態切分、權重與版本遷移 | Phase 2.5 |
| Data Confidence | 各信心級別所需題數、覆蓋率、次數與時效 | Phase 2.5 |
| WeakPointPolicy | importance、recency、confidence 尺度與最低證據 | Phase 2.5 |
| Study Plan 排程 | 每日/每週量、考期接近時的調整與排序 | Phase 2.5/4 |
| A1-D1 — Exact Level Selector / Global Learning IA Presentation（OPEN） | §1.3 semantic frame 已核准；exact Level Selector / Global Learning IA presentation 未決，不關閉 A4-D1 / A5-D1 | 適用設計／實作前 |
| A1-D2 — Viewed / Selected Level State & Persistence（OPEN） | viewed / selected level state 與 persistence；不取代 StudyGoal target ownership，不選定 schema | 適用 state / persistence 實作前 |
| A1-D3 — Initial Landing / No-Target Experience（OPEN） | 初始 landing 與無 target experience；無 active StudyGoal 不阻止 available content access 已核准 | 適用 experience 設計／實作前 |
| A1-D4 — Level Recommendation / Continue-Learning Policy（OPEN） | level recommendation 與 continue-learning 政策；不以 recommendation 隱性改 target 或建立 access gate | 適用政策導入前 |
| A1-D5 — Course Curriculum / Lesson Sequence（OPEN） | 實際 curriculum、lesson sequence 與 pedagogical organization；canonical coverage authority 已核准，不由 02 決定 inventories、classification、counts、prerequisites 或 completion | 適用 Curriculum / Content 設計與交付前 |
| A1-D6 — Practice Collection / Question Selection Policy（OPEN） | 實際 Practice collection / question selection；三個 distinct contexts 已核准，不由本 CR 決定題型、題數、scoring 或 mastery effect | 適用 Practice policy 設計／實作前 |
| A2-P1 — StudyGoal Persistence Timing（OPEN / DEFERRED） | Phase 1 是否現在建立／persist StudyGoal、或僅先固定 architecture semantics；實際導入 Phase、SQLite table / schema、migration timing、persistence repository contract 與重啟持久化實作時點 | 實際導入時點待 Developer 決定；相關 persistence 實作前須解決，不由本 CR 指定 Phase |
| A2-R1 — Reset Semantics（OPEN / DEFERRED） | Reset Learning Data 是否保留 StudyGoal、Factory Reset 是否刪除、StudyGoal 的 reset scope 與 deletion / reset lifecycle | 相關 StudyGoal Reset / deletion 行為實作前；不由本 CR 選擇保留或刪除 |
| A3-D1 — Exact Content Family List（OPEN） | Content Family 的正式清單與 Level summary 的 relevant families；不由既有 Entity 名稱推定完整 taxonomy | 適用 family taxonomy / aggregation 實作前；實際 Phase 待 Developer 決定 |
| A3-D2 — Coverage Completion（OPEN） | Coverage completion / quantitative thresholds；不改 §8.5 已核准的 Available / Partial 語意 | 適用 coverage 判定實作前；實際 Phase 待 Developer 決定 |
| A3-D3 — ComingSoon Presentation（OPEN） | ComingSoon learner-facing presentation / ETA policy；不從 development rollout 自行推定呈現或 ETA | 適用 learner-facing 呈現前；實際 Phase 待 Developer 決定 |
| A3-D4 — Availability Representation（OPEN） | Persistence / schema / manifest / release metadata representation；不預建 DB table、persisted enum 或 migration | 適用 representation 實作前；實際 Phase 待 Developer 決定 |
| A4-D1 — Exact Entry Placement（OPEN） | Kana Foundation entry 的具體 placement；independently discoverable、不限 N5 entry 已核准，不由本 CR 設計 Home IA、Level Selector 或 Navigation component | 適用 entry placement 實作前；實際安排待 Developer 決定 |
| A4-D2 — Curriculum Sequence / Completion Semantics（OPEN） | teaching order、lesson grouping、completion definition、progress percentage、mastery threshold、repetition / correct-count requirement、Extended Kana curriculum placement；§1.1.2 Core scope 已核准，不等於 completion requirement | 適用 Curriculum / completion 政策導入前；不由本 CR 選定順序或門檻 |
| A4-D3 — Recommendation / Onboarding Policy（OPEN） | recommendation / onboarding 的實際政策；JLPT experiences 可 advisory 推薦／deep-link，不得作 gate | 適用 recommendation / onboarding 政策導入前 |
| A4-D4 — Progress Representation / Persistence（OPEN） | Kana Foundation progress 的 representation / persistence；progress 是 learner state，不由本 CR 建立 schema / table / migration | 適用 progress representation / persistence 實作前 |
| A5-D1 — Exact Entry / Reference IA（OPEN） | Vocabulary Index / Grammar Index 的具體 entry placement 與 Reference IA；獨立可發現、不需 Lesson entry / completion 已核准，不由本 CR 設計 Reference hub、Home IA、Level Selector 或 Navigation component | 適用 entry / IA 設計與實作前 |
| A5-D2 — Browse / Search / Sort Interaction（PARTIALLY RESOLVED） | CR-0012 的 Search core semantic 已核准（§1.2.5–1.2.10）：Vocabulary / Grammar single query、cross-level、deterministic matching / ranking、canonical results、offline 與 evidence boundary；Browse / Sort 與具體 Search interaction / presentation 仍 OPEN。不固定 UI control、exact normalization algorithm 或 stable tie-breaker implementation；normalization 若改變 learner-visible semantic 須 Product Review | 剩餘 interaction / presentation 於適用設計／實作前；影響 learner-visible semantic 的 normalization 於導入前 Review |
| A5-D3 — Detail Presentation Contract（OPEN） | Vocabulary / Grammar 最終 learner-facing detail field contract 與呈現；不由本 CR 決定 mandatory detail fields | 適用 detail contract 設計與實作前 |
| A5-D4 — Grammar → Learning Content Relationship Representation（OPEN） | zero / one / multiple applicable learning destinations 已核准；具體 relationship representation 未決，不指定 table / join 或 GrammarId → exactly one LessonId | 適用 relationship representation 實作前 |
| A5-D5 — Reference Viewing / Progress Semantics（OPEN） | browse / detail view 不自動等於 completion、mastery 或 Assessment evidence 已核准；其餘 viewing / progress 語意未決，不建立 known / mastered policy 或 Reference progress schema | 適用 viewing / progress 政策實作前 |
| A6-D1 — Assessment Hub Exact IA / Presentation（OPEN） | final Hub IA / UI、Bottom Navigation / Sidebar；independent destination 已核准，不固定 component / placement | 適用設計／實作前 |
| A6-D2 — Assessment Mode Availability / Rollout（OPEN） | Diagnostic / Benchmark / Mock 的實際 mode / level availability 與 rollout；N5～N1 discoverability 不代表題組 production-ready；Diagnostic 是否提供 repeat、repeat trigger、cooldown、frequency、repeat question-set reuse / refresh policy 仍為 downstream decision | 適用模式／級別交付前 |
| A6-D3 — WeakPoint Resolution / Reopen Policy（OPEN） | exact resolution / reopen thresholds、evidence counts 與判定規則；單次答對不足自動 resolution、resolved 退出 active queue 並可 reopen 已核准 | 適用 weakness policy 實作前 |
| A6-D4 — Adaptive Review / Suppression Policy（OPEN） | 實際 adaptive prioritization / suppression、spaced repetition algorithm、review interval；high mastery 降低優先度但非永久排除已核准 | 適用 review policy 實作前 |
| A6-D5 — Learning History Presentation（OPEN） | learner-facing history 的具體 presentation / timeline；projection / view 已核准，不要求單一 persistence table | 適用 history 設計／實作前 |
| A6-D6 — Cross-mode Evidence Weighting（OPEN） | evidence source 的實際 weighting；Learning / Assessment 皆形成 evidence，不同 source 不視為等價已核准 | 適用 evidence policy 實作前 |
| A6-D7 — WrongQuestion Learner-facing Lifecycle（OPEN） | WrongQuestion learner-facing lifecycle；不由 weakness resolved / reopen 決定 persistence lifecycle，不改既有 §17 Reset scope | 適用 lifecycle 政策實作前 |
| 官方 JLPT 資料 | 發布前核對日期、分區及門檻版本 | 發布前 |
| SDK / providers | SDK 版本與 AI / Speaking / STT 等 phase-specific provider、平台支援及成本限制；Phase 1 Learning Audio 依下一列 | SDK：Phase 0；其餘於對應 Phase 導入前 |
| Learning Audio delivery | Phase 1 已由 `DEC-P1-001` 決定 Local / OS Japanese TTS；Reference Audio、remote TTS、進階 cache、授權與成本等後續增強仍待決 | 後續增強於對應 Phase 前 |
| Furigana data / rendering | alignment 與句子 segmentation 格式、ruby rendering 細節；不改預設 ON | Phase 1 |
| Practice / Review feedback | Phase 1 由 `DEC-P1-003` 決定 packaged sounds、預設 ON、可關閉、手動下一題；其他階段增強與各題型 Reading Aid 政策仍待決 | 後續增強於對應 Phase 前 |
| Kana handwriting recognition follow-up（PARTIALLY RESOLVED） | `DEC-P1-005` 已決定 Android / iOS Google ML Kit Digital Ink Recognition（`ja`）與 dedicated Flutter integration、動態 model download／明確使用者操作／model availability states／下載後離線辨識、centralized normalization、Top 1 / Top 3 candidate 與 ambiguous recognition／learner confirmation、暫存 `Stroke → ordered StrokePoint[]`／處理後釋放／不永久保存／不上傳 Cloud／不用於 model training、不得以任意未校準 confidence threshold 作唯一 correctness rule／不持久化 confidence 或轉成 handwriting-quality score；仍未決僅限 Windows offline recognition provider / technical spike，以及未來 replacement provider / materially different adapter 決策 | 已決政策依 `DEC-P1-005`；Windows provider 或未來 replacement provider / materially different adapter 導入前須另作 Decision；無 approved Windows offline adapter 時 recognition = unavailable，Keyboard Practice 仍可用 |
| Kana answer policy follow-up（PARTIALLY RESOLVED） | centralized normalization 與 accepted Kana 邊界已由 `DEC-P1-005` 決定，不再列為待決；未轉換 Romaji 不視為有效 Kana answer；未來若要接受直接 Romaji-as-answer，仍須另行 Product Decision | 既有 Phase 1 比對依 `DEC-P1-005`；直接 Romaji-as-answer 擴充於適用版本前另作 Product Decision |
| Handwriting sample lifecycle | stroke data retention / telemetry 尚未核准；Phase 1 僅暫存處理並釋放；未來若需長期保存須另作 Privacy / Data Lifecycle Decision | 任一保存／傳輸功能導入前 |
| Advanced handwriting scoring | 筆順與書寫品質評分不屬 Phase 1；日後加入須另作 Product Decision | 日後適用 Phase 前 |
| Assessment Presentation Policy | Diagnostic / Benchmark 回饋時點與額外 Furigana；Mock Exam 已定義不得提前揭露 | Phase 2.5 |
| Mock Exam execution | 各級別題數、官方時限、section transition、未完成／timeout／resume 的精確 validity 規則與 rollout | Phase 2.5 導入對應模式／級別前 |
| AI Tutor architecture / runtime parameters | CR-0011 §10.1 的 exact API / structured response schema、timeout / retry 參數與 Provider 適配設計；沿用 Gateway responsibility，不改已核准 D1～D6 semantics | Phase 2 適用設計／實作前 |
| AI Tutor privacy / server-provider retention | 實際 provider retention、debug logging 與 privacy policy 若需額外正式決策，於 Architecture / Privacy Review 處理；不假定永久 prompt / response 留存權限或 provider zero retention | Phase 2 適用傳送／記錄功能前 |
| AI Tutor post-assessment permission | Diagnostic / Benchmark / Mock 完成後 Result / Review 是否允許 Tutor，依該 Assessment phase 正式 policy 另決；active 期間預設 DISABLED 已核准 | 適用 Assessment phase 功能導入前 |
| Feedback / Privacy | anonymous / account-linked、附件／截圖、logs、過濾、retention、developer UI、backend storage 與刪除範圍 | Phase 5 Feedback 功能前 |

本表登錄 V2.2 已提及但未具體決定的實作參數，以及 CR-0001 新增需求中
尚未決定的實作／政策參數；不將未決事項視為已批准的產品行為。已決定項目
須標記完成並保留決策紀錄。Show Furigana 預設 ON、可關閉、Mock Exam 交卷前
不揭露，以及 Practice / Review 可關閉回饋音效均為已確認需求，非未決參數。
CR-0002 已確定 Hiragana / Katakana、四種練習流程、Kana expected answer、
離線 keyboard fallback 與僅辨識 Kana identity；不得以待決參數延後或改寫。
`DEC-P1-001`、`DEC-P1-003`、`DEC-P1-004` 均有 Repository Decision Record；
Phase 1 core data conventions 依 `DEC-P1-004`。
CR-0004 §7.3.1 已核准 Phase 1 `singleChoice` Practice / Review 的 session、
answer、revision、resume、retry、completion 與 Result 來源契約，非本表待決政策。
若後續要加入 learner-facing discard / abandon / start over、同題 explicit retry
或其他 answer type 的正式資料語意，須另作 Specification Decision；不得由實作
自行擴張。05 / 04 的細部 delivery 排程屬適用正式設計／任務文件，不在此表
硬編碼 sprint 日期或特定工具／model。

CR-0005 A2-Core 的 primary target ownership、navigation / unlock / availability
分離、無 active goal 的語意與 contextual / historical target 邊界已核准，非待決事項；
A2-P1 / A2-R1 仍 OPEN / DEFERRED。CR-0006 已核准 §8.5 的 A3 authoritative scope、
四個核心狀態、access semantics 與 Level summary aggregation；這些不是待決事項。
A3-D1～D4 仍 OPEN；CR-0007 不因 Kana Foundation 定位而解決 A3-D1。
CR-0007 已核准 §1.1 的 shared foundational area、獨立可發現 entry、skip / revisit、
advisory-only recommendation、非 gate / 非 target 語意與 Foundation Core scope；
這些不是待決事項。A4-D1～D4 仍 OPEN，不把 core scope 寫成 completion requirement。
CR-0008 已核准 §1.2 的 distinct reference indexes、獨立 entry、level browse /
detail、canonical content reuse、A3 availability、Grammar zero / one / multiple
destinations 及非自動 completion / mastery / Assessment evidence；這些不是待決事項。
A5-D1 / D3 / D4 / D5 仍 OPEN；A5-D2 僅 Search core semantic 由 CR-0012 已核准，
Browse / Sort 與具體 Search interaction / presentation 仍 OPEN，不將 partial
resolution 誤作完整 UI / detail / representation 決策。
CR-0009 已核准 §1.3 的 global semantic frame、五個 Level destinations、Course /
Canonical Curriculum coverage boundary、zero Lesson mappings 與 distinct Practice
contexts，以及 §8.6 的 curriculum authoring / approval 職責；這些不是待決事項。
A1-D1～D6 仍 OPEN，A3-D1 不由 IA labels 決定，A4-D1 / A5-D1 不因 global
semantic frame 關閉。Level Selector / Home IA 的具體 UI、target UI、Cloud Sync、
account ownership 與 conflict resolution 未因上游 semantic 核准而獲核准。

CR-0010 A6-Core 的獨立 Assessment destination、history / current state 分界、
concept-level weakness lifecycle 與 adaptive priority semantic 已核准（§1.4、§13–16）。
A6-D1～D7 仍 OPEN；既有 MasteryPolicy、WeakPointPolicy、ReadinessPolicy、
Data Confidence、Assessment question-set / validity / Presentation Policy、
Mock Exam execution 與 Study Plan scheduling 未被 A6 關閉。
A1～A5 原 Open Decisions 保持；不由 A6 決定 UI、evidence counts / weights、
threshold、spaced repetition、storage representation 或 Phase start。

CR-0011-D1～D6 與 Shared Baseline 的 Phase 2 contextual entry、canonical-first、
ephemeral multi-turn、language / reading、post-feedback、Gateway、structured
response、offline fallback、minimization 與 no-evidence semantics 已核准，非待決事項。
上述 architecture / runtime / privacy 與 post-assessment row 不得被用來更改
已核准語意；Global AI destination、Local-only history、voice / image、AI-generated
ruby、conversation evidence 與跨教材 retrieval 若未來需要，須另行需求／架構決策。
既有 A1～A6 Open Decisions、Phase scope / order 與其他 gates 保持不變。

CR-0012 已核准 §1.2.5–1.2.10 的 Search scope、cross-level、publication、
matching / ranking、result / no-result、offline / evidence 與 Phase 2 placement，
不是待決事項；其 schema / engine / index、具體 UI 不由本 CR 決定。
AI-assisted Retrieval 維持 DRAFT / NOT PART OF CR-0012 / NOT AUTHORIZED；
A1-D1、A5-D1 / D3 / D4 / D5 與其他剩餘 Open Decisions 不因此關閉。

CR-0013 的 SR-D01～03 已由 Developer 核准：§6 的 bounded Phase 1 Settings
entry，以及 §7.4.1 的 single global showFurigana、success-confirmed propagation、
read failure / retry / recovery 與 reading policy priority，不再屬待決語意。
本版經 Developer 核准並正式進入 Repository；CR-0013 APPLIED，V2.16 取代 V2.15 為 Current Approved Spec；production implementation 未授權。

此核准不關閉 A1-D1～D6 或 A2-R1，不批准 SR-D04 Feedback Sound preference
race / unknown policy、SR-D05 Reset / Factory Reset execution、SR-D06 Audio
sample / canonical unit policy、SR-D07 Audio replacement / Back behavior 或
SR-D08 Non-Windows capability presentation / adapters。上述未決項目不得由
實作代決；本 CR 不新增它們的具體政策，不修改既有 Audio / Feedback Sound、
Reset scope / Content deletion option，不構成整份 05 V0.1 或 Global Design
System 核准。Settings family 的適用 Design Approval / handoff 仍依 §6.1。

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
    Furigana / Settings 的 CR-0013 global preference、read failure / retry 與
    policy isolation 依 §7.4.1 / §24.9 核對；既有 §6.1 family handoff gate 保留
[ ] Learning Preference 不改寫正式 Mock Exam 題組；交卷前沒有答案洩漏
[ ] Feedback AI 建議須經 Developer 決策，敏感資訊依已核准政策處理
[ ] CR-0002 適用的 Kana Content、鍵盤／手寫四種流程與離線 fallback 已驗證
[ ] Handwriting provider Decision Record 已核對；UI 分層、Submit 後辨識、
    逐題回饋／手動 Continue、手寫資料最小化及必要 migration 已驗證
[ ] CR-0004 適用的 Practice / Review snapshot、逐題 durable answer、stable context
    與單一 active session、Continue 前後及最後一題的 durable resume progress、
    冪等 Submit / completion、Final Result 來源及 versioned migration 已驗證
[ ] 新 learner-facing interaction family 的正式 contract 與適用 05 handoff
    已核對；主要 UI 完成後接受 fidelity review，適用級別進行整合一致性 audit
[ ] Production visual 的穩定 Content、visual need、05 約束、Developer Visual
    Review 與獨立 integration authorization 已核對（適用時）
[ ] CR-0012 Search 的 offline canonical matching / ranking、cross-level results /
    detail、publication / availability / no-result 及 no target / evidence mutation
    依 §24.8 / §38.5 驗證；適用 05 handoff 已核對，不新增 Phase 1 closure gate
    或 AI-assisted Retrieval authorization
```

AI 功能另外需要，依下列共同與專屬責任適用；此分類不降低任何功能的既有
Requirement / DoD。AI 題庫、Assessment、Readiness 與 Knowledge Mapping 的
專屬要求不得因功能使用 AI 而無條件套用 CR-0011 Tutor；Tutor 仍須完成
每個功能的共通 DoD、下列共同 AI 檢查及其已核准契約。

```text
共同 AI requirements
[ ] JSON Schema
[ ] Cost / usage limit
[ ] Sensitive data review

AI 題庫 / 生成題目（§10.2–11）
[ ] Rule Validation
[ ] Duplicate Detection
[ ] Version metadata

Assessment（§14）
[ ] Assessment version metadata

Readiness（§15、§42.2）
[ ] Readiness policy version

Knowledge Mapping（§8.3、§13.2）
[ ] Knowledge mapping completeness

CR-0011 Tutor（§10.1、§24.7、§38.5）
[ ] CR-0011 適用 Tutor 的 canonical revision context、structured answer basis、
    ephemeral multi-turn、zh-TW / Japanese、reading 分界、post-feedback eligibility、
    Assessment exclusion、no-evidence mutation、privacy 與 offline failure isolation
    依 §24.7 / §38.5 已驗證；不以本 Spec promotion 授權 implementation
```

## 41. V2.16 結論

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

CR-0002 在 Phase 1 補足 Hiragana / Katakana 的離線鍵盤與支援裝置上的
手寫練習；手寫辨識 unavailable 時保留鍵盤練習，不改變後續 Assessment
或 Mock Exam 的回饋政策。

CR-0007 將此 learning area 明確定位為 Kana Foundation：與 N5 同在 Phase 1
交付但不由 N5 擁有，提供獨立可發現 entry，learner 可 skip / revisit；Foundation
Core scope 與 learner completion 分離。不以 Kana progress 決定 availability、
unlock 或 target，不以 Kana completion gate JLPT content；未決政策依 §38.11。

CR-0008 提供 distinct Vocabulary / Grammar reference indexes，可獨立進入並
依 JLPT level browse / detail，不需 Lesson completion 或變更 target。沿用正式
canonical content、publication 與 A3 availability；Grammar 可連結 zero / one /
multiple learning destinations，觀看不自動成為 completion / mastery / Assessment
evidence。最終 IA、interaction、detail、relationship 與 progress 依 §38.11 待決。

CR-0009 以 §1.3 的 Learning frame 組織 Foundation / JLPT Courses / Vocabulary /
Grammar；各 Level 可發現，存取與 target 分離。Canonical curriculum 定義 coverage，
Course / Lessons 組織教學；Reference / focused Practice 不要求每個 item 有 Lesson。
三個 Practice contexts 與既有 learning / Assessment 契約並存，實際 curriculum
由 03 → 06 → Developer 處理；未決 UI / Curriculum / Practice policy 依 §38.11。

CR-0010 提供獨立 Assessment destination 與 learner-facing Learning History，
Learning / Assessment evidence 各保留來源與用途；concept-level WeakPoint
可 improving、resolved、reopen，resolved 不抹去歷史。Adaptive Review 優先弱項與
低信心，high mastery 不代表永不複習，也不改固定評估 validity。具體 UI、policy
與 representation 依 §38.11 待決，Phase order / gates 保持不變。

CR-0011 在 Phase 2 提供 contextual AI Tutor 追問：canonical-first 的補充解釋，
限 current revision-bound ephemeral Session，正式教材與 curated explanation
仍為 baseline。Learner 可在閱讀內容或完整 Practice / Review feedback 後以文字
提問，收到 zh-TW explanation / Japanese examples；不足 context 明確表示限制。
Tutor 不改 canonical reading、學習／評估證據或答案／結果，active Assessment
預設禁用；network / Gateway 不可用時離線核心保持。V1 scope 與未決細節依
§10.1 / §38.11，不新增 Global Chat、voice / image 或 persistent / Cloud history。

CR-0012 在 Phase 2 先提供 local canonical Vocabulary / Grammar discovery：
single query 預設跨 N5～N1，deterministic results 導向正式 canonical detail；
learner 無需先知道 Level / Type / Index，不改 target 或學習／評估證據。
Offline Search 沿用 publication、A3 availability 與 Content governance，不要求
AI / Cloud / network，也不新增 Search History 或 parallel canonical source。
A5-D2 僅 Search core 部分解決；具體 IA / interaction 與其他未決事項依 §38.11。
未來 AI-assisted Retrieval 仍 DRAFT / NOT PART OF CR-0012 / NOT AUTHORIZED，
不擴張 §10.1 contextual Tutor，也不變更 Phase 1 closure gate。

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

以上 N5 是示例；primary JLPT learning / exam-preparation target 依
`StudyGoal.targetLevel`（§15.2.2）。示例、瀏覽級別與 historical / contextual
records 均不設定 primary target；未設定也不阻止 learner 存取 available content。

可存取內容包含 §8.5 的 Available / Partial；Level summary 不表示 learner
progress、mastery 或 unlock，也不取代各 Content Family 的 availability。

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
- CR-0006 的 Content Availability 依 §8.5：JLPT Level × Content Family 為
  authoritative scope，Level summary 為 derived product summary，不是 learner
  state。Content lifecycle / contentVersion 與 runtime capability 保持獨立；
  A3-D4 representation 仍 OPEN，不因 semantic contract 建立 schema、migration、
  Cloud contract 或 Content Update protocol，亦不改既有資料生命週期。
- CR-0005 的 `StudyGoal.targetLevel` ownership 依 §15.2.2；不以 AppSetting、
  UserProfile、navigation state 或 contextual / historical target 取代。A2-P1
  persistence timing 與 A2-R1 Reset lifecycle 仍依 §38.11 待決；不由 ownership
  推定 SQLite table、migration、導入 Phase、Cloud / account policy 或 Reset 處置。
- Reset 操作必須依第 17 節 scope 執行於 transaction；完成後驗證 Content Data 保留及 Derived Analytics 清除/重建結果符合所選 scope。
- `contentVersion`、`questionSetVersion`、`scoringVersion`、`scoringPolicyVersion` 各自代表不同版本，不得共用一個版本欄位代替。
- CR-0001 的 reading / alignment、audio reference、curated explanation、AppSetting 與 Mock Exam confirmed submission 若需新增 schema，須以 versioned migration 保留既有資料並測試舊版升級；Feedback backend 的實際 schema 與 retention 待 Phase 5 決策，不預建假 Cloud 實作。
- Phase 1 identity / time / nullable 慣例依已核准的 `DEC-P1-004`：UUID v7 / TEXT、UTC timestamp、date-only 分離、nullable 僅用於語意真正可缺值，unavailable / unknown / not-applicable 優先明確 status。KnowledgeConcept identity 仍依 §38.11 的 Phase 1.5 決策，不由 Kana schema 先行決定。
- CR-0002 的 Kana Content / Practice Answer 若需新增 schema，保留舊資料並提供 versioned migration 與 upgrade test；辨識 strokes / points 不因作答而永久保存。
- CR-0007 的 Kana Foundation progress 依 §1.1 / §7.3 歸為 learner state，
  不作 availability / unlock / target state。A4-D2 completion / progress 政策與
  A4-D4 representation / persistence 仍 OPEN；Core scope 與 entry 契約不授權
  新增 progress schema / table 或 migration，既有 Content / Answer lifecycle 不變。
- CR-0004 §7.3.1 的 Phase 1 `QuizSession`、有序 `QuizSessionQuestion` 快照與
  `QuizAnswer` 須以既有 production schema 之後的新 versioned migration 導入，
  不回寫已發布 migration、不刪庫重建；驗證新安裝、舊版升級、重開、Content
  Data 保留、必要欄位 backfill / default、ID / FK、唯一答案、不變性及失敗重試。
  Reset quiz records 依 §17.1 處理 session / snapshot / answer 關聯，不誤刪教材。
  Schema / Repository 亦須 durable 表達相同 stable context + mode 的單一 active
  `in_progress` session 與 §7.3.1 的 presentation progress；具體 table、column
  或 enum 表示不在本 Spec 鎖定。

- CR-0008 Reference Index 依 §1.2 沿用 canonical Vocabulary / Grammar identity、
  immutable revisions 與 publication / provenance，不新增平行 content entity。
  Grammar destination cardinality 不選定 relationship schema；browse / detail view
  不自動產生 completion、mastery 或 Assessment evidence，A5-D4 / A5-D5 保持
  OPEN；本 CR 不新增 schema / migration、不修改 KnowledgeConcept contract。

- CR-0009 的 Canonical Curriculum / Course / Practice context semantic 依 §1.3；
  不新增 canonical content source 或 schema / table / join / migration，不改既有
  Content lifecycle、identity / revision、KnowledgeConcept、§7.3.1 session /
  answer / resume 契約或資料生命週期。A1-D2 state / persistence 仍 OPEN，
  navigation 不修改 primary target；A2～A5 原未決事項保持不變。

- CR-0010 的 Learning History 為 projection / view，WeakPoint lifecycle 為
  semantic，不要求單一 History / 新 Assessment table 或 WeakPoint persisted enum；
  不新增 schema / migration，不改 Content / User State / Derived Analytics 分層、
  §7.3.1 durable session 與 §17 明確 Reset / Delete scope。Resolved 不刪 historical
  evidence，也不自行決定 WrongQuestion persistence lifecycle。

- CR-0011 ephemeral Tutor Session 不新增 persistent conversation / message
  history、Cloud history、schema 或 migration（§7.3、§10.1.3）。Canonical content
  identity / immutable revision / ContentVersion 既有契約保留；對話不成為正式
  learner evidence，不改既有 durable QuizSession / QuizAnswer 或 Derived Analytics。
  後續若其他正式需求需 schema 變更，仍依既有 versioned migration policy，
  不以本 CR 預建 history table 或 destructive reset。

- CR-0012 Search 沿用 canonical Vocabulary / Grammar logical identity、
  immutable revision、ContentVersion、effective published / provenance（§1.2.6）。
  Comparison normalization 不改 canonical text，不建立平行 content source、
  Search History / personalization persistence、table / index 或 migration。
  未來 history 須另決 persistence / retention / Reset / Privacy / learner-state；
  若正式 schema 變更獲准，仍須 versioned migration、保留現有資料與 upgrade
  test，不以刪庫重建替代。本次不選 engine 或 schema，不改既有 §17 Reset。

### 42.2 Policy 與可重現結果

Mastery、Readiness、Weak Point 與 Assessment validity 的規則集中在對應 policy。每筆衍生結果應記錄足以重現其計算的 policy/version 及證據範圍；政策更新不得靜默改寫舊 Assessment 的原始答案或版本資料。

V2.2 提供的 Readiness 初始權重 55/25/10/10 是工程假設。使用前仍須定義 insufficient-data 規則及分區 gate；在此之前，UI 不可顯示 ready/ready_with_buffer 作為有效結論。對外文字不得稱為官方分數、統計信賴區間或通過機率。

CR-0010 的 historical evidence / AssessmentResult / ReadinessSnapshot 不被
後續 current Mastery / WeakPoint / Review Priority retroactively 改寫（§13.6）。
Derived Analytics 可重算不代表可因後續 current state 改寫既有 historical result；不選定 evidence
weighting、resolution threshold 或 suppression algorithm。Adaptive learning
不得改變 fixed Benchmark / Mock validity；各政策仍須正式版本化與可追溯。

### 42.3 階段驗證最低要求

各 Phase 除其功能測試外，至少保留下列回歸檢查：

| 完成階段 | 必須重跑的既有流程 |
|---|---|
| Phase 1.5 | Phase 1 離線課程、Quiz、Wrong Question、Review、Reset；Practice / Review 逐題 durable answer、Continue 前後及最後一題 progress resume、session completion / Result 與 migration 升級；reading / Furigana、Audio 降級、逐題回饋／詳解、Settings 持久化；Kana keyboard / handwriting、recognizer unavailable 與離線 fallback |
| Phase 2 | Phase 1 + Slice A；Gateway 關閉時 reading、Lesson、curated explanation 與 Quiz 的離線流程；CR-0011 Tutor unavailable / failure 不破壞核心 learning state（§24.7）；Local Canonical Search 的 offline canonical result / detail、publication 及 no target / learner-evidence mutation（§24.8） |
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

### 42.6 CR-0002 驗收與風險

驗收以 §4–8、§12.6、§14.1、§24、§27–28、§34、§38.3–38.4、§38.11
與 §40 為準：

- Hiragana / Katakana 可離線學習；聽音或視覺提示各自支援鍵盤與支援裝置的
  手寫作答。鍵盤比對正式 Kana；IME 轉換後的 Kana 可用，直接 Romaji
  不自動視為正解。
- 手寫 Canvas 可清除／重寫，僅在明確 Submit 後辨識並產出 Kana candidate
  或明確 unavailable / error；成功時與 expected Kana 比對並顯示辨識結果、
  正誤、正解、可重試及離線 curated explanation / 學習提示；依 `DEC-P1-003`
  可關閉音效且須手動 Continue。
- 日語 voice 不可用時依 `DEC-P1-001` 提供指引，視覺提示練習仍可完成；
  recognizer、touch / stylus 或 network 不可用時 Keyboard Practice 仍可完成。
  UI 不直接呼叫辨識 provider / SDK / 平台 API；核心不依賴 Cloud / AI API。
- Phase 1 不加入筆順、角度、速度、美觀或 AI quality score；不永久保存完整
  手寫軌跡。需要 schema 變更時提供 migration / upgrade test；相關 Unit、
  Widget、Integration 與平台證據須實際通過，Phase 1.5 回歸納入 Kana 流程。

風險：不同平台 touch / stylus 與離線 recognizer 能力可能不一致；模糊辨識
可能誤判；日語 voice 或 recognizer 缺失會減少可用模式；手寫軌跡若被記錄
可能造成隱私風險。Provider、confidence / 多候選、答案正規化及平台適配
須在導入前有 Decision Record；不得以未決參數猜測產品政策。

治理狀態：V2.16 是 Current Approved Spec；Developer Approved / Repository Integrated。
V2.16 取代 V2.15；CR-0001～CR-0013 均已 APPLIED。
CR-0013 APPLIED；APPLIED：Yes。
僅 SR-D01～03 已正式整合；production implementation 未授權。
A6-Core APPLIED；A6-D1～D7 OPEN；A1-D1～D6 OPEN。
A2-P1 / A2-R1 OPEN / DEFERRED；A3-D1～D4、A4-D1～D4 OPEN。
A5-D1 / D3 / D4 / D5 OPEN；A5-D2 PARTIALLY RESOLVED：
Search core semantic 已核准，Browse / Sort 與具體 Search interaction / presentation 仍 OPEN。
AI-assisted Retrieval：DRAFT / NOT PART OF CR-0012 / NOT AUTHORIZED。
V2.15、V2.14、V2.13、V2.12、V2.11、V2.10、V2.9、V2.8、V2.7、V2.6、V2.5、V2.4、V2.3 保留為被取代的歷史 Spec。
Phase 0 COMPLETE；Phase 1 STARTED / NOT YET COMPLETE；Phase 1.5 / Phase 2 NOT AUTHORIZED。
