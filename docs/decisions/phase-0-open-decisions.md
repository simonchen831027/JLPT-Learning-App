# Phase 0 待決策紀錄

依 `JLPT_Learning_App_Technical_Spec_V2.3.md` §38.11 登錄。已核准的 Phase 0 決策記錄於本文件；其他項目保持「待決策」。每項決策均記錄決定、理由、日期及適用的 policy/version；未決項目不得猜值或硬編碼。

## 已核准決策

決策日期：2026-09-26。

| 項目 | 決定 | 理由／限制 |
|---|---|---|
| Flutter / Dart SDK | Flutter 3.47.5 stable；使用隨附 Dart 3.13.4，不獨立安裝 Dart。 | 依 Flutter 官方 Windows SDK release index；Flutter 與 Dart SDK 綁定以避免版本漂移。 |
| .NET SDK | 10.0.401；根目錄 `global.json` 精確鎖版，`rollForward: disable`。 | 目前已安裝版本；設定檔只指定 SDK，不建立 .NET 專案。 |
| Python SDK | Content Pipeline 使用 Python 3.14.7。加入實際套件時驗證相容性；若不相容，先新增 Decision Record 才能改版。 | 避免在尚無依賴清單時臆測套件相容性或自行降版。 |
| Flutter dependency lock | Flutter App 的 `pubspec.lock` 納入 Git。 | 固定 App 的直接與間接 Dart/Flutter 套件版本。 |
| NuGet dependency lock | NuGet 專案開始時提交 `packages.lock.json`，restore 使用 locked mode。 | 確保應用程式依賴可重現；專案尚未建立。 |

官方版本依據： [Flutter SDK release index](https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json)、[Microsoft .NET 10.0 download](https://dotnet.microsoft.com/en-us/download/dotnet/10.0)、[Python downloads](https://www.python.org/downloads/)。

| 狀態 | 項目 | 待決定內容 | 最晚決策階段 |
|---|---|---|---|
| 待決策 | KnowledgeConcept identity | ID 格式、內容改版後是否沿用 concept ID | Phase 1.5 |
| 待決策 | QuestionConceptMap | 權重範圍、合計規則、主要概念限制 | Phase 1.5 |
| 待決策 | MasteryPolicy | 加權公式、最低證據量、狀態切換條件 | Phase 1.5/2.5 |
| 待決策 | Assessment 題組 | 各模式/級別題數、題型、抽題規則 | Phase 2.5 |
| 待決策 | Assessment validity | 超時、跳題、缺題、重複作答門檻 | Phase 2.5 |
| 待決策 | ReadinessPolicy | Section safety threshold、狀態切分、權重與版本遷移 | Phase 2.5 |
| 待決策 | Data Confidence | 各信心級別所需題數、覆蓋率、次數與時效 | Phase 2.5 |
| 待決策 | WeakPointPolicy | importance、recency、confidence 尺度與最低證據 | Phase 2.5 |
| 待決策 | Study Plan 排程 | 每日/每週量、考期接近時的調整與排序 | Phase 2.5/4 |
| 待決策 | 官方 JLPT 資料 | 發布前核對日期、分區及門檻版本 | 發布前 |
| 部分決策 | SDK / providers | Flutter 3.47.5、Dart 3.13.4、.NET 10.0.401、Python 3.14.7 已選定；STT/TTS provider、平台支援與成本限制仍待決策 | Phase 0/2/3 |

## 延後決策

| 狀態 | 項目 | 待決內容 | 最晚決策時點 |
|---|---|---|---|
| 已選定 | Python lockfile 格式 | uv 0.12.19 + `uv.lock`；本次授權評估選定，實際套件加入時驗證 | 見 [Phase 0 基礎建設決策](phase-0-foundation.md) |
| 已選定 | Python 多平台鎖定 | 同一跨平台 lockfile；Windows／Ubuntu 使用 locked sync 並驗證 | 見 [Phase 0 基礎建設決策](phase-0-foundation.md) |
| 已核准 | iOS 建置主機 | 使用者於 2026-09-26 選擇 macOS GitHub Actions；未簽署編譯 | 見 [Phase 0 基礎建設決策](phase-0-foundation.md) |
| 待決策 | STT/TTS providers | Provider、平台支援及成本限制 | Phase 2/3 導入對應 provider 前（依 V2.3 §38.11） |

SDK 與依賴策略已記錄於 [Phase 0 基礎建設決策](phase-0-foundation.md)。Flutter 依賴已加入並鎖定；Python 套件加入時仍需驗證 Python 3.14.7，若失敗須先新增 Decision Record 才能改版。App Shell、SQLite migration framework 與最小 CI 已納入本次實作，實際閘門狀態見 [Phase 0 交付紀錄](../phase-0-validation.md)。

## 實作前仍須補齊的決策

| 項目 | 影響與決策時點 |
|---|---|
| Entity ID、時區與 nullable 規則 | V2.3 §42.1；正式 Phase 1 schema 開始前記錄，KnowledgeConcept identity 仍依 Phase 1.5 決策。 |
| 正式 application/bundle ID、簽署 | 目前使用 Flutter 範本開發識別；對外發布、安裝正式資料或配置簽署前選定。 |

決策完成時，記錄決定、理由、日期與 policy/version，並連結實際採用的 SDK 設定或工具文件。不得只將建議當成已核准決策。
