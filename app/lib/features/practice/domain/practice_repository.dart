import 'practice_models.dart';

abstract interface class PracticeRepository {
  Future<PracticeState> startOrResume(String contextContentId, QuizMode mode);
  Future<PracticeState> getSession(String sessionId);
  Future<QuizAnswer> submitAnswer(
    String sessionId,
    String sessionQuestionId,
    String? optionId,
  );
  Future<PracticeState> continueQuestion(
    String sessionId,
    String sessionQuestionId,
  );
  Future<PracticeState> completeSession(String sessionId);
  Future<PracticeResult> getResult(String sessionId);
}
