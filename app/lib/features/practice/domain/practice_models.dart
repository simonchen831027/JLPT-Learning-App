import '../../content/domain/content_models.dart';
import 'practice_failure.dart';

enum QuizMode { practice, review }

enum QuizSessionStatus { inProgress, completed }

enum QuestionProgress { awaitingAnswer, answeredAwaitingContinue, continued }

final class QuizSession {
  QuizSession({
    required this.id,
    required this.contextContentId,
    required this.mode,
    required this.status,
    required this.contentVersionId,
    required this.questionCount,
    required this.currentOrdinal,
    required this.createdAt,
    required this.startedAt,
    this.completedAt,
  }) {
    if (questionCount < 1 ||
        currentOrdinal < 0 ||
        currentOrdinal >= questionCount ||
        (status == QuizSessionStatus.completed) != (completedAt != null)) {
      throw const PracticeFailure(PracticeFailureReason.invalidState);
    }
  }

  final String id;
  final String contextContentId;
  final QuizMode mode;
  final QuizSessionStatus status;
  final String contentVersionId;
  final int questionCount;
  final int currentOrdinal;
  final DateTime createdAt;
  final DateTime startedAt;
  final DateTime? completedAt;
}

final class QuizSessionQuestion {
  const QuizSessionQuestion({
    required this.id,
    required this.sessionId,
    required this.ordinal,
    required this.question,
  });
  final String id;
  final String sessionId;
  final int ordinal;
  final QuestionContent question;
}

final class QuizAnswer {
  const QuizAnswer({
    required this.id,
    required this.sessionId,
    required this.sessionQuestionId,
    required this.questionRevisionId,
    required this.submittedOptionId,
    required this.isCorrect,
    required this.submittedAt,
    required this.createdAt,
  });
  final String id;
  final String sessionId;
  final String sessionQuestionId;
  final String questionRevisionId;
  final String submittedOptionId;
  final bool isCorrect;
  final DateTime submittedAt;
  final DateTime createdAt;
}

/// Pure singleChoice evaluation; callers persist before reporting success.
bool evaluatePracticeAnswer(QuestionContent question, String? optionId) {
  if (optionId == null || optionId.isEmpty) {
    throw const PracticeFailure(PracticeFailureReason.missingSelection);
  }
  if (!question.options.any((option) => option.id == optionId)) {
    throw const PracticeFailure(PracticeFailureReason.invalidSelection);
  }
  return question.correctOptionId == optionId;
}

final class PracticeState {
  PracticeState({
    required this.session,
    required List<QuizSessionQuestion> questions,
    required List<QuizAnswer> answers,
  }) : questions = List.unmodifiable(questions),
       answers = List.unmodifiable(answers) {
    if (questions.length != session.questionCount) {
      throw const PracticeFailure(PracticeFailureReason.invalidState);
    }
    for (var index = 0; index < questions.length; index++) {
      final item = questions[index];
      if (item.ordinal != index ||
          item.sessionId != session.id ||
          item.question.revision.contentVersionId != session.contentVersionId) {
        throw const PracticeFailure(PracticeFailureReason.invalidState);
      }
    }
    final answered = <String>{};
    for (final answer in answers) {
      final matches = questions.where(
        (item) => item.id == answer.sessionQuestionId,
      );
      if (answer.sessionId != session.id ||
          matches.length != 1 ||
          !answered.add(answer.sessionQuestionId)) {
        throw const PracticeFailure(PracticeFailureReason.invalidState);
      }
      final item = matches.single;
      if (item.question.revision.id != answer.questionRevisionId ||
          item.ordinal > session.currentOrdinal ||
          evaluatePracticeAnswer(item.question, answer.submittedOptionId) !=
              answer.isCorrect) {
        throw const PracticeFailure(PracticeFailureReason.invalidState);
      }
    }
    if (questions
            .take(session.currentOrdinal)
            .any((item) => !answered.contains(item.id)) ||
        (session.status == QuizSessionStatus.completed &&
            (answers.length != questions.length ||
                session.currentOrdinal != questions.length - 1))) {
      throw const PracticeFailure(PracticeFailureReason.invalidState);
    }
  }

  final QuizSession session;
  final List<QuizSessionQuestion> questions;
  final List<QuizAnswer> answers;

  QuizSessionQuestion get currentQuestion => questions[session.currentOrdinal];
  QuizAnswer? answerFor(String sessionQuestionId) {
    for (final answer in answers) {
      if (answer.sessionQuestionId == sessionQuestionId) return answer;
    }
    return null;
  }

  /// Future questions are not marked as presented. Continue comes from the
  /// persisted ordinal, never merely from the existence of an answer.
  QuestionProgress? progressFor(int ordinal) {
    if (ordinal < 0 || ordinal >= questions.length) {
      throw RangeError.index(ordinal, questions);
    }
    if (session.status == QuizSessionStatus.completed ||
        ordinal < session.currentOrdinal) {
      return QuestionProgress.continued;
    }
    if (ordinal > session.currentOrdinal) return null;
    return answerFor(questions[ordinal].id) == null
        ? QuestionProgress.awaitingAnswer
        : QuestionProgress.answeredAwaitingContinue;
  }

  QuestionProgress get currentProgress => progressFor(session.currentOrdinal)!;
}

/// A read model of original evidence, not a separate persistence truth.
final class PracticeResult {
  PracticeResult(this.state) {
    if (state.session.status != QuizSessionStatus.completed) {
      throw const PracticeFailure(PracticeFailureReason.incompleteSession);
    }
  }
  final PracticeState state;
  int get answerCount => state.answers.length;
  int get correctCount =>
      state.answers.where((answer) => answer.isCorrect).length;
  int get wrongCount => answerCount - correctCount;
}
