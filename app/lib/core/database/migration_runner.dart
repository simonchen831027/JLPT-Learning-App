import 'package:sqflite_common/sqlite_api.dart';

import 'schema_migration.dart';

class MigrationRunner {
  MigrationRunner(List<SchemaMigration> migrations)
    : migrations = List.unmodifiable(migrations) {
    if (migrations.isEmpty) {
      throw ArgumentError('Migration list must not be empty.');
    }
    for (var index = 0; index < migrations.length; index++) {
      if (migrations[index].version != index + 1 ||
          migrations[index].name.isEmpty ||
          migrations[index].statements.isEmpty) {
        throw ArgumentError(
          'Migrations must be nonempty and consecutive from 1.',
        );
      }
    }
  }
  final List<SchemaMigration> migrations;
  int get version => migrations.last.version;

  Future<Database> open(DatabaseFactory factory, String path) {
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        singleInstance: false,
        onConfigure: (database) => database.execute('PRAGMA foreign_keys = ON'),
        onCreate: (database, target) => _upgrade(database, 0, target),
        onUpgrade: _upgrade,
        onDowngrade: (database, previous, target) async {
          throw StateError('Database downgrade is not supported.');
        },
        onOpen: (database) => _verifyHistory(database, version),
      ),
    );
  }

  Future<void> _upgrade(Database database, int previous, int target) async {
    if (previous > 0) await _verifyHistory(database, previous);
    // sqflite 的 onCreate/onUpgrade 已在同一 transaction 內。
    // 失敗向外拋出，讓 DDL、history 與 user_version 一起回滾。
    for (final migration in migrations.skip(previous).take(target - previous)) {
      for (final statement in migration.statements) {
        await database.execute(statement);
      }
      await database.insert('schema_migrations', {
        'version': migration.version,
        'name': migration.name,
      });
    }
  }

  Future<void> _verifyHistory(Database database, int expectedVersion) async {
    final rows = await database.query('schema_migrations', orderBy: 'version');
    if (rows.length != expectedVersion) {
      throw StateError('Database migration history is inconsistent.');
    }
    for (var index = 0; index < rows.length; index++) {
      if (rows[index]['version'] != migrations[index].version ||
          rows[index]['name'] != migrations[index].name) {
        throw StateError('Database migration history is inconsistent.');
      }
    }
  }
}
