# DEC-P1-004 — Core Data Conventions

- Decision ID：`DEC-P1-004`
- Status：`APPROVED`
- 核准來源：Developer 於 V2.5 Candidate Review Fix 明確確認
- 適用範圍：Phase 1 Entity ID、時間與 nullable／migration 資料慣例；V2.5 Candidate §7.4.2、§38.11、§42.1

## Decision

### Entity ID

- Entity ID 使用 UUID v7。
- Domain / Application 使用 `String`；SQLite 使用 `TEXT`。
- ID 不依賴 SQLite `rowid`。
- UUID 內含的時間資訊不可取代 `createdAt`。

### Time

- Persisted instant 使用 UTC。
- SQLite 以 ISO-8601 UTC 儲存 persisted instant。
- UI 顯示時轉換為 local timezone。
- Date-only 與 timestamp 分離。

### Nullable 與 migration

- Nullable 僅用於語意真正允許不存在的值。
- Required invariant 使用 `NOT NULL`。
- 不以 `null` 表示 `false`、`0` 或 empty collection。
- `unavailable`、`unknown`、`not-applicable` 優先使用明確 status。
- Required migration field 必須有 backfill / default strategy。
