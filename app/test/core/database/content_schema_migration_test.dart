import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;

  test(
    'production v1 upgrades to v2 and preserves migration history',
    () async {
      final directory = await Directory.systemTemp.createTemp('jlpt_content_');
      addTearDown(() => directory.delete(recursive: true));
      final databasePath = path.join(directory.path, 'content.sqlite3');
      var database = await MigrationRunner([appMigrations.first])
          .open(factory, databasePath);
      expect(await database.getVersion(), 1);
      await database.close();

      database = await MigrationRunner(appMigrations)
          .open(factory, databasePath);
      expect(await database.getVersion(), 2);
      expect(await database.query('schema_migrations'), [
        {'version': 1, 'name': 'initialize_migration_history'},
        {'version': 2, 'name': 'phase_1_content_data'},
      ]);
      expect(
        await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'content_revisions'",
        ),
        hasLength(1),
      );
      await database.close();

      database = await MigrationRunner(appMigrations)
          .open(factory, databasePath);
      expect(await database.query('schema_migrations'), hasLength(2));
      await database.close();
    },
  );

  test('fresh database creates the same latest production schema', () async {
    final directory = await Directory.systemTemp.createTemp('jlpt_content_');
    addTearDown(() => directory.delete(recursive: true));
    final database = await MigrationRunner(appMigrations)
        .open(factory, path.join(directory.path, 'fresh.sqlite3'));
    expect(await database.getVersion(), 2);
    expect(await database.query('schema_migrations'), hasLength(2));
    await database.close();
  });
}
