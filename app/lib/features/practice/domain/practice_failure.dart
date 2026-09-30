enum PracticeFailureReason {
  missingSelection,
  invalidSelection,
  contentUnavailable,
  unknownContext,
  sessionNotFound,
  questionNotFound,
  outOfOrder,
  conflictingAnswer,
  incompleteSession,
  completionRequired,
  invalidState,
  persistence,
}

/// Operation failures never become persisted session status or wrong answers.
final class PracticeFailure implements Exception {
  const PracticeFailure(this.reason);
  final PracticeFailureReason reason;
}
