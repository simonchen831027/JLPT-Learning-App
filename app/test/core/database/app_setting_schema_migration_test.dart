import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/practice_fixture.dart';

void main() {
  sqfliteFfiInit();

  Future<Database> freshDatabase() async {
    final directory = await Directory.systemTemp.createTemp('jlpt_settings_');
    addTearDown(() => directory.delete(recursive: true));
    final database = await MigrationRunner(
      appMigrations,
    ).open(databaseFactoryFfi, path.join(directory.path, 'settings.sqlite3'));
    addTearDown(database.close);
    return database;
  }

  test(
    'fresh v4 stores both ON defaults with complete migration history',
    () async {
      final database = await freshDatabase();
      expect(await database.getVersion(), 4);
      expect(await database.query('app_settings'), [
        {'singleton': 1, 'show_furigana': 1, 'feedback_sound': 1},
      ]);
      expect(await database.query('schema_migrations', orderBy: 'version'), [
        {'version': 1, 'name': 'initialize_migration_history'},
        {'version': 2, 'name': 'phase_1_content_data'},
        {'version': 3, 'name': 'phase_1_practice_user_state'},
        {'version': 4, 'name': 'phase_1_app_settings'},
      ]);
      expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  test(
    'v3 to v4 preserves B0 Content, sessions, snapshots and answers',
    () async {
      final fixture = await PracticeFixture.create(version: 3);
      addTearDown(fixture.dispose);
      var state = await fixture.practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      final answer = await fixture.practice.submitAnswer(
        state.session.id,
        state.currentQuestion.id,
        state.currentQuestion.question.correctOptionId,
      );
      state = await fixture.practice.continueQuestion(
        state.session.id,
        state.currentQuestion.id,
      );
      final contentBefore = await fixture.contentRows();
      final practiceBefore = {
        for (final table in [
          'quiz_sessions',
          'quiz_session_questions',
          'quiz_answers',
        ])
          table: await fixture.database.query(table, orderBy: 'id'),
      };
      final historyBefore = await fixture.database.query(
        'schema_migrations',
        orderBy: 'version',
      );

      await fixture.reopen(version: 4);
      expect(await fixture.database.getVersion(), 4);
      for (final entry in contentBefore.entries) {
        expect(
          await fixture.database.query(entry.key),
          entry.value,
          reason: 'Content preserved: ${entry.key}',
        );
      }
      for (final entry in practiceBefore.entries) {
        expect(
          await fixture.database.query(entry.key, orderBy: 'id'),
          entry.value,
          reason: 'Practice preserved: ${entry.key}',
        );
      }
      expect(
        await fixture.database.query('schema_migrations', orderBy: 'version'),
        [
          ...historyBefore,
          {'version': 4, 'name': 'phase_1_app_settings'},
        ],
      );
      expect(await fixture.database.query('app_settings'), [
        {'singleton': 1, 'show_furigana': 1, 'feedback_sound': 1},
      ]);
      final resumed = await fixture.practice.getSession(state.session.id);
      expect(resumed.currentQuestion.id, state.currentQuestion.id);
      expect(resumed.answers.single.id, answer.id);
      expect(resumed.currentProgress, QuestionProgress.awaitingAnswer);
      expect(
        await fixture.database.rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );

      await fixture.reopen(version: 4);
      expect(await fixture.database.query('schema_migrations'), hasLength(4));
      expect(await fixture.database.query('app_settings'), hasLength(1));
      expect(
        (await fixture.practice.getSession(state.session.id)).answers.single.id,
        answer.id,
      );
    },
  );

  test(
    'SQLite rejects null and invalid booleans and additional settings rows',
    () async {
      final database = await freshDatabase();
      final info = await database.rawQuery('PRAGMA table_info(app_settings)');
      for (final column in ['show_furigana', 'feedback_sound']) {
        final metadata = info.singleWhere((row) => row['name'] == column);
        expect(metadata['notnull'], 1);
        expect(metadata['dflt_value'], '1');
        for (final invalid in [null, -1, 2, 0.5, 'on']) {
          await expectLater(
            database.update('app_settings', {column: invalid}),
            throwsA(isA<DatabaseException>()),
            reason: '$column rejects $invalid',
          );
        }
      }
      await expectLater(
        database.insert('app_settings', {'singleton': 2}),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        database.insert('app_settings', {'singleton': 1}),
        throwsA(isA<DatabaseException>()),
      );
      expect(await database.query('app_settings'), [
        {'singleton': 1, 'show_furigana': 1, 'feedback_sound': 1},
      ]);
      expect(
        await database.rawQuery('PRAGMA foreign_key_list(app_settings)'),
        isEmpty,
      );
    },
  );

  test(
    'Practice parent deletion leaves AppSetting preferences and Content intact',
    () async {
      final fixture = await PracticeFixture.create(version: 4);
      addTearDown(fixture.dispose);
      await fixture.database.update('app_settings', {
        'show_furigana': 0,
        'feedback_sound': 0,
      });
      final state = await fixture.practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      await fixture.practice.submitAnswer(
        state.session.id,
        state.currentQuestion.id,
        state.currentQuestion.question.correctOptionId,
      );
      final before = await fixture.contentRows();
      // 僅驗證儲存生命週期分離；未建立 production Reset 流程。
      await fixture.database.transaction((tx) => tx.delete('quiz_sessions'));
      expect(await fixture.database.query('quiz_sessions'), isEmpty);
      expect(await fixture.database.query('quiz_session_questions'), isEmpty);
      expect(await fixture.database.query('quiz_answers'), isEmpty);
      expect(await fixture.contentRows(), before);
      expect(await fixture.database.query('app_settings'), [
        {'singleton': 1, 'show_furigana': 0, 'feedback_sound': 0},
      ]);
      expect(
        await fixture.database.rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );
    },
  );
}
