import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/app/app.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/home/domain/initialize_app.dart';
import 'package:jlpt_learning_app/features/home/domain/startup_repository.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_use_cases.dart';
import 'package:jlpt_learning_app/features/learning/presentation/reading_line.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _ReadyStartup implements StartupRepository {
  @override
  Future<void> initialize() async {}
}

class _LoadedLessons implements N5LessonRepository {
  _LoadedLessons(this.summary, this.detail);
  final N5LessonSummary summary;
  final N5LessonDetail detail;
  @override
  Future<List<N5LessonSummary>> listLessons() async => [summary];
  @override
  Future<N5LessonDetail?> getLesson(String contentId) async =>
      contentId == summary.contentId ? detail : null;
}

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late Database database;
  late N5LessonSummary summary;
  late N5LessonDetail detail;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_b0_ui_');
    database = await MigrationRunner(appMigrations)
        .open(databaseFactoryFfi, path.join(directory.path, 'ui.sqlite3'));
    final content = SqliteContentRepository(database);
    await const B0ContentPackage(EntityIdGenerator()).install(content);
    final sqliteLessons = SqliteN5LessonRepository(() async => content);
    summary = (await sqliteLessons.listLessons()).single;
    detail = (await sqliteLessons.getLesson(summary.contentId))!;
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  testWidgets('Home to N5 to L01 displays approved repository content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lessons = _LoadedLessons(summary, detail);
    await tester.pumpWidget(
      JlptLearningApp(
        initializeApp: InitializeApp(_ReadyStartup()),
        listN5Lessons: ListN5Lessons(lessons),
        getN5Lesson: GetN5Lesson(lessons),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('N5 課程'), findsOneWidget);

    await tester.tap(find.text('N5 課程'));
    await tester.pumpAndSettle();
    expect(find.text('L01 — 身分／自我介紹'), findsOneWidget);

    await tester.tap(find.text('L01 — 身分／自我介紹'));
    await tester.pumpAndSettle();
    expect(find.text('L01 — 身分／自我介紹'), findsOneWidget);
    expect(
      find.text('Support Expression Note — さん', skipOffstage: false),
      findsOneWidget,
    );
    final detailList = tester.widget<ListView>(find.byType(ListView).last);
    final children =
        (detailList.childrenDelegate as SliverChildListDelegate).children;
    int titleIndex(String title) =>
        children.indexWhere((child) => child is Text && child.data == title);
    int exampleIndex(String sentence) => children.indexWhere((child) {
      if (child is! Card || child.child is! ListTile) return false;
      final title = (child.child! as ListTile).title;
      return title is ReadingLine && title.value.surface == sentence;
    });
    expect(
      titleIndex('Step 2 — G01'),
      lessThan(titleIndex('Step 3 — Original G01 Examples')),
    );
    expect(
      titleIndex('Step 3 — Original G01 Examples'),
      lessThan(exampleIndex('わたしはミオです。')),
    );
    expect(exampleIndex('わたしはミオです。'), lessThan(exampleIndex('ミオさんは学生です。')));
    expect(exampleIndex('ミオさんは学生です。'), lessThan(exampleIndex('レンさんは日本人です。')));
    expect(exampleIndex('レンさんは日本人です。'), lessThan(titleIndex('Step 4 — G02')));
    expect(titleIndex('Step 4 — G02'), lessThan(exampleIndex('ミオさんは学生ですか。')));
    await tester.scrollUntilVisible(
      find.textContaining('人物卡'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('人物卡'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('がくせい'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('がくせい'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
