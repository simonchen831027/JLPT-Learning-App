import '../domain/practice_models.dart';
import '../domain/practice_repository.dart';

/// Preserves app startup ownership of database initialization.
final class DeferredPracticeRepository implements PracticeRepository {
  const DeferredPracticeRepository(this.open);
  final Future<PracticeRepository> Function() open;
  @override
  Future<PracticeState> startOrResume(String context, QuizMode mode) async =>
      (await open()).startOrResume(context, mode);
  @override
  Future<PracticeState> getSession(String id) async =>
      (await open()).getSession(id);
  @override
  Future<QuizAnswer> submitAnswer(
    String id,
    String question,
    String? option,
  ) async => (await open()).submitAnswer(id, question, option);
  @override
  Future<PracticeState> continueQuestion(String id, String question) async =>
      (await open()).continueQuestion(id, question);
  @override
  Future<PracticeState> completeSession(String id) async =>
      (await open()).completeSession(id);
  @override
  Future<PracticeResult> getResult(String id) async =>
      (await open()).getResult(id);
}
