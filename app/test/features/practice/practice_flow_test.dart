import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/practice/data/sqlite_practice_repository.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_failure.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_use_cases.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/practice_fixture.dart';

void main() {
  late PracticeFixture fixture;
  setUp(() async => fixture = await PracticeFixture.create());
  tearDown(() => fixture.dispose());

  Future<PracticeState> start({QuizMode mode = QuizMode.practice}) =>
      StartOrResumePractice(fixture.practice)(B0ContentIds.lesson, mode: mode);

  Future<QuizAnswer> answer(PracticeState state, {bool correct = true}) {
    final item = state.currentQuestion;
    final option = correct
        ? item.question.correctOptionId
        : item.question.options
              .firstWhere((o) => o.id != item.question.correctOptionId)
              .id;
    return SubmitPracticeAnswer(fixture.practice)(
      state.session.id,
      item.id,
      option,
    );
  }

  Future<PracticeState> finishAnswers(PracticeState state) async {
    for (
      var index = state.session.currentOrdinal;
      index < state.questions.length;
      index++
    ) {
      await answer(state, correct: index != 1);
      state = await GetPracticeSession(fixture.practice)(state.session.id);
      if (index < state.questions.length - 1) {
        state = await ContinuePractice(fixture.practice)(
          state.session.id,
          state.currentQuestion.id,
        );
      }
    }
    return state;
  }

  Matcher failure(PracticeFailureReason reason) =>
      throwsA(isA<PracticeFailure>().having((e) => e.reason, 'reason', reason));

  test(
    'B0 non-UI Use Case loop freezes three questions and rebuilds Result',
    () async {
      final originalContent = await fixture.contentRows();
      var state = await start();
      expect(state.session.contentVersionId, B0ContentIds.version);
      expect(state.questions.map((q) => q.ordinal), [0, 1, 2]);
      expect(
        state.questions.map((q) => q.question.revision.contentId),
        B0ContentIds.questions,
      );
      expect(
        state.session.id,
        matches(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      );
      expect(state.session.createdAt, fixture.now);
      expect(state.session.startedAt.isUtc, isTrue);
      expect(state.session.completedAt, isNull);
      expect(state.currentProgress, QuestionProgress.awaitingAnswer);
      expect(state.progressFor(1), isNull);
      state = await finishAnswers(state);
      expect(state.currentProgress, QuestionProgress.answeredAwaitingContinue);
      expect(state.session.status, QuizSessionStatus.inProgress);
      await expectLater(
        GetPracticeResult(fixture.practice)(state.session.id),
        failure(PracticeFailureReason.incompleteSession),
      );
      state = await CompletePracticeSession(fixture.practice)(state.session.id);
      expect(state.session.status, QuizSessionStatus.completed);
      final completedAt = state.session.completedAt;
      fixture.now = fixture.now.add(const Duration(days: 1));
      final retry = await CompletePracticeSession(fixture.practice)(
        state.session.id,
      );
      expect(retry.session.completedAt, completedAt);
      await fixture.reopen();
      final result = await GetPracticeResult(fixture.practice)(
        state.session.id,
      );
      expect(result.answerCount, 3);
      expect(result.correctCount, 2);
      expect(result.wrongCount, 1);
      expect(result.state.answers.map((answer) => answer.isCorrect), [
        true,
        false,
        true,
      ]);
      expect(
        result.state.questions.map((q) => q.question.revision.id),
        state.questions.map((q) => q.question.revision.id),
      );
      expect(
        result.state.answers.map((a) => a.id).toSet(),
        state.answers.map((a) => a.id).toSet(),
      );
      expect(await fixture.contentRows(), originalContent);
      expect(
        await fixture.database.rawQuery(
          "SELECT name FROM sqlite_master WHERE name = 'quiz_results'",
        ),
        isEmpty,
      );
    },
  );

  test(
    'empty and invalid selection never create attempts or progress',
    () async {
      final state = await start();
      final submit = SubmitPracticeAnswer(fixture.practice);
      for (final option in [null, '']) {
        await expectLater(
          submit(state.session.id, state.currentQuestion.id, option),
          failure(PracticeFailureReason.missingSelection),
        );
        await expectLater(
          fixture.practice.submitAnswer(
            state.session.id,
            state.currentQuestion.id,
            option,
          ),
          failure(PracticeFailureReason.missingSelection),
        );
      }
      await expectLater(
        submit(
          state.session.id,
          state.currentQuestion.id,
          state.questions[1].question.options.first.id,
        ),
        failure(PracticeFailureReason.invalidSelection),
      );
      expect(await fixture.database.query('quiz_answers'), isEmpty);
      expect((await start()).currentProgress, QuestionProgress.awaitingAnswer);
      await expectLater(
        ContinuePractice(fixture.practice)(
          state.session.id,
          state.currentQuestion.id,
        ),
        failure(PracticeFailureReason.incompleteSession),
      );
      await expectLater(
        CompletePracticeSession(fixture.practice)(state.session.id),
        failure(PracticeFailureReason.incompleteSession),
      );
      await expectLater(
        submit(
          state.session.id,
          state.questions[1].id,
          state.questions[1].question.correctOptionId,
        ),
        failure(PracticeFailureReason.outOfOrder),
      );
    },
  );

  test('same-option Submit is idempotent, changed option conflicts', () async {
    var state = await start();
    final submitted = await answer(state);
    fixture.now = fixture.now.add(const Duration(hours: 1));
    final retry = await answer(state);
    expect(retry.id, submitted.id);
    expect(retry.submittedAt, submitted.submittedAt);
    expect(retry.createdAt, submitted.createdAt);
    await expectLater(
      answer(state, correct: false),
      failure(PracticeFailureReason.conflictingAnswer),
    );
    expect(await fixture.database.query('quiz_answers'), hasLength(1));
    final firstQuestion = state.currentQuestion;
    state = await ContinuePractice(fixture.practice)(
      state.session.id,
      firstQuestion.id,
    );
    final retriedContinue = await ContinuePractice(fixture.practice)(
      state.session.id,
      firstQuestion.id,
    );
    expect(retriedContinue.session.currentOrdinal, 1);
    expect(
      (await SubmitPracticeAnswer(fixture.practice)(
        state.session.id,
        firstQuestion.id,
        submitted.submittedOptionId,
      )).id,
      submitted.id,
    );
  });

  test('resume 1: durable Q1 before Continue restores same feedback', () async {
    var state = await start();
    final saved = await answer(state, correct: false);
    await fixture.reopen();
    state = await start();
    expect(state.session.currentOrdinal, 0);
    expect(state.currentProgress, QuestionProgress.answeredAwaitingContinue);
    expect(state.answerFor(state.currentQuestion.id)?.id, saved.id);
    expect(state.answerFor(state.currentQuestion.id)?.isCorrect, isFalse);
    expect(state.currentQuestion.question.explanation, isNotEmpty);
  });

  test(
    'resume 2: durable Continue restores next unanswered question',
    () async {
      var state = await start();
      await answer(state);
      await ContinuePractice(fixture.practice)(
        state.session.id,
        state.currentQuestion.id,
      );
      await fixture.reopen();
      state = await start();
      expect(state.session.currentOrdinal, 1);
      expect(state.progressFor(0), QuestionProgress.continued);
      expect(state.currentProgress, QuestionProgress.awaitingAnswer);
      expect(state.answers, hasLength(1));
    },
  );

  test('resume 3: last durable answer never auto-completes', () async {
    var state = await finishAnswers(await start());
    await fixture.reopen();
    state = await start();
    expect(state.session.currentOrdinal, 2);
    expect(state.session.status, QuizSessionStatus.inProgress);
    expect(state.session.completedAt, isNull);
    expect(state.currentProgress, QuestionProgress.answeredAwaitingContinue);
    await expectLater(
      ContinuePractice(fixture.practice)(
        state.session.id,
        state.currentQuestion.id,
      ),
      failure(PracticeFailureReason.completionRequired),
    );
  });

  test(
    'resume 4: completion failure rolls back, reopens and retries safely',
    () async {
      var state = await finishAnswers(await start());
      final oldAnswerIds = state.answers.map((a) => a.id).toSet();
      await fixture.database.execute(
        "CREATE TRIGGER test_fail_complete AFTER UPDATE OF status ON quiz_sessions "
        "WHEN NEW.status = 'completed' "
        "BEGIN SELECT RAISE(ABORT, 'synthetic completion failure'); END",
      );
      await expectLater(
        CompletePracticeSession(fixture.practice)(state.session.id),
        failure(PracticeFailureReason.persistence),
      );
      await fixture.reopen();
      state = await start();
      expect(state.answers.map((a) => a.id).toSet(), oldAnswerIds);
      expect(state.session.status, QuizSessionStatus.inProgress);
      expect(state.session.completedAt, isNull);
      expect(state.currentProgress, QuestionProgress.answeredAwaitingContinue);
      await expectLater(
        GetPracticeResult(fixture.practice)(state.session.id),
        failure(PracticeFailureReason.incompleteSession),
      );
      await fixture.database.execute('DROP TRIGGER test_fail_complete');
      final completed = await CompletePracticeSession(fixture.practice)(
        state.session.id,
      );
      fixture.now = fixture.now.add(const Duration(hours: 5));
      final repeated = await CompletePracticeSession(fixture.practice)(
        state.session.id,
      );
      expect(repeated.session.completedAt, completed.session.completedAt);
      expect(repeated.answers.map((a) => a.id).toSet(), oldAnswerIds);
    },
  );

  test(
    'resume 5: repeated and cross-connection racing start share one active',
    () async {
      // 第二個 connection 沿用 fixture 的 schema，避免此競態測試隱含升級。
      final second = await MigrationRunner(
        appMigrations.take(await fixture.database.getVersion()).toList(),
      ).open(databaseFactoryFfi, fixture.databasePath);
      try {
        final other = SqlitePracticeRepository(second);
        final states = await Future.wait([
          for (var i = 0; i < 8; i++)
            i.isEven
                ? start()
                : other.startOrResume(B0ContentIds.lesson, QuizMode.practice),
        ]);
        expect(states.map((s) => s.session.id).toSet(), hasLength(1));
        expect(await fixture.database.query('quiz_sessions'), hasLength(1));
        expect(
          await fixture.database.query('quiz_session_questions'),
          hasLength(3),
        );
        await fixture.reopen();
        expect((await start()).session.id, states.first.session.id);
      } finally {
        await second.close();
      }
    },
  );

  test('resume 6: completed history allows a new active session', () async {
    final first = await finishAnswers(await start());
    await CompletePracticeSession(fixture.practice)(first.session.id);
    await fixture.reopen();
    final next = await start();
    expect(next.session.id, isNot(first.session.id));
    expect(next.currentProgress, QuestionProgress.awaitingAnswer);
    expect(await fixture.database.query('quiz_sessions'), hasLength(2));
    expect(
      (await GetPracticeResult(fixture.practice)(first.session.id)).answerCount,
      3,
    );
  });

  test(
    'resume 7: new published version cannot replace frozen revisions',
    () async {
      var state = await start();
      final originalId = state.session.id;
      final oldRevisions = state.questions
          .map((q) => q.question.revision.id)
          .toList();
      final oldOption = state.currentQuestion.question.correctOptionId;
      final nextVersion = await fixture.publishNextVersion();
      // Old published/withdrawn revisions remain valid for an existing session.
      await fixture.content.withdraw(
        state.currentQuestion.question.revision.id,
        'synthetic-test',
        fixture.now,
      );
      await fixture.reopen();
      state = await start();
      expect(state.session.id, originalId);
      expect(state.session.contentVersionId, B0ContentIds.version);
      expect(state.questions.map((q) => q.question.revision.id), oldRevisions);
      final saved = await SubmitPracticeAnswer(fixture.practice)(
        originalId,
        state.currentQuestion.id,
        oldOption,
      );
      expect(saved.isCorrect, isTrue);
      state = await finishAnswers(state);
      await CompletePracticeSession(fixture.practice)(originalId);
      final next = await start();
      expect(next.session.contentVersionId, nextVersion);
      expect(
        next.questions.first.question.revision.id,
        isNot(oldRevisions.first),
      );
      expect(await fixture.database.query('quiz_sessions'), hasLength(2));
    },
  );

  test(
    'answer and Continue failures preserve original durable state',
    () async {
      var state = await start();
      await fixture.database.execute(
        "CREATE TRIGGER test_fail_answer AFTER INSERT ON quiz_answers "
        "BEGIN SELECT RAISE(ABORT, 'synthetic answer failure'); END",
      );
      await expectLater(
        answer(state),
        failure(PracticeFailureReason.persistence),
      );
      await fixture.reopen();
      state = await start();
      expect(state.answers, isEmpty);
      expect(state.currentProgress, QuestionProgress.awaitingAnswer);
      await fixture.database.execute('DROP TRIGGER test_fail_answer');
      final saved = await answer(state);
      await fixture.database.execute(
        "CREATE TRIGGER test_fail_continue AFTER UPDATE OF current_ordinal "
        "ON quiz_sessions WHEN NEW.current_ordinal != OLD.current_ordinal "
        "BEGIN SELECT RAISE(ABORT, 'synthetic Continue failure'); END",
      );
      await expectLater(
        ContinuePractice(fixture.practice)(
          state.session.id,
          state.currentQuestion.id,
        ),
        failure(PracticeFailureReason.persistence),
      );
      await fixture.reopen();
      state = await start();
      expect(state.session.currentOrdinal, 0);
      expect(state.currentProgress, QuestionProgress.answeredAwaitingContinue);
      expect(state.answers.single.id, saved.id);
      await fixture.database.execute('DROP TRIGGER test_fail_continue');
      state = await ContinuePractice(fixture.practice)(
        state.session.id,
        state.currentQuestion.id,
      );
      expect(state.session.currentOrdinal, 1);
    },
  );

  test(
    'failed start snapshot rolls back session and all partial rows',
    () async {
      await fixture.database.execute(
        "CREATE TRIGGER test_fail_snapshot AFTER INSERT ON quiz_session_questions "
        "WHEN NEW.ordinal = 1 "
        "BEGIN SELECT RAISE(ABORT, 'synthetic start failure'); END",
      );
      await expectLater(start(), failure(PracticeFailureReason.persistence));
      expect(await fixture.database.query('quiz_sessions'), isEmpty);
      expect(await fixture.database.query('quiz_session_questions'), isEmpty);
      await fixture.database.execute('DROP TRIGGER test_fail_snapshot');
      expect((await start()).questions, hasLength(3));
    },
  );

  test(
    'review mode is independent; unknown contexts and missing IDs are safe',
    () async {
      final practice = await start();
      final review = await start(mode: QuizMode.review);
      expect(practice.session.id, isNot(review.session.id));
      expect(
        (await start(mode: QuizMode.review)).session.id,
        review.session.id,
      );
      await expectLater(
        StartOrResumePractice(fixture.practice)('unknown'),
        failure(PracticeFailureReason.unknownContext),
      );
      await expectLater(
        GetPracticeSession(fixture.practice)('missing'),
        failure(PracticeFailureReason.sessionNotFound),
      );
      await expectLater(
        SubmitPracticeAnswer(fixture.practice)(
          practice.session.id,
          review.currentQuestion.id,
          review.currentQuestion.question.correctOptionId,
        ),
        failure(PracticeFailureReason.questionNotFound),
      );
    },
  );
}
