import 'n5_lesson_repository.dart';

final class ListN5Lessons {
  const ListN5Lessons(this._repository);
  final N5LessonRepository _repository;
  Future<List<N5LessonSummary>> call() => _repository.listLessons();
}

final class GetN5Lesson {
  const GetN5Lesson(this._repository);
  final N5LessonRepository _repository;
  Future<N5LessonDetail?> call(String contentId) =>
      _repository.getLesson(contentId);
}
