import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/database/persistence_values.dart';
import 'package:jlpt_learning_app/core/database/schema_migration.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  final fixtureV2 = SchemaMigration(
    version: 2,
    name: 'persistence_convention_fixture',
    statements: [
      '''CREATE TABLE persistence_fixture (
        id TEXT PRIMARY KEY NOT NULL,
        created_at TEXT NOT NULL,
        study_date TEXT NOT NULL,
        is_complete INTEGER NOT NULL DEFAULT 0 CHECK (is_complete IN (0, 1)),
        attempt_count INTEGER NOT NULL DEFAULT 0,
        items_json TEXT NOT NULL DEFAULT '[]'
      ) WITHOUT ROWID''',
    ],
  );
  final fixtureV3 = SchemaMigration(
    version: 3,
    name: 'backfill_required_fixture_field',
    statements: [
      "ALTER TABLE persistence_fixture ADD COLUMN source TEXT NOT NULL DEFAULT 'legacy'",
    ],
  );

  test('UTC instants and date-only values keep separate semantics', () {
    final instant = DateTime.parse('2025-01-02T03:04:05.123456+09:00');
    final stored = PersistenceValues.encodeInstant(instant);
    expect(stored, '2025-01-01T18:04:05.123456Z');
    final restored = PersistenceValues.decodeInstant(stored);
    expect(restored.isUtc, isTrue);
    expect(restored.isAtSameMomentAs(instant), isTrue);
    expect(
      () => PersistenceValues.decodeInstant('2025-01-01T18:04:05+00:00'),
      throwsFormatException,
    );

    expect(PersistenceValues.dateOnly('2024-02-29'), '2024-02-29');
    expect(
      () => PersistenceValues.dateOnly('2025-02-29'),
      throwsFormatException,
    );
    expect(
      () => PersistenceValues.dateOnly('2025-01-01T00:00:00Z'),
      throwsFormatException,
    );
  });

  test(
    'versioned upgrade preserves explicit values and backfills required data',
    () async {
      final uuidV7 = const EntityIdGenerator().generate();
      final directory = await Directory.systemTemp.createTemp(
        'jlpt_persistence_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final databasePath = path.join(directory.path, 'fixture.sqlite3');
      final factory = databaseFactoryFfi;

      Future<Database> open(List<SchemaMigration> migrations) =>
          MigrationRunner(migrations).open(factory, databasePath);

      var database = await open([...appMigrations, fixtureV2]);
      const createdAt = '2024-03-01T12:34:56.000Z';
      await database.insert('persistence_fixture', {
        'id': uuidV7,
        'created_at': createdAt,
        'study_date': PersistenceValues.dateOnly('2024-02-29'),
        'is_complete': 0,
        'attempt_count': 0,
        'items_json': '[]',
      });
      await expectLater(
        database.insert('persistence_fixture', {
          'id': const EntityIdGenerator().generate(),
          'created_at': null,
          'study_date': '2024-02-29',
        }),
        throwsA(isA<DatabaseException>()),
      );
      await database.close();

      database = await open([...appMigrations, fixtureV2, fixtureV3]);
      expect(await database.getVersion(), 3);
      final rows = await database.query('persistence_fixture');
      expect(rows, hasLength(1));
      final row = rows.single;
      expect(row['id'], uuidV7);
      expect(row['id'], isA<String>());
      expect(row['created_at'], createdAt);
      expect(
        PersistenceValues.decodeInstant(row['created_at']! as String).isUtc,
        isTrue,
      );
      expect(row['study_date'], '2024-02-29');
      expect(row['is_complete'], 0);
      expect(row['attempt_count'], 0);
      expect(row['items_json'], '[]');
      expect(row['source'], 'legacy');
      await expectLater(
        database.rawQuery('SELECT rowid FROM persistence_fixture'),
        throwsA(isA<DatabaseException>()),
      );
      await database.close();

      database = await open([...appMigrations, fixtureV2, fixtureV3]);
      expect(await database.query('persistence_fixture'), rows);
      await database.close();
    },
  );
}
