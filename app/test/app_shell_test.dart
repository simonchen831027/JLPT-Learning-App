import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/app/app.dart';
import 'package:jlpt_learning_app/features/home/domain/initialize_app.dart';
import 'package:jlpt_learning_app/features/home/domain/startup_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_use_cases.dart';

class TestRepository implements StartupRepository {
  Future<void> Function() action = () async {};
  @override
  Future<void> initialize() => action();
}

class EmptyLessons implements N5LessonRepository {
  @override
  Future<List<N5LessonSummary>> listLessons() async => const [];
  @override
  Future<N5LessonDetail?> getLesson(String contentId) async => null;
}

JlptLearningApp testApp(StartupRepository repository) {
  final lessons = EmptyLessons();
  return JlptLearningApp(
    initializeApp: InitializeApp(repository),
    listN5Lessons: ListN5Lessons(lessons),
    getN5Lesson: GetN5Lesson(lessons),
  );
}

void main() {
  testWidgets('phone shows loading, empty content and working navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pending = Completer<void>();
    final repository = TestRepository()..action = () => pending.future;
    await tester.pumpWidget(testApp(repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('從 N5 開始，一步一步學習'), findsOneWidget);
    await tester.tap(find.text('複習'));
    await tester.pumpAndSettle();
    expect(find.text('目前沒有複習項目'), findsOneWidget);
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(find.text('你的學習空間'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop uses a rail and supports larger text', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(testApp(TestRepository()));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(find.text('你的學習空間'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('storage failure shows a safe error and retry recovers', (
    tester,
  ) async {
    final repository = TestRepository()
      ..action = () async => throw StateError('private SQL');
    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();
    expect(find.text('暫時無法開啟'), findsOneWidget);
    expect(find.textContaining('private SQL'), findsNothing);
    repository.action = () async {};
    await tester.tap(find.text('重試'));
    await tester.pumpAndSettle();
    expect(find.text('從 N5 開始，一步一步學習'), findsOneWidget);
  });
}
