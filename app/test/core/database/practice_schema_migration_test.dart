import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/practice_fixture.dart';

void main() {
  late PracticeFixture fixture;
  const ids = EntityIdGenerator();
  tearDown(() => fixture.dispose());

  test(
    'v2 B0 upgrade to v3 preserves all content and reopens with FK integrity',
    () async {
      fixture = await PracticeFixture.create(version: 2);
      final before = await fixture.contentRows();
      expect(await fixture.database.getVersion(), 2);
      await fixture.reopen();
      expect(await fixture.database.getVersion(), 3);
      expect(await fixture.contentRows(), before);
      expect(await fixture.database.query('schema_migrations'), [
        {'version': 1, 'name': 'initialize_migration_history'},
        {'version': 2, 'name': 'phase_1_content_data'},
        {'version': 3, 'name': 'phase_1_practice_user_state'},
      ]);
      final state = await fixture.practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      await fixture.reopen();
      final resumed = await fixture.practice.getSession(state.session.id);
      expect(
        resumed.questions.map((q) => q.question.revision.id),
        state.questions.map((q) => q.question.revision.id),
      );
      expect(
        await fixture.database.rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );
    },
  );

  test(
    'fresh v3 required columns, UTC instants and semantic nullable completion',
    () async {
      fixture = await PracticeFixture.create();
      expect(await fixture.database.getVersion(), 3);
      final required = {
        'quiz_sessions': [
          'id',
          'context_content_id',
          'mode',
          'status',
          'content_version_id',
          'question_count',
          'current_ordinal',
          'created_at',
          'started_at',
        ],
        'quiz_session_questions': [
          'id',
          'session_id',
          'question_revision_id',
          'ordinal',
        ],
        'quiz_answers': [
          'id',
          'session_id',
          'session_question_id',
          'question_revision_id',
          'submitted_option_id',
          'is_correct',
          'submitted_at',
          'created_at',
        ],
      };
      for (final entry in required.entries) {
        final info = await fixture.database.rawQuery(
          'PRAGMA table_info(${entry.key})',
        );
        for (final name in entry.value) {
          expect(
            info.singleWhere((row) => row['name'] == name)['notnull'],
            1,
            reason: '${entry.key}.$name',
          );
        }
      }
      final sessionInfo = await fixture.database.rawQuery(
        'PRAGMA table_info(quiz_sessions)',
      );
      expect(
        sessionInfo.singleWhere(
          (row) => row['name'] == 'completed_at',
        )['notnull'],
        0,
      );
      final state = await fixture.practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      final original = (await fixture.database.query('quiz_sessions')).single;
      for (final change in [
        {'mode': 'mock_exam'},
        {'status': 'failed'},
        {'status': 'abandoned'},
        {'completed_at': fixture.now.toIso8601String()},
        {'created_at': 'not-an-instant'},
        {'started_at': '2026-10-01T01:00:00'},
      ]) {
        await expectLater(
          fixture.database.insert('quiz_sessions', {
            ...original,
            'id': ids.generate(),
            ...change,
          }),
          throwsA(isA<DatabaseException>()),
        );
      }
      await expectLater(
        fixture.database.update(
          'quiz_sessions',
          {
            'status': 'completed',
            'completed_at': fixture.now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [state.session.id],
        ),
        throwsA(isA<DatabaseException>()),
      );
      expect(
        (await fixture.practice.getSession(state.session.id))
            .session
            .completedAt,
        isNull,
      );
    },
  );

  test(
    'SQLite prevents duplicate active sessions and rewriting frozen snapshot',
    () async {
      fixture = await PracticeFixture.create();
      final state = await fixture.practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      final original = (await fixture.database.query('quiz_sessions')).single;
      await expectLater(
        fixture.database.insert('quiz_sessions', {
          ...original,
          'id': ids.generate(),
        }),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        fixture.database.update(
          'quiz_sessions',
          {'current_ordinal': 1},
          where: 'id = ?',
          whereArgs: [state.session.id],
        ),
        throwsA(isA<DatabaseException>()),
      );
      for (final change in [
        {'content_version_id': B0ContentIds.previousVersion},
        {'question_count': 4},
        {'mode': 'review'},
      ]) {
        await expectLater(
          fixture.database.update(
            'quiz_sessions',
            change,
            where: 'id = ?',
            whereArgs: [state.session.id],
          ),
          throwsA(isA<DatabaseException>()),
        );
      }
      await expectLater(
        fixture.database.update(
          'quiz_session_questions',
          {'ordinal': 2},
          where: 'id = ?',
          whereArgs: [state.currentQuestion.id],
        ),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        fixture.database.delete(
          'quiz_session_questions',
          where: 'id = ?',
          whereArgs: [state.currentQuestion.id],
        ),
        throwsA(isA<DatabaseException>()),
      );
      final snapshot = (await fixture.database.query('quiz_session_questions'))
          .first;
      await expectLater(
        fixture.database.insert('quiz_session_questions', {
          ...snapshot,
          'id': ids.generate(),
          'ordinal': 3,
        }),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  test(
    'SQLite guards exact revision/option, correctness, unique immutable answer',
    () async {
      fixture = await PracticeFixture.create();
      final state = await fixture.practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      final first = state.currentQuestion;
      final valid = {
        'id': ids.generate(),
        'session_id': state.session.id,
        'session_question_id': first.id,
        'question_revision_id': first.question.revision.id,
        'submitted_option_id': first.question.correctOptionId,
        'is_correct': 1,
        'submitted_at': fixture.now.toIso8601String(),
        'created_at': fixture.now.toIso8601String(),
      };
      for (final change in [
        {'question_revision_id': state.questions[1].question.revision.id},
        {
          'submitted_option_id': state.questions[1].question.options.first.id,
          'is_correct': 0,
        },
        {'is_correct': 0},
        {'submitted_at': null},
        {'is_correct': 2},
      ]) {
        await expectLater(
          fixture.database.insert('quiz_answers', {
            ...valid,
            'id': ids.generate(),
            ...change,
          }),
          throwsA(isA<DatabaseException>()),
        );
      }
      final saved = await fixture.practice.submitAnswer(
        state.session.id,
        first.id,
        first.question.correctOptionId,
      );
      await expectLater(
        fixture.database.insert('quiz_answers', {
          ...valid,
          'id': ids.generate(),
        }),
        throwsA(isA<DatabaseException>()),
      );
      for (final change in [
        {'submitted_option_id': first.question.options[1].id},
        {'is_correct': 0},
        {
          'submitted_at': fixture.now
              .add(const Duration(days: 1))
              .toIso8601String(),
        },
      ]) {
        await expectLater(
          fixture.database.update(
            'quiz_answers',
            change,
            where: 'id = ?',
            whereArgs: [saved.id],
          ),
          throwsA(isA<DatabaseException>()),
        );
      }
      await expectLater(
        fixture.database.delete(
          'quiz_answers',
          where: 'id = ?',
          whereArgs: [saved.id],
        ),
        throwsA(isA<DatabaseException>()),
      );
      expect(
        await fixture.database.rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );
      expect(
        (await fixture.database.query('quiz_answers')).single['id'],
        saved.id,
      );
    },
  );

  test(
    'completedAt cannot be rewritten; Reset session cascade preserves Content',
    () async {
      fixture = await PracticeFixture.create();
      final before = await fixture.contentRows();
      var state = await fixture.practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      for (var i = 0; i < 3; i++) {
        await fixture.practice.submitAnswer(
          state.session.id,
          state.currentQuestion.id,
          state.currentQuestion.question.correctOptionId,
        );
        if (i < 2) {
          state = await fixture.practice.continueQuestion(
            state.session.id,
            state.currentQuestion.id,
          );
        }
      }
      state = await fixture.practice.completeSession(state.session.id);
      await expectLater(
        fixture.database.update(
          'quiz_sessions',
          {
            'completed_at': fixture.now
                .add(const Duration(days: 1))
                .toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [state.session.id],
        ),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        fixture.database.update(
          'quiz_sessions',
          {'status': 'in_progress', 'completed_at': null},
          where: 'id = ?',
          whereArgs: [state.session.id],
        ),
        throwsA(isA<DatabaseException>()),
      );
      // No production Reset path exists yet. Verify the future data-layer
      // deletion order: parent session -> snapshot -> answers in a transaction.
      await fixture.database.transaction((tx) async {
        await tx.delete('quiz_sessions');
      });
      expect(await fixture.database.query('quiz_sessions'), isEmpty);
      expect(await fixture.database.query('quiz_session_questions'), isEmpty);
      expect(await fixture.database.query('quiz_answers'), isEmpty);
      expect(await fixture.contentRows(), before);
      expect(
        await fixture.database.rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );
      await fixture.reopen();
      expect(await fixture.contentRows(), before);
    },
  );
}
