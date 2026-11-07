# AGENTS

Applicability: 生效依 Root §0 完整 Bundle 條件及 Developer 對本 revision／全文的精確批准、正式整合、適用驗證與最終 Acceptance 判定；候選產出、Source Write 或 Review PASS 均不單獨使其生效。
Governance Revision: AGENTS-THINROOT-V270-R01
正式目的地：AGENTS.md；路徑標示不授權執行／套用。

# 0. 同級附錄／Revision／G0

Root與下表構成同一AGENTS Bundle；附錄屬§1.2第4層，不因docs/路徑變成第3層ProjectDocument。

| 登錄 | 正式路徑 | 內容 |
|---|---|---|
| D | docs/governance/AGENTS_GOVERNANCE_DETAILS.md | 完整程序／例外，沿原§1～16 |
| T | docs/governance/TASK_REVIEW_PACKET_TEMPLATES.md | T1 Task、T2 Review、T3 CHAT_HANDOFF、T4 CODEX_DECISION、T5 SESSION_HANDOFF |

三檔須同次精確Developer批准、Repository整合、指定同一生效revision並核批准綁定的各檔bytes/hash；不可只看Bundle標籤、只套Root或部分APPLIED。Project設定另批；身分記既有批准/Task/Review，不建永久登錄。

G0讀Root、完整Task、適用正式來源並核附錄revision/identity。操作前實讀D：Repair/副作用§3.6；共享資源/Native§3.7；Escalation§4～8；Evidence§12；交付/Activation/Recovery/Artifact§13；Git§14；Session§15。產生正式Packet/Handoff/Decision先讀T全文。必要來源缺失、超ReadScope、identity不符或衝突即STOP相依工作，交01/Developer；不猜補或自選優先。

未正式生效附錄無現行權威。Root達bytes目標不證完整指令鏈／有效Runtimebudget／自動載入，文字Binding不證強制Pinning／原子Claim／Exactly-once。


# Language

使用繁體中文回覆、撰寫報告、CHAT_HANDOFF 及 Decision Record；程式識別字、API、檔名與必要技術詞保留原文。

# 1. Source of Truth 與規格治理

## 1.1 Current Approved Spec

Baseline：JLPT_Learning_App_Technical_Spec_V2.16.md，Current Approved Spec／CR-0013 APPLIED；V2.15～V2.3 historical。新版須Developer核准、正式進Repository、明確supersede、對應CR APPLIED四條件俱足；不可因舊AGENTS忽略正式新版。

## 1.2 權威順序

1. Current Approved Repository Spec
2. Approved Change Request
3. 正式 Project Documents／Architecture Documents／Decision Records
4. AGENTS.md（含 §0 登錄且同 revision 生效的附錄）
5. Existing Code／Tests
6. Current Task Packet／Current Chat／Work／Codex Task Context
7. Previous Session／Conversation
8. ChatGPT Memory

第3層須Developer批准且正式入庫；Draft/Proposal/Work/Screenshot/Benchmark/localhandoff不屬正式文件。排序不授權未APPLIED實作；歷史不覆現況。指令與Spec產品／架構衝突STOP。詳D§1.2。

## 1.3 Spec 與 Code

Spec定義應有行為，Code為實況；差異區分bug／未完成Requirement／正式決策缺口，不配合Code默改Spec或推其過時。決策缺口走§4～8。

## 1.4 Requirement／Change

DRAFT討論不實作、不要求CHANGE_REQUEST:DRAFT；APPROVED須Developer確認及正式APPROVED CR，僅Work依scope建Candidate；APPLIED須Review/Approve、正式入Repository成CurrentSpec。未APPLIED不實作新版，獨立不受影響工作可續；Candidate非APPLIED、未解衝突不覆現規。Implementation依§7.1；純治理不授產品／實作權。

## 1.5 Grounding／Source QA

各Workspace於重要Task/久置恢復/換Session/Review/Handoff/Candidate/Repository判斷前核CurrentSpec、AGENTS、相關正式Decision/ProjectDoc、ApprovedCR/CODEX_DECISION及直接input；可存取時核Root/branch/HEAD/upstream/workingtree/相關tracked內容。歷史/Memory/舊Packet/Sessionage非現況；衝突依§1.2，缺來源明列限制並交01/Developer決策。

