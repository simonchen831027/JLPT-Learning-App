import 'package:flutter/foundation.dart';

import '../domain/practice_failure.dart';
import '../domain/practice_models.dart';
import '../domain/practice_repository.dart';
import '../domain/practice_use_cases.dart';

/// Feature-local composition of the existing application operations.
final class PracticeActions {
  factory PracticeActions.fromRepository(PracticeRepository repository) =>
      PracticeActions(
        start: StartOrResumePractice(repository),
        read: GetPracticeSession(repository),
        submit: SubmitPracticeAnswer(repository),
        next: ContinuePractice(repository),
        complete: CompletePracticeSession(repository),
        result: GetPracticeResult(repository),
      );
  const PracticeActions({
    required this.start,
    required this.read,
    required this.submit,
    required this.next,
    required this.complete,
    required this.result,
  });
  final StartOrResumePractice start;
  final GetPracticeSession read;
  final SubmitPracticeAnswer submit;
  final ContinuePractice next;
  final CompletePracticeSession complete;
  final GetPracticeResult result;
}

enum PracticePhase {
  initialLoading,
  awaiting,
  submitting,
  answerSavedReloading,
  feedback,
  continuing,
  completing,
  submitError,
  reconciling,
  reconciliationError,
  continueError,
  completionError,
  resultLoading,
  resultReadError,
  completedResult,
  unavailable,
  internalError,
}

enum PracticeFocus { question, validation, feedback, error, result }

enum _Retry { entry, read, reconcile, next, complete, result }

String practiceFailureMessage(PracticeFailureReason reason) => switch (reason) {
  PracticeFailureReason.missingSelection => '請先選擇一個答案。',
  PracticeFailureReason.invalidSelection => '所選答案無法使用。請重新確認題目。',
  PracticeFailureReason.contentUnavailable => '本次練習內容暫時無法讀取。',
  PracticeFailureReason.unknownContext => '目前無法開啟這項練習。',
  PracticeFailureReason.sessionNotFound => '無法找到這次練習的資料。',
  PracticeFailureReason.questionNotFound => '目前題目無法讀取。請重新載入。',
  PracticeFailureReason.outOfOrder => '題目狀態已更新。請重新載入。',
  PracticeFailureReason.conflictingAnswer => '這題已有保存的答案。正在確認作答狀態。',
  PracticeFailureReason.incompleteSession => '目前尚無法完成本次練習。請確認作答狀態。',
  PracticeFailureReason.completionRequired => '請查看本次結果。',
  PracticeFailureReason.invalidState => '本次練習狀態無法讀取。',
  PracticeFailureReason.persistence => '答案尚未確認保存，請重試。',
};

final class PracticeViewModel extends ChangeNotifier {
  PracticeViewModel(this.actions, this.contextId);
  final PracticeActions actions;
  final String contextId;
  PracticePhase phase = PracticePhase.initialLoading;
  PracticeState? state;
  PracticeResult? result;
  String? selection;
  String? error;
  bool validation = false;
  QuizAnswer? acknowledgedAnswer;
  int focusRevision = 0;
  PracticeFocus focus = PracticeFocus.question;
  _Retry? _retry;
  String? _pendingQuestion;
  bool _reconcilingTransition = false;
  bool _disposed = false;

  bool get mutationLocked => switch (phase) {
    PracticePhase.submitting ||
    PracticePhase.continuing ||
    PracticePhase.completing ||
    PracticePhase.reconciling ||
    PracticePhase.reconciliationError => true,
    _ => false,
  };
  bool get busy =>
      (mutationLocked && phase != PracticePhase.reconciliationError) ||
      phase == PracticePhase.initialLoading ||
      phase == PracticePhase.resultLoading ||
      (phase == PracticePhase.answerSavedReloading && error == null);
  QuizAnswer? get answer =>
      acknowledgedAnswer ?? state?.answerFor(state!.currentQuestion.id);
  bool get canSelect =>
      (phase == PracticePhase.awaiting || phase == PracticePhase.submitError) &&
      answer == null;
  bool get isLast =>
      state != null &&
      state!.session.currentOrdinal == state!.session.questionCount - 1;
  bool get canAdvance =>
      phase == PracticePhase.feedback ||
      phase == PracticePhase.continueError ||
      phase == PracticePhase.completionError;
  bool get canRetry =>
      _retry != null && !busy ||
      phase == PracticePhase.reconciliationError ||
      (phase == PracticePhase.answerSavedReloading && error != null);

