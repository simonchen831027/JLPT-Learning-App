# DEC-P1-006 — UUID v7 Generation Dependency

- Decision ID：`DEC-P1-006`
- Status：`APPROVED`
- 核准來源：Developer 對 Phase 1 Slice 1A UUID dependency `CHAT_HANDOFF` 的明確決策
- 適用範圍：Current Approved Spec V2.5、`DEC-P1-004`、Phase 1 Slice 1A
- Spec Change Required：No

## Context

`DEC-P1-004` 規定 Entity ID 使用 UUID v7，Domain／Application 以 `String` 表示，SQLite 以 `TEXT` 儲存。Repository 尚無 UUID v7 generator，Slice 1A 已停止該部分並提交 `CHAT_HANDOFF`。Developer 現核准使用聚焦的既有套件實作，而非自行撰寫 UUID 演算法。

## Decision

- 核准 `uuid` version 4.6.0；`app/pubspec.yaml` 使用 repository 既有 dependency constraint style，目標版本為 4.6.0，`pubspec.lock` 記錄實際 resolved version。
- 產生標準 RFC 9562 UUID v7，不自行實作 UUID 演算法，不改用 UUID v4、SQLite `rowid` 或 timestamp ID。
- Domain／Application 的 Entity ID 保持 `String`，SQLite 保持 `TEXT`；package-specific UUID 型別不得洩漏至 Domain。
- UUID 內含的 timestamp 不得取代 `createdAt` 或其他 business timestamp，也不得依賴 UUID 的 lexical ordering 判定建立順序。
- Phase 1 Slice 1A 不需要 monotonic UUID v7 generator。

## Constraints

- 僅加入已核准的 `uuid` dependency 與解析所需的 lockfile／transitive dependency 變動，不藉此新增 convenience package。
- 保留既有資料庫架構、migration 與其他 Decision Record；不修改 Current Approved Spec。
- UUID generator 對外只提供 `String`，套件 API 留在共用 implementation 邊界內。

## Validation Expectations

驗證實際產生值為有效 RFC 9562 UUID v7、variant 正確、多次產生不重複且對外型別為 `String`；SQLite `TEXT` round-trip 與明確 `createdAt` 分離；既有 migration／重開測試及相關 Flutter 驗證通過。若套件解析、SDK compatibility 或 API 與核准假設不符，停止受影響工作並重新提交 `CHAT_HANDOFF`。