對指定 Source Checkpoint 的 Hash Gate，Expected 必須取自可識別的原始批准、
適用正式 revision 或批准明指的 canonical source block；Observed 必須由工具讀取
指定檔案的原始 bytes 計算，不得以 Observed 自填 Expected。分別記錄來源引用、
path / revision、bytes、Expected、Observed、格式判定及比較結果。SHA-256 須以
完整 64 字元 Hex 驗證；僅忽略 Hex 大小寫比較，不補字、不截取或改檔修配 Hash。
只有獨立 Expected 與 Observed 格式有效、完整相等，且指定 bytes（若有）相符，
才能標 Verified Match。缺失、格式錯誤或不符時停止依賴該 checkpoint 的工作。
有效 Expected 與實讀不符是 checkpoint mismatch；格式錯誤是 input defect，
兩者均不自行判定為 typo 或以既有檔案證明批准已變更。
Packet 生成優先引用單一 canonical Expected block；必要副本由工具產生並於發布前
核對完整值、bytes、來源引用及一致性，不建立第二份人工 Expected 權威。
Developer 勘誤須保留原值、原批准定位、勘誤的人類訊息與適用 scope / revision；
不改寫原批准，重新通過受影響 Gate 後才繼續，且不恢復任何已耗用額度。
本規則不新增原 Task 未要求的事前 Hash Gate；未提供獨立 Expected 時記
NOT PROVIDED / UNVERIFIED，不宣稱 MATCH；原已明定的 Gate 不得豁免。

# 2. 主要產品規格

需求／Phase／Scope／Architecture／驗收依CurrentSpec；先建立適用Decision，不猜／硬編碼未決政策或增刪／降低Spec。詳D§2。


# 3. 職責、Scope 與資源

## 3.1 Autonomy-First

已准工程以自主交付為預設。依D§3.1分流Routine／Bounded Recovery／Coordination／Hard STOP。一般技術決定在原授權內自處，守§3.6／3.7及§4～6。正式Contract及政策依§3.2。

## 3.2 不具有的權限

不得自行新增需求、決定 Spec 未定義的可觀察行為，或改 API、DB semantic／ownership／lifecycle、Architecture、Privacy／retention、Readiness、AI Agent 產品權限、Migration、Compatibility、Scope／Requirement。技術建議不等於 Developer 決策。

## 3.3 Workspace 分工

01分析Product／Architecture／Governance與Review，Developer最終批准；Repository保存正式狀態。01 Work 依有效 Batch Approval／Delegated Envelope 統一配置 Child、派工、查狀態、協調資源及收件。已逐項批准免重請。不自批新 Task、產品架構或政策。02維護Spec／治理／Decision／CR；03研究／原創authoring／provenance／AuthorQA；04Visual；05UI/UX／DesignSystem／accessibility／fidelity；06IndependentContentQA。Codex依批准實作／驗證，A獲准Native／Integration而非永久GitOwner，B UI／Features，C Domain／Data，D Tests／IndependentReview不自得production寫權。

介面/對話名稱不升權；03Chat/Work同角色。未正式批准/整合的Work輸出為Draft/Proposal/Review-ready。02文件維護不含application/tests/CI/Backend/Python；治理不能改產品、Architecture/API/Data/Migration/Compatibility/Privacy/Security。跨角色拆責任、不代決；詳D§3.3。

## 3.4 Artifact status

Work output→Draft／Proposal→Review-ready→DeveloperApproval→適用Change／Decision lifecycle→RepositoryIntegration並可識別Approved／Current，才成正式來源。明確批准且當前Task精確指定的local-only input可在scope內使用；記path/version/hash/批准範圍（可行時），不升權、覆蓋正式來源或授權Release／DesignPolicy／Production／APPLIED。04visualapproval、05recommendation、03content、02Candidate均非實作／release批准。詳D§3.4。

## 3.5 Handoff／Content

交接分Formal／task-specific approved input／Draft或history；最新Draft非currentapproved。依DEC007/008/009與D§3.5：03AuthorQA→06IndependentQA→DeveloperContentApproval→獨立ProductionIntegrationAuthorization（適用時）→Codex／validation。03Candidate、06PASS非APPROVED/RELEASED/實作權；新／實質learner-facing先06，targeted QA、既有ApprovedContent非追溯及immutable例外讀DEC009，不以自審替代。

## 3.6 Repair／工具副作用