  void _publish({PracticeFocus? target}) {
    if (_disposed) return;
    if (target != null) {
      focus = target;
      focusRevision++;
    }
    notifyListeners();
  }

  void select(String id) {
    if (!canSelect ||
        !state!.currentQuestion.question.options.any((o) => o.id == id)) {
      return;
    }
    selection = id;
    validation = false;
    _publish();
  }

  Future<void> open() async {
    if (_disposed || mutationLocked) return;
    phase = PracticePhase.initialLoading;
    error = null;
    _retry = null;
    _publish();
    try {
      await _map(await actions.start(contextId));
    } catch (e) {
      _readFailure(e, _Retry.entry);
    }
  }

  Future<void> _map(PracticeState next, {bool keepDraft = false}) async {
    if (_disposed) return;
    final oldQuestion = state?.currentQuestion.id;
    state = next;
    acknowledgedAnswer = null;
    error = null;
    validation = false;
    _retry = null;
    if (next.session.status == QuizSessionStatus.completed) {
      selection = null;
      await _readResult();
      return;
    }
    final saved = next.answerFor(next.currentQuestion.id);
    if (saved != null) {
      selection = saved.submittedOptionId;
      phase = PracticePhase.feedback;
      _publish(target: PracticeFocus.feedback);
    } else {
      if (!keepDraft ||
          oldQuestion != next.currentQuestion.id ||
          !next.currentQuestion.question.options.any(
            (o) => o.id == selection,
          )) {
        selection = null;
      }
      phase = PracticePhase.awaiting;
      _publish(target: PracticeFocus.question);
    }
  }

  Future<void> submit() async {
    if (!canSelect) return;
    if (selection == null) {
      validation = true;
      _publish(target: PracticeFocus.validation);
      return;
    }
    final original = state!;
    final option = selection!;
    _pendingQuestion = original.currentQuestion.id;
    phase = PracticePhase.submitting;
    error = null;
    _retry = null;
    _publish();
    try {
      final saved = await actions.submit(
        original.session.id,
        _pendingQuestion!,
        option,
      );
      if (_disposed) return;
      if (saved.sessionId != original.session.id ||
          saved.sessionQuestionId != original.currentQuestion.id ||
          saved.questionRevisionId !=
              original.currentQuestion.question.revision.id ||
          saved.submittedOptionId != option) {
        throw const PracticeFailure(PracticeFailureReason.invalidState);
      }
      acknowledgedAnswer = saved;
      selection = saved.submittedOptionId;
      phase = PracticePhase.answerSavedReloading;
      _publish();
      // An acknowledged durable answer never becomes an editable draft if
      // this pure read fails. No sound is requested on hydration paths.
      await _readSaved();
    } catch (e) {
      if (_disposed) return;
      if (e is PracticeFailure &&
          e.reason == PracticeFailureReason.missingSelection) {
        phase = PracticePhase.awaiting;
        validation = true;
        _publish(target: PracticeFocus.validation);
      } else if (e is PracticeFailure &&
          e.reason == PracticeFailureReason.persistence) {
        // A known failed save does not need an outcome reconciliation read.
        // Keep the draft retryable, as for known Continue / Complete failures.
        phase = PracticePhase.submitError;
        error = practiceFailureMessage(e.reason);
        _publish(target: PracticeFocus.error);
      } else {
        await _reconcile(e);
      }
    }
  }

  Future<void> _readSaved() async {
    phase = PracticePhase.answerSavedReloading;
    error = null;
    _publish();
    try {
      final loaded = await actions.read(state!.session.id);
      final acknowledged = acknowledgedAnswer!;
      final persisted = loaded.answerFor(acknowledged.sessionQuestionId);
      if (persisted == null ||
          persisted.id != acknowledged.id ||
          persisted.submittedOptionId != acknowledged.submittedOptionId ||
          persisted.isCorrect != acknowledged.isCorrect) {
        throw const PracticeFailure(PracticeFailureReason.invalidState);
      }
      await _map(loaded);
    } catch (_) {
      if (_disposed) return;
      phase = PracticePhase.answerSavedReloading;
      error = '答案已保存，暫時無法讀取作答狀態。請重新載入。';
      _retry = _Retry.read;
      _publish(target: PracticeFocus.error);
    }
  }

