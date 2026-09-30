import 'practice_failure.dart';
import 'practice_models.dart';
import 'practice_repository.dart';

final class StartOrResumePractice {
  const StartOrResumePractice(this._repository);
  final PracticeRepository _repository;
  Future<PracticeState> call(
    String contextContentId, {
    QuizMode mode = QuizMode.practice,
  }) => _repository.startOrResume(contextContentId, mode);
}

final class GetPracticeSession {
  const GetPracticeSession(this._repository);
  final PracticeRepository _repository;
  Future<PracticeState> call(String sessionId) =>
      _repository.getSession(sessionId);
}

final class SubmitPracticeAnswer {
  const SubmitPracticeAnswer(this._repository);
  final PracticeRepository _repository;
  Future<QuizAnswer> call(
    String sessionId,
    String sessionQuestionId,
    String? optionId,
  ) async {
    if (optionId == null || optionId.isEmpty) {
      throw const PracticeFailure(PracticeFailureReason.missingSelection);
    }
    return _repository.submitAnswer(sessionId, sessionQuestionId, optionId);
  }
}

final class ContinuePractice {
  const ContinuePractice(this._repository);
  final PracticeRepository _repository;
  Future<PracticeState> call(String sessionId, String sessionQuestionId) =>
      _repository.continueQuestion(sessionId, sessionQuestionId);
}

final class CompletePracticeSession {
  const CompletePracticeSession(this._repository);
  final PracticeRepository _repository;
  Future<PracticeState> call(String sessionId) =>
      _repository.completeSession(sessionId);
}

final class GetPracticeResult {
  const GetPracticeResult(this._repository);
  final PracticeRepository _repository;
  Future<PracticeResult> call(String sessionId) =>
      _repository.getResult(sessionId);
}