額外Repair須Developer預准Envelope：精確FileAllowlist、DiagnosticCategories、禁改、修正／補驗預算、ValidationGates與STOP；不收回§3.1原授權，未列不推無上限。不得改正式Contract/policy、放寬／繞過assertions；留failurelog/diff/前後hash/command-result，做已准targeted補驗。預算耗盡／超scope／缺批准／正式衝突STOP；無新診斷不重跑。實作／測試／建置在核准 Scope／Envelope／Budget 內自主診斷、修復、補驗。Packet 預列替代診斷、有限恢復及交付額度，不繞平台拒絕或重置實耗。

Read-only／Source-immutable／Execution-only不自含Repair/Tests/Build；Envelope不含Git/Native/清理/DB操作。--no-pub非零副作用；SDK正常lock/stamp、Task-ownedtemp、合成DB/sidecar、generatedoutput/fixtureteardown僅精確scope/ownership/協調/清理/平台權限內，不擴sourceallowlist或任改整個cache。SDK升級/下載、全域cache修復、安全標記/憑證/設定、網路/安裝/費用、真實LearnerData刪除／不可逆清理另批。操作前讀D§3.6/13.3，Runtime/Native/Git獨立gate；新治理不追溯解除舊批准／STOP。

## 3.7 並行／Single Writer

並行不擴權。獨立寫入優先分離worktree／branch但建立／Git須批准；列Owner／目錄／baseline／scope／依賴／交付。worktree不帶其他dirty／ignoredinput，須核identity與批准。同checkout同時唯一SourceWriter；formatter／generation／tests／build之source及共用產物也須協調，分檔allowlist不是隔離。

SourceCheckpoint用commit或必要dirty／untracked／設定／input之path/diff/hash/state，不是新權威／批准；按風險不要求全庫複製。可變來源Review／Validation用固定checkpoint；ReadLease須雙方明認保護路徑、用途、起訖／釋放，期間不得寫。漂移／ownership不明STOP，首尾hash相同不是技術鎖或全程穩定證明。

獲准 01 Work 協調 checkout、Source Writer、SDK／Cache、Runner、Fixture 與共用生成物。核實際 Owner、範圍、互斥窗口及釋放。Windows 限定程序觀察可補證，毋須完整未知程序樹。Evidence／Slots 核 Writer，不覆他人。index不競爭，共同整合目標由指定GitOwner序列操作；整合前核來源／目的／依賴，整合後適用驗證，不用branch evidence證整合或用conflict resolution代決。

worktree不隔離Host／desktop／foreground／input／clipboard／capture／device／外部資料；干擾Native須明定Operator、互斥、process/window、額度及釋放。證明獨立且已准工作可續。協調記既有Task/Review/SESSION_HANDOFF，不另建永久lock/ledger；換session/介面/checkpoint不移交Owner。操作前讀D§3.7。


# 4. STOP Conditions

以下任何一項停止受影響工作：Spec不明或自相矛盾；指令與Spec產品／架構衝突；未授權publicAPI／Contract；新增未定義schema semantic、data ownership／lifecycle；改module／architectureboundary；多合理選項且影響Architecture／Product／Compatibility／Data／Security／Privacy／長期維護；未授權破壞既有功能／compatibility；Code差異不能判定implementationbug；需新增未定產品行為；需改Spec；歷史session衝突；缺Spec要求的Decision；超Phase／Scope；依未APPLIEDCR實作；未過Phasegate開始下Phase。

另依 Task STOP：批准不足、Source／Hash／Task／Attempt失配、未知重大副作用、超出Read／Write／Tool／Artifact Envelope、Budget耗盡、Writer／Runner／Native衝突、工具／平台拒絕或UNKNOWN，停止相依操作。不可用新Task名稱、換Host／Channel／Model／Session繞過或恢復額度。

# 5. STOP 後行為

保全安全狀態，清楚說明問題／缺證，產生 §6 CHAT_HANDOFF 等待Developer決策。不得猜政策、默改Spec／Requirement、擴scope、把建議／舊Session當批准或繼續blockedwork。已證明獨立、安全、明確授權部分可繼續；無安全工作寫 None。

# 6. CHAT_HANDOFF

正式STOP先讀D§6/T3，按T3完整格式及起訖寫明問題/原因/狀態、各選項全部影響風險、需批准的Recommendation/Decision、Blocked/SafeWork（無則None）；不只寫Spec不清，不續blockedwork。


# 7. Escalation

## 7.1 Implementation Decision

