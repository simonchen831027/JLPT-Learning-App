import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/database/schema_migration.dart';

void main() {
  late Directory directory;
  late String databasePath;
  final factory = databaseFactoryFfi;
  sqfliteFfiInit();
  final baseMigrations = [appMigrations.first];

  final fixtureV2 = SchemaMigration(
    version: 2,
    name: 'test_fixtures',
    statements: [
      'CREATE TABLE content_fixture (id INTEGER PRIMARY KEY, title TEXT NOT NULL)',
      'CREATE TABLE state_fixture (id INTEGER PRIMARY KEY, content_id INTEGER NOT NULL REFERENCES content_fixture(id))',
      'CREATE TABLE analytics_fixture (id INTEGER PRIMARY KEY, value INTEGER NOT NULL)',
    ],
  );
  final fixtureV3 = SchemaMigration(
    version: 3,
    name: 'test_add_column',
    statements: ['ALTER TABLE content_fixture ADD COLUMN note TEXT'],
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_migration_test_');
    databasePath = path.join(directory.path, 'test.sqlite3');
  });
  tearDown(() => directory.delete(recursive: true));

  Future<Database> open(List<SchemaMigration> migrations) =>
      MigrationRunner(migrations).open(factory, databasePath);

  test(
    'fresh database and repeated open retain one migration record',
    () async {
      var database = await open(appMigrations);
      expect(await database.getVersion(), 2);
      expect(await database.query('schema_migrations'), [
        {'version': 1, 'name': 'initialize_migration_history'},
        {'version': 2, 'name': 'phase_1_content_data'},
      ]);
      expect(await database.rawQuery('PRAGMA foreign_keys'), [
        {'foreign_keys': 1},
      ]);
      await database.close();
      database = await open(appMigrations);
      expect(await database.query('schema_migrations'), hasLength(2));
      await database.close();
    },
  );

  test('upgrade preserves content, user state and derived fixtures', () async {
    var database = await open([...baseMigrations, fixtureV2]);
    await database.insert('content_fixture', {'id': 1, 'title': 'fixture'});
    await database.insert('state_fixture', {'id': 1, 'content_id': 1});
    await database.insert('analytics_fixture', {'id': 1, 'value': 7});
    await database.close();
    database = await open([...baseMigrations, fixtureV2, fixtureV3]);
    expect(await database.getVersion(), 3);
    expect(await database.query('content_fixture'), [
      {'id': 1, 'title': 'fixture', 'note': null},
    ]);
    expect(await database.query('state_fixture'), [
      {'id': 1, 'content_id': 1},
    ]);
    expect(await database.query('analytics_fixture'), [
      {'id': 1, 'value': 7},
    ]);
    await expectLater(
      database.insert('state_fixture', {'id': 2, 'content_id': 999}),
      throwsA(isA<DatabaseException>()),
    );
    await database.close();
  });

  test(
    'failed multi-version upgrade rolls back DDL, rows, history and version',
    () async {
      var database = await open([...baseMigrations, fixtureV2]);
      await database.insert('content_fixture', {'id': 1, 'title': 'keep'});
      await database.close();
      final invalidV4 = SchemaMigration(
        version: 4,
        name: 'test_failure',
        statements: [
          "UPDATE content_fixture SET title = 'changed'",
          'CREATE TABLE should_rollback (id INTEGER PRIMARY KEY)',
          'INSERT INTO missing_table VALUES (1)',
        ],
      );
      await expectLater(
        open([...baseMigrations, fixtureV2, fixtureV3, invalidV4]),
        throwsA(anything),
      );
      database = await open([...baseMigrations, fixtureV2]);
      expect(await database.getVersion(), 2);
      expect(await database.query('content_fixture'), [
        {'id': 1, 'title': 'keep'},
      ]);
      expect(await database.query('schema_migrations'), hasLength(2));
      expect(
        await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE name = 'should_rollback'",
        ),
        isEmpty,
      );
      await database.close();
    },
  );

  test('downgrade is rejected without erasing data', () async {
    var database = await open([...baseMigrations, fixtureV2]);
    await database.insert('content_fixture', {'id': 1, 'title': 'keep'});
    await database.close();
    await expectLater(open(baseMigrations), throwsA(anything));
    database = await open([...baseMigrations, fixtureV2]);
    expect(await database.getVersion(), 2);
    expect(await database.query('content_fixture'), [
      {'id': 1, 'title': 'keep'},
    ]);
    await database.close();
  });

  test('inconsistent history prevents further migration', () async {
    var database = await open(baseMigrations);
    await database.update('schema_migrations', {'name': 'unexpected'});
    await database.close();
    await expectLater(open([...baseMigrations, fixtureV2]), throwsA(anything));
    database = await factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    expect(await database.getVersion(), 1);
    expect(
      await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE name = 'content_fixture'",
      ),
      isEmpty,
    );
    await database.close();
  });

  test('invalid migration numbering is rejected before opening storage', () {
    expect(() => MigrationRunner([]), throwsArgumentError);
    expect(() => MigrationRunner([fixtureV2]), throwsArgumentError);
    expect(
      () => MigrationRunner([...baseMigrations, fixtureV3]),
      throwsArgumentError,
    );
    expect(
      () => MigrationRunner([...baseMigrations, ...baseMigrations]),
      throwsArgumentError,
    );
  });
}
