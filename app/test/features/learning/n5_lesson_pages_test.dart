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
    expect(find.text('自我介紹：姓名與身分'), findsOneWidget);

    await tester.tap(find.text('自我介紹：姓名與身分'));
    await tester.pumpAndSettle();
    expect(find.text('自我介紹：姓名與身分'), findsOneWidget);
    expect(find.text('稱呼別人時的さん', skipOffstage: false), findsOneWidget);
    final detailList = tester.widget<ListView>(find.byType(ListView).last);
    final children =
        (detailList.childrenDelegate as SliverChildListDelegate).children;
    final bodyLines = children.whereType<ReadingLine>().toList();
    expect(
      bodyLines.map((line) => line.value),
      orderedEquals(detail.lesson.sections.map((section) => section.body)),
    );
    expect(bodyLines.every((line) => line.showReadings), isTrue);
    for (final section in detail.lesson.sections) {
      expect(
        children.whereType<Text>().where(
          (text) => text.data == section.body.surface,
        ),
        isEmpty,
      );
    }
    int titleIndex(String title) =>
        children.indexWhere((child) => child is Text && child.data == title);
    const sectionTitles = [
      '學習目標',
      '先認識六個單字',
      '稱呼別人時的さん',
      '用名詞介紹姓名與身分',
      '讀讀姓名與身分的例句',
      '加上か，變成問句',
      '用はい與いいえ回答',
      '看懂一張人物卡',
      '重點複習',
    ];
    expect(
      detail.lesson.sections.map((section) => section.title.surface),
      sectionTitles,
    );
    for (var index = 0; index < sectionTitles.length; index++) {
      expect(titleIndex(sectionTitles[index]), greaterThanOrEqualTo(0));
      if (index > 0) {
        expect(
          titleIndex(sectionTitles[index - 1]),
          lessThan(titleIndex(sectionTitles[index])),
        );
      }
    }
    int exampleIndex(String sentence) => children.indexWhere((child) {
      if (child is! Card || child.child is! ListTile) return false;
      final title = (child.child! as ListTile).title;
      return title is ReadingLine && title.value.surface == sentence;
    });
    expect(titleIndex('用名詞介紹姓名與身分'), lessThan(titleIndex('讀讀姓名與身分的例句')));
    expect(titleIndex('讀讀姓名與身分的例句'), lessThan(exampleIndex('わたしはミオです。')));
    expect(exampleIndex('わたしはミオです。'), lessThan(exampleIndex('ミオさんは学生です。')));
    expect(exampleIndex('ミオさんは学生です。'), lessThan(exampleIndex('レンさんは日本人です。')));
    expect(exampleIndex('レンさんは日本人です。'), lessThan(titleIndex('加上か，變成問句')));
    expect(titleIndex('加上か，變成問句'), lessThan(exampleIndex('ミオさんは学生ですか。')));
    final vocabularyBody = find.byWidgetPredicate(
      (widget) =>
          widget is ReadingLine &&
          widget.value.id == detail.lesson.sections[1].body.id,
    );
    await tester.scrollUntilVisible(
      vocabularyBody,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    for (final reading in ['ひと', 'なまえ', 'がくせい', 'にほんじん', 'にほんご']) {
      expect(
        find.descendant(of: vocabularyBody, matching: find.text(reading)),
        findsWidgets,
      );
    }
    final cardBody = find.byWidgetPredicate(
      (widget) =>
          widget is ReadingLine &&
          widget.value.id == detail.lesson.sections[7].body.id,
    );
    await tester.scrollUntilVisible(
      cardBody,
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(cardBody, findsOneWidget);
    expect(
      tester.widget<ReadingLine>(cardBody).value.surface,
      detail.lesson.sections[7].body.surface,
    );
    final studentVocabulary = find.byWidgetPredicate(
      (widget) =>
          widget is ReadingLine &&
          widget.value.id ==
              detail.vocabulary
                  .singleWhere((item) => item.written.surface == '学生')
                  .written
                  .id,
    );
    await tester.scrollUntilVisible(
      studentVocabulary,
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.descendant(of: studentVocabulary, matching: find.text('がくせい')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