Spec足夠且不改正式Product／Architecture／API／Data：ImplementationDecision→Developer CODEX_DECISION（T4）→Resume。Agent自寫非批准、不代CR／免gate；§3.1普通決定不逐項升級。恢復核不衝突、evidence適用，完成尚需且獲准驗證並引用。接受evidence須記來源/source/command/result/scope；詳D§7.1。

## 7.2 Specification Decision

正式Product／Architecture／API／Data／Lifecycle／Compatibility／Migration／Privacy／Requirement改變：Developer APPROVED CR→Work Impact/Conflict/Candidate→DeveloperReview/Approve→Repository更新指定Current→APPLIED→Resume。重讀新Spec／變更／原HANDOFF、確認衝突解決並做相關regression；詳D§7.2。

# 8. Spec Modification

不得附帶默改Spec，走§7.2；明准純文件同步不授權產品變更。詳D§8。


# 9. Architecture／Data／Security

Feature-first/MVVM/UseCase/Repository/Service，UI不直呼DB/Provider/Platform；Local-first/Offline核心。Content/UserState/Derived分離，Derived可重算；SQLite版本化migration，Reset明確scope/transaction、不刪教材。Flutter無AISecret，AI經ASP.NETCoreGateway/Adapter。Practice/Diagnostic/Benchmark/Mock分開；Readiness非官方分數／通過率，樣本不足不得有效結論，Speaking不併入。不記secret／完整錄音／不必要敏感資料，守最小化/retention；真實LearnerData／不可逆處置須精確批准。守Phase/VerticalSlice、不擴scope；僅正式新版Spec/CR可改限制。Native/Production獨立批准。完整D§9。


# 10. 結構與風格

依Spec feature-first分層及各語言慣例／formatter，不做無關全庫refactor；完整目錄／命名依D§10。

# 11. DoD

適用Requirement／UI／Entity／UseCase／Repository／Service／Migration／錯誤與loading/empty／Tests／Privacy清單、formatter/analyzer、GitDiff/Codex/HumanReview均依D§11及Spec§40，工具仍須Task授權，未執行明列而非免gate。

## 11.1 Phase gate

Spec§38順序／gate及§42.3回歸保持；Task完成／部分PASS／文件更新不是PhaseComplete，未過gate不得開始下Phase。Spec§40共同AI與題庫／Assessment／Readiness／KnowledgeMapping／Tutor專屬DoD分開，不無條件套Tutor或降低既有要求。


# 12. Evidence

只報實際結果；未執行標NOT RUN，未知標UNKNOWN，環境未建立不宣稱build/test。Historical、Current working-tree、Committed clean-checkout、CI、Device/platform、Developer manual六類依D§12.1分別取證，可並列不擴證明範圍；每筆記執行者／日期／目錄／平台、commit/HEAD＋dirty、完整command/result/exitcode（可得時）/log、gate及限制。引用舊證據標本次未重跑與來源。

Developer完整command/result有效；CODEX_DECISION接受且source／依賴／設定／環境／scope適用，不無條件重跑。受測行為或環境變動、新失敗／coveragegap才說明補驗；換session不是理由。證據接受不減Spec／CI／device／cleancheckout／當階段regression。無輸出不等於失敗，先查process/log/進度；仍執行不重啟，無新診斷停重試、正常等待不是PASS。長工作回報進度並交接process/log。使用前讀D§12。


# 13. Task／Review／Activation

## 13.1 Review 與 Final Gate

重要交付須含Scope、ChangedAreas、SpecCoverage、Migration、Regression、Tests／evidence、Limitations、PendingDecisions、GitStatus。Review-ready須使用T2完整 CODEX_REVIEW_PACKET，19個必填欄位及起訖均保留。

固定local_data/codex-review/CODEX_REVIEW_PACKET.md，先check-ignore；未忽略先回報不自改.gitignore。不commit、不預設archive；並行Slot衝突／明准Outbox依精確位置同格式交付、不覆他人／自回填；無安全位置在對話交付。Evidence來自實際來源，提供足夠實際diff；大檔省略及已核准本文狀態差異例外依D§13.1，無法核baseline不得藏差異。保護敏感資料；Packet非權威、批准、validation或Phase完成、不代CHAT／SESSION_HANDOFF。

   交付前核對原始批准、Packet Identity、Expected / Actual Task、
   Expected / Actual Deliverable、Task / Attempt / Target Turn、Scope、
   已用 Budget 與 STOP；若任務或成果不符，標 TASK SELECTION MISMATCH / STOP，
   不以歷史成果替代交付，也不將受阻工作標為完整完成。

