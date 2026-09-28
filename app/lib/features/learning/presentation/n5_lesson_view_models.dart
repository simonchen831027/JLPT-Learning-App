import 'package:flutter/foundation.dart';

import '../domain/n5_lesson_repository.dart';
import '../domain/n5_lesson_use_cases.dart';

enum LessonLoadStatus { loading, ready, empty, failed }

final class N5LessonListViewModel extends ChangeNotifier {
  N5LessonListViewModel(this._list);
  final ListN5Lessons _list;
  bool _disposed = false;
  LessonLoadStatus status = LessonLoadStatus.loading;
  List<N5LessonSummary> lessons = const [];

  Future<void> load() async {
    status = LessonLoadStatus.loading;
    notifyListeners();
    try {
      final result = await _list();
      if (_disposed) return;
      lessons = result;
      status = lessons.isEmpty
          ? LessonLoadStatus.empty
          : LessonLoadStatus.ready;
    } catch (_) {
      if (_disposed) return;
      status = LessonLoadStatus.failed;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

final class N5LessonDetailViewModel extends ChangeNotifier {
  N5LessonDetailViewModel(this._get, this._contentId);
  final GetN5Lesson _get;
  final String _contentId;
  bool _disposed = false;
  LessonLoadStatus status = LessonLoadStatus.loading;
  N5LessonDetail? detail;

  Future<void> load() async {
    status = LessonLoadStatus.loading;
    notifyListeners();
    try {
      final result = await _get(_contentId);
      if (_disposed) return;
      detail = result;
      status = detail == null ? LessonLoadStatus.empty : LessonLoadStatus.ready;
    } catch (_) {
      if (_disposed) return;
      status = LessonLoadStatus.failed;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
