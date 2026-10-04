import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/database/sqlite_local_store.dart';
import 'package:jlpt_learning_app/features/settings/data/sqlite_app_setting_repository.dart';
import 'package:jlpt_learning_app/features/settings/domain/app_setting_repository.dart';
import 'package:jlpt_learning_app/features/settings/domain/app_setting_use_cases.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late SqliteLocalStore store;
  late Database database;
  late AppSettingRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_setting_boundary_');
    store = SqliteLocalStore(
      openDatabase: () => MigrationRunner(
        appMigrations,
      ).open(databaseFactoryFfi, path.join(directory.path, 'settings.sqlite3')),
    );
    database = await store.database;
    repository = SqliteAppSettingRepository(database);
  });
  tearDown(() async {
    await store.close();
    await directory.delete(recursive: true);
  });

  Future<void> expectSettings(bool furigana, bool sound) async {
    final settings = await GetAppSettings(repository)();
    expect(settings.showFurigana, furigana);
    expect(settings.feedbackSound, sound);
  }

  test(
    'public use cases read defaults and update each preference independently',
    () async {
      await expectSettings(true, true);
      await SetShowFurigana(repository)(false);
      await expectSettings(false, true);
      await SetFeedbackSound(repository)(false);
      await expectSettings(false, false);
      await SetShowFurigana(repository)(true);
      await expectSettings(true, false);
      await SetFeedbackSound(repository)(true);
      await expectSettings(true, true);
      // 重複設定同一值可成功；不新增額外資料列。
      await SetFeedbackSound(repository)(true);
      expect(await database.query('app_settings'), hasLength(1));
    },
  );

  test(
    'both OFF preferences survive storage close and repository recreation',
    () async {
      await SetShowFurigana(repository)(false);
      await SetFeedbackSound(repository)(false);
      await store.close();
      database = await store.database;
      repository = SqliteAppSettingRepository(database);
      await expectSettings(false, false);
      await SetShowFurigana(repository)(true);
      await store.close();
      database = await store.database;
      repository = SqliteAppSettingRepository(database);
      await expectSettings(true, false);
    },
  );

  test(
    'separate repository instances do not overwrite the other preference',
    () async {
      final other = SqliteAppSettingRepository(database);
      await Future.wait([
        SetShowFurigana(repository)(false),
        SetFeedbackSound(other)(false),
      ]);
      await expectSettings(false, false);
    },
  );

  test(
    'failed write propagates through use case and retains stored settings',
    () async {
      await database.execute(
        'CREATE TRIGGER test_fail_setting BEFORE UPDATE ON app_settings '
        "BEGIN SELECT RAISE(ABORT, 'synthetic settings write failure'); END",
      );
      await expectLater(
        SetShowFurigana(repository)(false),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        SetFeedbackSound(repository)(false),
        throwsA(isA<DatabaseException>()),
      );
      await expectSettings(true, true);
      await database.execute('DROP TRIGGER test_fail_setting');
      await SetFeedbackSound(repository)(false);
      await expectSettings(true, false);
    },
  );

  test(
    'missing settings row cannot be reported as defaults or successful write',
    () async {
      await database.delete('app_settings');
      await expectLater(GetAppSettings(repository)(), throwsStateError);
      await expectLater(SetShowFurigana(repository)(false), throwsStateError);
      await expectLater(SetFeedbackSound(repository)(false), throwsStateError);
    },
  );
}
