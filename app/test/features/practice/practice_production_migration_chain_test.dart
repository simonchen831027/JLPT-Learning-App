import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrintSynchronously;
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/database/sqlite_local_store.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/practice/data/sqlite_practice_repository.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_failure.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String databasePath;
  Database? database;
  SqliteLocalStore? store;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_practice_chain_');
    databasePath = path.join(directory.path, 'synthetic.sqlite3');
    debugPrintSynchronously('CHAIN_FIXTURE ${directory.path}');
  });
  tearDown(() async {
    if (store != null) {
      await store!.close();
    } else {
      await database?.close();
    }
    store = null;
    database = null;
    await directory.delete(recursive: true);
    expect(await directory.exists(), isFalse);
    debugPrintSynchronously('CHAIN_RELEASE ${directory.path}');
  });

  Future<Database> openCurrent() async {
    if (store != null) {
      await store!.close();
    } else {
      await database?.close();
    }
    database = null;
    // Same registry/runner/factory as SqliteLocalStore.platform on Windows.
    // Only the path provider is replaced: never open the learner database.
    store = SqliteLocalStore(
      openDatabase: () =>
          MigrationRunner(appMigrations).open(databaseFactoryFfi, databasePath),
    );
    return database = await store!.database;
  }

  Future<Map<String, List<Map<String, Object?>>>> rows(
    Database db, {
    bool includePractice = true,
  }) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name != 'schema_migrations' "
      "ORDER BY name",
    );
    final snapshot = <String, List<Map<String, Object?>>>{};
    for (final table in tables) {
      final name = table['name']! as String;
      if (!includePractice && name.startsWith('quiz_')) continue;
      snapshot[name] = (await db.query(name)).toList()
        ..sort((a, b) => jsonEncode(a).compareTo(jsonEncode(b)));
    }
    return snapshot;
  }

  Future<void> expectCurrent(Database db) async {
    expect(await db.getVersion(), appMigrations.last.version);
    expect(await db.query('schema_migrations', orderBy: 'version'), [
      for (final migration in appMigrations)
        {'version': migration.version, 'name': migration.name},
    ]);
    expect(await db.rawQuery('PRAGMA foreign_keys'), [
      {'foreign_keys': 1},
    ]);
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    expect(await db.rawQuery('PRAGMA integrity_check'), [
      {'integrity_check': 'ok'},
    ]);
    expect(await db.query('app_settings'), [
      {'singleton': 1, 'show_furigana': 1, 'feedback_sound': 1},
    ]);
  }

  Future<PracticeState> saveCurrent(
    SqlitePracticeRepository repository,
    PracticeState state,
  ) async {
    final item = state.currentQuestion;
    final question = item.question;
    final option = item.ordinal == 1
        ? question.options
              .firstWhere((o) => o.id != question.correctOptionId)
              .id
        : question.correctOptionId;
    await repository.submitAnswer(state.session.id, item.id, option);
    return repository.getSession(state.session.id);
  }

  Future<PracticeState> seed(
    SqlitePracticeRepository repository,
    String progress,
  ) async {
    var state = await repository.startOrResume(
      B0ContentIds.lesson,
      QuizMode.practice,
    );
    state = await saveCurrent(repository, state);
    if (progress == 'feedback') return state;
    state = await repository.continueQuestion(
      state.session.id,
      state.currentQuestion.id,
    );
    if (progress == 'continued') return state;
    while (true) {
      state = await saveCurrent(repository, state);
      if (state.session.currentOrdinal == state.questions.length - 1) break;
      state = await repository.continueQuestion(
        state.session.id,
        state.currentQuestion.id,
      );
    }
    return progress == 'completed'
        ? repository.completeSession(state.session.id)
        : state;
  }

  // These are the historical production prefixes at this source checkpoint.
  // No synthetic migration statements or alternate compatibility policy.
  for (final scenario in [
    (version: 0, progress: 'fresh'),
    (version: 1, progress: 'history'),
    (version: 2, progress: 'content'),
    (version: 3, progress: 'feedback'),
    (version: 3, progress: 'continued'),
    (version: 3, progress: 'last-feedback'),
    (version: 3, progress: 'completed'),
  ]) {
    test('production v${scenario.version} to v4 / ${scenario.progress}: '
        'preserves data and completes durable Practice after reopen', () async {
      expect(appMigrations.map((m) => m.version), [1, 2, 3, 4]);
      var before = <String, List<Map<String, Object?>>>{};
      var oldHistory = <Map<String, Object?>>[];
      PracticeState? oldState;
      if (scenario.version > 0) {
        database = await MigrationRunner(
          appMigrations.take(scenario.version).toList(),
        ).open(databaseFactoryFfi, databasePath);
        expect(await database!.getVersion(), scenario.version);
        if (scenario.version >= 2) {
          await const B0ContentPackage(EntityIdGenerator())
              .install(SqliteContentRepository(database!));
        }
        if (scenario.version == 3) {
          oldState = await seed(
            SqlitePracticeRepository(database!),
            scenario.progress,
          );
        }
        before = await rows(database!);
        oldHistory = await database!.query(
          'schema_migrations',
          orderBy: 'version',
        );
      }

      var db = await openCurrent();
      await expectCurrent(db);
      final upgraded = await rows(db);
      for (final entry in before.entries) {
        expect(upgraded[entry.key], entry.value, reason: entry.key);
      }
      final history = await db.query('schema_migrations', orderBy: 'version');
      expect(history.take(oldHistory.length), oldHistory);
      if (scenario.version < 2) {
        await const B0ContentPackage(EntityIdGenerator())
            .install(SqliteContentRepository(db));
      }
      final contentAndSettings = await rows(db, includePractice: false);
      var repository = SqlitePracticeRepository(db);
      if (oldState != null) {
        final restored = await repository.getSession(oldState.session.id);
        expect(
          restored.session.currentOrdinal,
          oldState.session.currentOrdinal,
        );
        expect(restored.currentProgress, oldState.currentProgress);
        expect(restored.session.status, oldState.session.status);
        expect(restored.session.completedAt, oldState.session.completedAt);
        expect(
          restored.questions.map((q) => q.question.revision.id),
          oldState.questions.map((q) => q.question.revision.id),
        );
        if (scenario.progress == 'completed') {
          final historical = await repository.getResult(oldState.session.id);
          expect(historical.answerCount, 3);
          expect(historical.correctCount, 2);
          expect(historical.wrongCount, 1);
        }
      }

      var state = await repository.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      if (oldState != null) {
        expect(
          state.session.id,
          scenario.progress == 'completed'
              ? isNot(oldState.session.id)
              : oldState.session.id,
        );
      }
      final sessionId = state.session.id;
      final contentVersion = state.session.contentVersionId;
      final questionIds = state.questions.map((q) => q.id).toList();
      final revisions = state.questions
          .map((q) => q.question.revision.id)
          .toList();
      while (true) {
        state = await saveCurrent(repository, state);
        final saved = state.answerFor(state.currentQuestion.id)!;
        final ordinal = state.session.currentOrdinal;
        db = await openCurrent();
        repository = SqlitePracticeRepository(db);
        state = await repository.startOrResume(
          B0ContentIds.lesson,
          QuizMode.practice,
        );
        expect(state.session.id, sessionId);
        expect(state.session.contentVersionId, contentVersion);
        expect(state.questions.map((q) => q.id), questionIds);
        expect(state.questions.map((q) => q.question.revision.id), revisions);
        expect(state.session.currentOrdinal, ordinal);
        expect(
          state.currentProgress,
          QuestionProgress.answeredAwaitingContinue,
        );
        expect(state.session.status, QuizSessionStatus.inProgress);
        expect(state.session.completedAt, isNull);
        final recovered = state.answerFor(state.currentQuestion.id)!;
        expect(recovered.id, saved.id);
        expect(recovered.submittedOptionId, saved.submittedOptionId);
        expect(recovered.isCorrect, saved.isCorrect);
        expect(recovered.submittedAt, saved.submittedAt);
        expect(recovered.createdAt, saved.createdAt);
        await expectLater(
          repository.getResult(sessionId),
          throwsA(
            isA<PracticeFailure>().having(
              (e) => e.reason,
              'reason',
              PracticeFailureReason.incompleteSession,
            ),
          ),
        );
        if (ordinal == state.questions.length - 1) break;
        await repository.continueQuestion(sessionId, state.currentQuestion.id);
        db = await openCurrent();
        repository = SqlitePracticeRepository(db);
        state = await repository.startOrResume(
          B0ContentIds.lesson,
          QuizMode.practice,
        );
        expect(state.session.id, sessionId);
        expect(state.session.currentOrdinal, ordinal + 1);
        expect(state.progressFor(ordinal), QuestionProgress.continued);
        expect(state.currentProgress, QuestionProgress.awaitingAnswer);
        expect(state.answers.length, ordinal + 1);
      }

      final answerIds = state.answers.map((a) => a.id).toList();
      final completed = await repository.completeSession(sessionId);
      expect(completed.session.status, QuizSessionStatus.completed);
      expect(completed.session.completedAt, isNotNull);
      db = await openCurrent();
      repository = SqlitePracticeRepository(db);
      final result = await repository.getResult(sessionId);
      expect(result.answerCount, 3);
      expect(result.correctCount, 2);
      expect(result.wrongCount, 1);
      expect(result.state.answers.map((a) => a.id), answerIds);
      expect(result.state.questions.map((q) => q.id), questionIds);
      expect(result.state.session.contentVersionId, contentVersion);
      expect(
        (await repository.completeSession(sessionId)).session.completedAt,
        completed.session.completedAt,
      );
      await expectCurrent(db);
      expect(await rows(db, includePractice: false), contentAndSettings);
    });
  }
}