  Future<void> _reconcile(Object cause, {bool transition = false}) async {
    _reconcilingTransition = transition;
    phase = PracticePhase.reconciling;
    error = null;
    _retry = null;
    _publish();
    try {
      await _map(await actions.read(state!.session.id), keepDraft: true);
      if (_disposed) return;
      if (phase == PracticePhase.awaiting) {
        if (transition) return;
        phase = PracticePhase.submitError;
        error = cause is PracticeFailure
            ? practiceFailureMessage(cause.reason)
            : practiceFailureMessage(PracticeFailureReason.persistence);
        _publish(target: PracticeFocus.error);
      } else if (transition &&
          phase == PracticePhase.feedback &&
          state!.currentQuestion.id == _pendingQuestion) {
        phase = isLast
            ? PracticePhase.completionError
            : PracticePhase.continueError;
        error = practiceFailureMessage(
          cause is PracticeFailure
              ? cause.reason
              : PracticeFailureReason.persistence,
        );
        _retry = isLast ? _Retry.complete : _Retry.next;
        _publish(target: PracticeFocus.error);
      }
    } catch (_) {
      if (_disposed) return;
      phase = PracticePhase.reconciliationError;
      error = '尚無法確認作答狀態。請重新讀取後再繼續。';
      _retry = _Retry.reconcile;
      _publish(target: PracticeFocus.error);
    }
  }

  Future<void> advance() async {
    if (!canAdvance) return;
    final completing = isLast;
    final originalQuestion = _pendingQuestion = state!.currentQuestion.id;
    phase = completing ? PracticePhase.completing : PracticePhase.continuing;
    error = null;
    _retry = null;
    _publish();
    try {
      final next = completing
          ? await actions.complete(state!.session.id)
          : await actions.next(state!.session.id, originalQuestion);
      await _map(next);
    } catch (e) {
      if (_disposed) return;
      if (e is PracticeFailure &&
          e.reason == PracticeFailureReason.persistence) {
        phase = completing
            ? PracticePhase.completionError
            : PracticePhase.continueError;
        error = completing ? '本次練習尚未完成。你的答案已保存，請再試一次。' : '未能開啟下一題。你的答案已保存，請重試。';
        _retry = completing ? _Retry.complete : _Retry.next;
        _publish(target: PracticeFocus.error);
      } else {
        // Reconcile uncertain transitions before permitting navigation/retry.
        // Never manually advance an ordinal or repeat an unknown mutation.
        await _reconcile(e, transition: true);
      }
    }
  }

  Future<void> _readResult() async {
    phase = PracticePhase.resultLoading;
    result = null;
    error = null;
    _retry = null;
    _publish();
    try {
      final value = await actions.result(state!.session.id);
      if (_disposed) return;
      result = value;
      phase = PracticePhase.completedResult;
      _publish(target: PracticeFocus.result);
    } catch (_) {
      if (_disposed) return;
      phase = PracticePhase.resultReadError;
      error = '本次練習已完成，暫時無法讀取結果。請重試。';
      _retry = _Retry.result;
      _publish(target: PracticeFocus.error);
    }
  }

  void _readFailure(Object e, _Retry retry) {
    if (_disposed) return;
    final reason = e is PracticeFailure
        ? e.reason
        : PracticeFailureReason.persistence;
    phase =
        reason == PracticeFailureReason.contentUnavailable ||
            reason == PracticeFailureReason.unknownContext
        ? PracticePhase.unavailable
        : PracticePhase.internalError;
    error = practiceFailureMessage(reason);
    _retry = reason == PracticeFailureReason.unknownContext ? null : retry;
    _publish(target: PracticeFocus.error);
  }

  Future<void> retry() async {
    if (!canRetry) return;
    switch (_retry) {
      case _Retry.entry:
        await open();
      case _Retry.result:
        await _readResult();
      case _Retry.reconcile:
        await _reconcile(
          const PracticeFailure(PracticeFailureReason.persistence),
          transition: _reconcilingTransition,
        );
      case _Retry.next || _Retry.complete:
        await advance();
      case _Retry.read:
        if (acknowledgedAnswer != null) {
          await _readSaved();
        } else {
          error = null;
          phase = PracticePhase.initialLoading;
          _publish();
          try {
            await _map(await actions.read(state!.session.id));
          } catch (e) {
            _readFailure(e, _Retry.read);
          }
        }
      case null:
        break;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
