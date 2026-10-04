import 'dart:async';

import 'package:jlpt_learning_app/features/practice/domain/practice_failure.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_repository.dart';

/// Failure/delay injection around real SQLite operations, not a replacement
/// grading or session engine.
final class ControlledPracticeRepository implements PracticeRepository {
  ControlledPracticeRepository(this.inner);
  final PracticeRepository inner;
  Completer<void>? submitGate;
  Completer<void>? readGate;
  Completer<void>? nextGate;
  Completer<void>? completeGate;
  Completer<void>? startGate;
  Completer<void>? resultGate;
  bool failSubmit = false, throwAfterSubmit = false;
  bool throwAfterNext = false, throwAfterComplete = false;
  bool failRead = false,
      failNext = false,
      failComplete = false,
      failResult = false;
  int submitCalls = 0, nextCalls = 0, completeCalls = 0, resultCalls = 0;
  void _fail(bool fail) {
    if (fail) throw const PracticeFailure(PracticeFailureReason.persistence);
  }

  @override
  Future<PracticeState> startOrResume(String context, QuizMode mode) async {
    await startGate?.future;
    return inner.startOrResume(context, mode);
  }

  @override
  Future<PracticeState> getSession(String id) async {
    await readGate?.future;
    _fail(failRead);
    return inner.getSession(id);
  }

  @override
  Future<QuizAnswer> submitAnswer(
    String id,
    String question,
    String? option,
  ) async {
    submitCalls++;
    await submitGate?.future;
    _fail(failSubmit);
    final saved = await inner.submitAnswer(id, question, option);
    if (throwAfterSubmit) throw StateError('test-only lost acknowledgement');
    return saved;
  }

  @override
  Future<PracticeState> continueQuestion(String id, String question) async {
    nextCalls++;
    await nextGate?.future;
    _fail(failNext);
    final next = await inner.continueQuestion(id, question);
    if (throwAfterNext) throw StateError('test-only lost acknowledgement');
    return next;
  }

  @override
  Future<PracticeState> completeSession(String id) async {
    completeCalls++;
    await completeGate?.future;
    _fail(failComplete);
    final completed = await inner.completeSession(id);
    if (throwAfterComplete) throw StateError('test-only lost acknowledgement');
    return completed;
  }

  @override
  Future<PracticeResult> getResult(String id) async {
    resultCalls++;
    await resultGate?.future;
    _fail(failResult);
    return inner.getResult(id);
  }
}
