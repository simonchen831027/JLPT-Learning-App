import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_failure.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:jlpt_learning_app/features/practice/presentation/practice_view_model.dart';

import '../../support/controlled_practice_repository.dart';
import '../../support/practice_fixture.dart';

void main() {
  late PracticeFixture fixture;
  late ControlledPracticeRepository repository;
  late PracticeViewModel model;
  setUp(() async {
    fixture = await PracticeFixture.create();
    repository = ControlledPracticeRepository(fixture.practice);
    model = PracticeViewModel(
      PracticeActions.fromRepository(repository),
      B0ContentIds.lesson,
    );
    await model.open();
  });
  tearDown(() async {
    model.dispose();
    await fixture.dispose();
  });

  Future<void> answer() async {
    model.select(model.state!.currentQuestion.question.correctOptionId);
    await model.submit();
  }

  Future<void> lastFeedback() async {
    for (var i = 0; i < 3; i++) {
      await answer();
      if (i < 2) await model.advance();
    }
  }

  Future<void> restart() async {
    model.dispose();
    await fixture.reopen();
    repository = ControlledPracticeRepository(fixture.practice);
    model = PracticeViewModel(
      PracticeActions.fromRepository(repository),
      B0ContentIds.lesson,
    );
    await model.open();
  }

  test(
    'empty submit never calls application operation or reveals feedback',
    () async {
      await model.submit();
      expect(model.validation, isTrue);
      expect(model.focus, PracticeFocus.validation);
      expect(repository.submitCalls, 0);
      expect(model.answer, isNull);
      model.select(model.state!.currentQuestion.question.options.last.id);
      expect(model.validation, isFalse);
    },
  );
  test(
    'unknown Continue commit locks Back until read confirms next ordinal',
    () async {
      await answer();
      repository.throwAfterNext = true;
      repository.failRead = true;
      await model.advance();
      expect(model.phase, PracticePhase.reconciliationError);
      expect(model.mutationLocked, isTrue);
      await model.advance();
      expect(repository.nextCalls, 1);
      repository.failRead = false;
      await model.retry();
      expect(model.state!.session.currentOrdinal, 1);
      expect(model.phase, PracticePhase.awaiting);
      expect(model.mutationLocked, isFalse);
      expect(repository.nextCalls, 1);
    },
  );
  test(
    'unknown completion commit retry reads Result without completing twice',
    () async {
      await lastFeedback();
      repository.throwAfterComplete = true;
      repository.failRead = true;
      await model.advance();
      expect(model.mutationLocked, isTrue);
      expect(model.result, isNull);
      repository.failRead = false;
      await model.retry();
      expect(model.phase, PracticePhase.completedResult);
      expect(model.result!.answerCount, 3);
      expect(repository.completeCalls, 1);
      expect(repository.resultCalls, 1);
      expect(model.mutationLocked, isFalse);
    },
  );
  test(
    'delayed save captures intent, locks Back and prevents duplicate submit',
    () async {
      repository.submitGate = Completer<void>();
      model.select(model.state!.currentQuestion.question.correctOptionId);
      final save = model.submit();
      expect(model.phase, PracticePhase.submitting);
      expect(model.mutationLocked, isTrue);
      expect(model.answer, isNull);
      await model.submit();
      expect(repository.submitCalls, 1);
      repository.submitGate!.complete();
      await save;
      expect(model.phase, PracticePhase.feedback);
      expect(model.canSelect, isFalse);
      expect(model.mutationLocked, isFalse);
    },
  );
  test('Submit rollback preserves draft and permits explicit retry', () async {
    repository.failSubmit = true;
    final selected = model.state!.currentQuestion.question.options.last.id;
    model.select(selected);
    await model.submit();
    expect(model.phase, PracticePhase.submitError);
    expect(model.selection, selected);
    expect(model.answer, isNull);
    expect(model.mutationLocked, isFalse);
    expect(await fixture.database.query('quiz_answers'), isEmpty);
    repository.failSubmit = false;
    await model.submit();
    expect(model.answer!.isCorrect, isFalse);
  });
  test('explicit Submit failure with read failure unlocks Back and preserves draft', () async {
    repository.failSubmit = true;
    repository.failRead = true;
    final selected = model.state!.currentQuestion.question.correctOptionId;
    model.select(selected);
    await model.submit();
    expect(await fixture.database.query('quiz_answers'), isEmpty);
    expect(model.answer, isNull);
    expect(model.result, isNull);
    expect(model.selection, selected);
    expect(model.mutationLocked, isFalse);
    expect(model.phase, PracticePhase.submitError);
    expect(model.canSelect, isTrue);
    expect(model.busy, isFalse);
    expect(model.focus, PracticeFocus.error);
    expect(model.error, isNotEmpty);
    expect(repository.submitCalls, 1);
    repository.failSubmit = false;
    await model.submit();
    expect(model.phase, PracticePhase.answerSavedReloading);
    expect(model.answer!.submittedOptionId, selected);
    expect(model.canSelect, isFalse);
    expect(await fixture.database.query('quiz_answers'), hasLength(1));
    repository.failRead = false;
    await model.retry();
    expect(model.phase, PracticePhase.feedback);
    expect(repository.submitCalls, 2);
  });
  test(
    'lost acknowledgement reconciles original durable answer without re-submit',
    () async {
      repository.throwAfterSubmit = true;
      await answer();
      expect(model.phase, PracticePhase.feedback);
      expect(repository.submitCalls, 1);
      expect(await fixture.database.query('quiz_answers'), hasLength(1));
    },
  );
  test(
    'unknown outcome read failure keeps Back locked; retry only reads',
    () async {
      repository.throwAfterSubmit = true;
      repository.failRead = true;
      await answer();
      expect(model.phase, PracticePhase.reconciliationError);
      expect(model.mutationLocked, isTrue);
      expect(model.answer, isNull);
      expect(model.result, isNull);
      expect(model.canSelect, isFalse);
      expect(await fixture.database.query('quiz_answers'), hasLength(1));
      await model.submit();
      await model.retry();
      expect(model.phase, PracticePhase.reconciliationError);
      expect(model.mutationLocked, isTrue);
      expect(repository.submitCalls, 1);
      repository.failRead = false;
      await model.retry();
      expect(model.phase, PracticePhase.feedback);
      expect(repository.submitCalls, 1);
    },
  );
  test(
    'known durable acknowledgement survives reload failure without unlocking',
    () async {
      repository.failRead = true;
      await answer();
      expect(model.phase, PracticePhase.answerSavedReloading);
      expect(model.answer, isNotNull);
      expect(model.canSelect, isFalse);
      expect(model.mutationLocked, isFalse);
      repository.failRead = false;
      await model.retry();
      expect(model.phase, PracticePhase.feedback);
      expect(repository.submitCalls, 1);
    },
  );
  test(
    'Continue error retains feedback and retries original transition once',
    () async {
      await answer();
      repository.failNext = true;
      await model.advance();
      expect(model.phase, PracticePhase.continueError);
      expect(model.state!.session.currentOrdinal, 0);
      expect(model.answer, isNotNull);
      expect(model.mutationLocked, isFalse);
      repository.failNext = false;
      await model.retry();
      expect(model.state!.session.currentOrdinal, 1);
      expect(repository.nextCalls, 2);
    },
  );
  test('completion delayed/error and Result read retry preserve completion authority', () async {
    await lastFeedback();
    expect(model.state!.session.status, QuizSessionStatus.inProgress);
    repository.completeGate = Completer<void>();
    repository.failComplete = true;
    final complete = model.advance();
    expect(model.phase, PracticePhase.completing);
    expect(model.mutationLocked, isTrue);
    expect(model.answer, isNotNull);
    repository.completeGate!.complete();
    await complete;
    expect(model.phase, PracticePhase.completionError);
    expect(model.result, isNull);
    repository.failComplete = false;
    repository.failResult = true;
    await model.retry();
    expect(model.phase, PracticePhase.resultReadError);
    final time = model.state!.session.completedAt;
    expect(time, isNotNull);
    final calls = repository.completeCalls;
    repository.failResult = false;
    await model.retry();
    expect(model.result!.answerCount, 3);
    expect(repository.completeCalls, calls);
    expect(model.state!.session.completedAt, time);
  });
  test(
    'R1 / R5 real reopen before Continue restores same feedback and active',
    () async {
      await answer();
      final id = model.state!.session.id;
      await restart();
      expect(model.state!.session.id, id);
      expect(model.phase, PracticePhase.feedback);
      expect(model.focus, PracticeFocus.feedback);
      expect(repository.submitCalls, 0);
      expect(await fixture.database.query('quiz_sessions'), hasLength(1));
    },
  );
  test(
    'R2 real reopen after Continue restores next awaiting question',
    () async {
      await answer();
      await model.advance();
      await restart();
      expect(model.state!.session.currentOrdinal, 1);
      expect(model.phase, PracticePhase.awaiting);
      expect(model.selection, isNull);
      expect(model.focus, PracticeFocus.question);
    },
  );
  test('R3 real last-answer reopen does not auto-complete', () async {
    await lastFeedback();
    await restart();
    expect(model.isLast, isTrue);
    expect(model.phase, PracticePhase.feedback);
    expect(model.state!.session.status, QuizSessionStatus.inProgress);
    expect(repository.completeCalls, 0);
  });
  test(
    'R4 completion rollback reopens last feedback, safe explicit retry',
    () async {
      await lastFeedback();
      await fixture.database.execute(
        "CREATE TRIGGER test_ui_fail_complete AFTER UPDATE OF status ON quiz_sessions WHEN NEW.status = 'completed' BEGIN SELECT RAISE(ABORT, 'synthetic'); END",
      );
      await model.advance();
      await restart();
      expect(model.isLast, isTrue);
      expect(model.phase, PracticePhase.feedback);
      expect(model.result, isNull);
      await fixture.database.execute('DROP TRIGGER test_ui_fail_complete');
      await model.advance();
      expect(model.phase, PracticePhase.completedResult);
    },
  );
  test(
    'R6 completed history opens new session; R7 version cannot replace active',
    () async {
      await lastFeedback();
      await model.advance();
      final completedId = model.state!.session.id;
      await restart();
      expect(model.state!.session.id, isNot(completedId));
      final version = model.state!.session.contentVersionId;
      final revision = model.state!.currentQuestion.question.revision.id;
      await fixture.publishNextVersion();
      await restart();
      expect(model.state!.session.contentVersionId, version);
      expect(model.state!.currentQuestion.question.revision.id, revision);
      expect(model.phase, PracticePhase.awaiting);
    },
  );
  test('12 failure mappings never expose internal enum names', () {
    for (final reason in PracticeFailureReason.values) {
      final copy = practiceFailureMessage(reason);
      expect(copy, isNot(contains(reason.name)));
      expect(copy, isNotEmpty);
    }
  });
}