產生packet不授權Git或Phase改變；檔案失敗在終端同格式回報未建立；成功最終給path、branch/HEAD、dirty、下一步Review，不重複全文。只留本次必要evidence／scope／未解／建議commit範圍，處置依§13.3。D §13.1保留完整9項規則。

## 13.2 Task／初始 Binding／Recovery

須使用T1完整 CODEX_TASK_PACKET，14個必填欄位及起訖均保留；不適用填None／N/A，不猜測。重大Task須有原始humanApproval定位、Task/Version/Attempt、唯一Sender/Target/Host/Owner、Canonical path/hash、Source、DoD、Dependencies/ParallelGate、Read/Write/Tool/ArtifactScope、Budget（Trigger/Observation分列）、STOP/UNKNOWN、Review/AcceptanceOwner。MinorRepair等可選欄保留，不填不增權、不收回原§3.1授權。

長Task用完整Packet，短簡單Task可Composer；固定local_data/codex-task/CURRENT_TASK.md，先check-ignore。指標未啟用仍每Task一份全文、不累積歷史；結束舊內容不可執行，inactive可NO_ACTIVE_TASK。明准WorkspaceInbox即唯一CURRENT入口；入口有效性不明先核，不選最新/雙啟。Packet僅tier6transport，不覆Spec/CR/Decision/AGENTS、不解STOP、不自批Git/Phase；內含Decision權威來自原批准。

Initial Task Binding：在本節既有入口規則下，先核對原始人類批准及適用 Delegation、
實際 Target Thread / Turn / Host / Owner、Task / Version / Attempt、唯一指定
Canonical Inbox / Packet、實讀 bytes / SHA-256、獨立 Expected（適用時）、Source
Checkpoint、Scope / Budget / STOP。指定 Inbox 的 Developer Manual Activation
與 Delegated Activation 保留各自原批准及互斥規則；Packet 存在不等於啟動批准。
已指定入口無法取得或身分不符時，只在原批准內有限恢復該入口；不 fallback 到
Root CURRENT、其他固定 Slot、歷史附件或最新檔案。不能核實則 INPUT UNKNOWN / STOP。
有實際有效的競爭 Task / Attempt 時停止受影響工作，不將歷史檔案存在視為有效 READY。
身分及檢查結果沿用 Task / Review Packet 或 SESSION_HANDOFF 記錄；不自行建立
永久 ledger / lock，也不宣稱此文字規則提供 Runtime Task Pinning 或原子 Claim。

Context Recovery 不構成新派工。任何新的 Task-specific Action 前，先在原批准
讀取範圍恢復 §13.2 的 Initial Task Binding：原始人類批准 / 適用 Delegation、
實際 Target Turn、Task / Version / Attempt、指定入口與 Packet identity、Source、
Scope、已用及剩餘 Budget、STOP；核對同一有效工作單元後才繼續。
摘要、搜尋結果、歷史附件與未被本次指定的舊 CURRENT 不能替代本次批准或任務；
不自行選最新 Task、重啟歷史 Task 或以另一 Attempt 恢復額度。
Task Identity 與 Source Identity 分開核對；必要原文或身分無法恢復時，
標 INPUT UNKNOWN / STOP；Task 選取不符時標 TASK SELECTION MISMATCH / STOP。
有限原文恢復與工程預算分開，不重置 Trigger / Observation / Repair / Native / Git
及其他已核准額度，不解除舊 STOP。沿用 §15.2 SESSION_HANDOFF，不另建報告系統。

Manual 預設，Delegated 須明准。Developer 可一次逐項批准多個 Child，各綁 Task／Attempt、Target／Host、Packet 身分、Scope、Budget、STOP 與 Sender→Target Trigger 授權。雙方核原批准、Source／依賴／資源與 Tool／Runtime Gate 後，01 Work 可直派。每 Attempt 啟動前選唯一模式，互斥人工條件依 D§13.2／T1.1。Trigger 至多一次，提出即耗。拒絕／失敗／逾時／UNKNOWN 或額度耗盡依原 STOP，不重送、改派、換模式或恢復額度。UNKNOWN 僅依原額度唯讀查原 Target。READY 非啟動，Agent 訊息非批准。不得追溯重啟或在有效競爭下啟動。

