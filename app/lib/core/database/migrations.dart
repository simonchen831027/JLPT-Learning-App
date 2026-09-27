import 'schema_migration.dart';

// 已發布的 migration 不可改寫；後續 schema 以連續版本附加。
final appMigrations = List<SchemaMigration>.unmodifiable([
  SchemaMigration(
    version: 1,
    name: 'initialize_migration_history',
    statements: [
      '''CREATE TABLE schema_migrations (
        version INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )''',
    ],
  ),
]);
