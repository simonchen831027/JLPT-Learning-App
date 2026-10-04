import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jlpt_learning_app/app/app.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/database/sqlite_local_store.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/home/data/local_startup_repository.dart';
import 'package:jlpt_learning_app/features/home/domain/initialize_app.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_use_cases.dart';
import 'package:jlpt_learning_app/features/practice/data/deferred_practice_repository.dart';
import 'package:jlpt_learning_app/features/practice/data/sqlite_practice_repository.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:jlpt_learning_app/features/practice/presentation/practice_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Windows offline Practice, persisted feedback resume and explicit Result',
    (tester) async {
      // Isolate smoke-test learning state from the learner's platform database.
      final directory = await Directory.systemTemp.createTemp(
        'jlpt_practice_smoke_',
      );
      debugPrint('Isolated Practice smoke database: ${directory.path}');
      sqfliteFfiInit();
      final store = SqliteLocalStore(
        openDatabase: () => MigrationRunner(appMigrations).open(
          databaseFactoryFfi,
          path.join(directory.path, 'practice.sqlite3'),
        ),
      );
      addTearDown(() async {
        await store.close();
        expect(
          path.isWithin(
            Directory.systemTemp.absolute.path,
            directory.absolute.path,
          ),
          isTrue,
        );
        await directory.delete(recursive: true);
      });
      Future<SqliteContentRepository> content() async =>
          SqliteContentRepository(await store.database);
      final startup = InitializeApp(
        LocalStartupRepository(
          store,
          afterInitialize: () async =>
              B0ContentPackage(const EntityIdGenerator())
                  .install(await content()),
        ),
      );
      final lessons = SqliteN5LessonRepository(content);
      final actions = PracticeActions.fromRepository(
        DeferredPracticeRepository(
          () async => SqlitePracticeRepository(await store.database),
        ),
      );
      final app = JlptLearningApp(
        initializeApp: startup,
        listN5Lessons: ListN5Lessons(lessons),
        getN5Lesson: GetN5Lesson(lessons),
        practiceActions: actions,
      );
      PracticeViewModel model() =>
          tester
                  .widget<ListenableBuilder>(
                    find.byWidgetPredicate(
                      (w) =>
                          w is ListenableBuilder &&
                          w.listenable is PracticeViewModel,
                    ),
                  )
                  .listenable
              as PracticeViewModel;
      Future<void> settle() async {
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (!model().busy) {
            await tester.pumpAndSettle();
            return;
          }
        }
        fail('Native Practice operation did not settle');
      }

      Future<void> tap(String label) async {
        final target = find.widgetWithText(FilledButton, label);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await settle();
      }

      Future<void> enter() async {
        await tester.pumpWidget(app);
        await store.initialize();
        await tester.pumpAndSettle();
        await tester.tap(find.text('N5 課程'));
        await tester.pumpAndSettle();
        final lesson = (await lessons.listLessons()).single;
        await tester.tap(find.text(lesson.title.surface));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('開始練習'),
          400,
          scrollable: find.byType(Scrollable).last,
        );
        await tap('開始練習');
      }

      Future<void> answer({bool wrong = false}) async {
        final question = model().state!.currentQuestion.question;
        final option = question.options.firstWhere(
          (o) => wrong
              ? o.id != question.correctOptionId
              : o.id == question.correctOptionId,
        );
        final semantics = tester.ensureSemantics();
        try {
          await tester.pump();
          final target = find.bySemanticsLabel(option.content.surface);
          await tester.ensureVisible(target);
          await tester.pumpAndSettle();
          await tester.tap(target);
        } finally {
          semantics.dispose();
        }
        await tap('提交答案');
      }

      await enter();
      expect(find.text('題目 1 / 3'), findsOneWidget);
      await tap('提交答案');
      expect(find.text('請先選擇一個答案。'), findsOneWidget);
      expect(await (await store.database).query('quiz_answers'), isEmpty);
      await answer();
      expect(find.text('✓ 答對了'), findsOneWidget);
      final sessionId = model().state!.session.id;
      final revisionId = model().state!.currentQuestion.question.revision.id;
      await tester.pumpWidget(const SizedBox.shrink());
      await store.close();
      await enter();
      expect(model().state!.session.id, sessionId);
      expect(model().state!.currentQuestion.question.revision.id, revisionId);
      expect(find.text('✓ 答對了'), findsOneWidget);
      await tap('下一題');
      expect(find.text('題目 2 / 3'), findsOneWidget);
      await answer(wrong: true);
      expect(find.text('✕ 答錯了'), findsOneWidget);
      await tap('下一題');
      expect(find.text('題目 3 / 3'), findsOneWidget);
      await answer();
      expect(model().state!.session.status, QuizSessionStatus.inProgress);
      await tap('查看本次結果');
      expect(find.text('作答題數：3'), findsOneWidget);
      expect(find.text('答對題數：2'), findsOneWidget);
      expect(find.text('答錯題數：1'), findsOneWidget);
      final resultSession = await actions.read(sessionId);
      expect(resultSession.session.status, QuizSessionStatus.completed);
      await tester.tap(find.widgetWithText(FilledButton, '返回課程'));
      await tester.pumpAndSettle();
      expect(find.text('開始練習'), findsOneWidget);
      final data = await content();
      expect(await data.publishedCountByVersion(B0ContentIds.version), 19);
      expect(
        await (await store.database).query('source_references'),
        hasLength(17),
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
    skip: !Platform.isWindows,
  );
}