Shortcut／合法Trigger只啟G0：全文有效、非NO_ACTIVE_TASK、未完成/Review/整合/取代、repo相容，再讀AGENTS/Spec/Git/STOP；不重貼已可取得全文、不猜scope或跳Packet。「我Review完了」非shortcut，續作需新Task或明確指令。ExecutionProfile非實際model/reasoning/approval/env保證，未知不猜，重大安全／正確性差異先報；非完全一致不全面停工。

Task/BatchApproval、DelegatedTriggerAuthorization、PacketDelivery、Activation、RuntimePermission、ExecutionCompletion、IndependentReview、DeveloperAcceptance分開。平台拒絕只由Developer選正式人工審核；Agent不換Host/Channel/FullAccess/安全設定繞過。

**條件式V2.7.0 File-First／CURRENT：**詳D§13.4。整個Bundle、Project設定、精確Task批准及RuntimeGate成立才啟用，否則沿原入口。01Work唯一Inbox／可變CURRENT Writer，Producer唯一自身OutboxWriter。Task-owned全文TASK/READY、RESULT/READY create-only、READY最後、bytes/hash核對，不取代14/19欄或固定Slots。CURRENT僅單一activeassignmentlocator，解析後讀完整Packet，先恢復原ActualTurn Binding，不依新pointer換任務。CURRENT建立/更新/釋放、staging/replace/backup/cleanup各須精確批准與前值／ownership核對；UNKNOWN不自retry/rollback/清理，無原子保證。Forward TASK_READY／Reverse TASK_TERMINAL只控制訊息，各需原human批准、平台Gate、預算；不得藏真實操作，Reverse只收件、Writer釋放後才通知。

## 13.3 Local Artifact

local_data非正式evidence。處置先唯讀KEEP/ARCHIVE/DELETECANDIDATE，分類不授權；建立/覆寫/搬移/封存/刪除各須精確scope/owner批准，未知KEEP。保護historical/acceptedevidence、dirty/untracked、learnerdata及他Task；不能依taskend/history或old/before/snapshot檔名刪正式文件/source/tests/CI/config。AllowlistNONE只對話交付不動Slots。清理非Git/Promotion/APPLIED/Phase/implementation權；CURRENTrelease非CLOSED/archive/額度恢復。完整例外及禁刪清單操作前讀D§13.3～13.4。


# 14. Git 與安全

起訖Git實讀、保留既存修改。Source／Validation／stage/commit／push分別明准。適用Review及commit後，push另批完整SHA、RemoteURL、DestinationRef、IntegrationOwner、nonforce、InvocationBudget、前後核對／STOP；commit不含push、push不含PR/merge/release，HTTPS唯讀非push能力。共同目標序列操作；分支與ConventionalCommit依D§14及Spec§21，不自增。禁止提交secrets/learnerdata/個資/不應入庫設定；秘密僅localenv或核准SecretStore，AI經BackendGateway。Native/Production/Release不由文書／TestPASS授權。


# 15. Session

## 15.1 介面／Resume

Windows主要CLI，Local可替代但須grounding；Cloud隔離不預設localdirty/ignoredinput。介面不永久獨占repo、不接管Task/Source/Git/NativeOwner。換Session/Model/介面不擴權、重置額度、解除STOP或覆他TaskSlots。CLI預設codex resume由Developer選，確知才--last；其他介面依實際能力，未知不猜model/native完成。適用evidence依§12重用。Spec/AGENTS/ApprovedCR/CHAT_HANDOFF/CODEX_DECISION/SESSION_HANDOFF/新Phase時重讀正式文件，Session非權威。詳D§15.1。

## 15.2 SESSION_HANDOFF

安全中斷／換session用T5完整起訖，記Task/Phase/Spec/文件、root/Git/dirty保全、完成/未完成/gate、CR/Decision/CHAT_HANDOFF、evidence分類/command/result/未執行/重用原因、活process/log/診斷、安全下一步/blocked/待決；保留原Binding/ActualTurn/Scope/Budget/STOP。無secret，不自commit/切branch/清理；接手重核正式來源/Git。Checkpoint非新批准／validation、不代CHAT_HANDOFF或解除STOP。

# 16. 核心工作原則

依§7分流、不跳Developer；02治理非產品／Phase批准。01Work收件→適用IndependentReview→01Chat→DeveloperAcceptance；READY/TaskComplete/TestPASS/同HEAD非Integration/Acceptance/PhaseComplete。詳D§16。
