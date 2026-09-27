# JLPT Learning App

以 [V2.4 技術規格](JLPT_Learning_App_Technical_Spec_V2.4.md) 為主要產品規格，採 Local-first、Offline-capable 與 Feature-first／MVVM／Use Case／Repository／Service 分層。

目前交付為 **Phase 0 App Shell 與基礎建設**；學習教材、測驗與 Reset 尚未實作。最新階段閘門及驗證結果見 [Phase 0 Closure](docs/phase-0-closure.md)；[初次交付紀錄](docs/phase-0-validation.md) 保留歷史結果。

## 開發入口

- [開發環境與重現步驟](docs/development-environment.md)
- [Phase 0 基礎建設決策](docs/decisions/phase-0-foundation.md)
- [待決策登錄](docs/decisions/phase-0-open-decisions.md)
- [貢獻與架構規則](AGENTS.md)

`app/` 是 Flutter 專案，含 Windows／Android／iOS targets、分層 App Shell、SQLite migration framework 與測試。`.github/workflows/flutter.yml` 提供品質檢查與三平台建置；Backend 與 Python Pipeline 於對應階段才建立。

## 快速開始

確認 Flutter 3.47.5／Dart 3.13.4，以及平台工具可用。Windows plugin 開發需啟用 Developer Mode，讓 Flutter 建立 symlinks。

```powershell
cd app
dart tool/check_sdk.dart
flutter pub get --enforce-lockfile
flutter run -d windows
```

完整測試與各平台建置指令見開發文件。請勿將本機資料庫、側錄檔、憑證或任何 provider secret 納入 Git。
