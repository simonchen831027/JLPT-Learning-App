import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jlpt_learning_app/app/app.dart';
import 'package:jlpt_learning_app/core/database/sqlite_local_store.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/home/data/local_startup_repository.dart';
import 'package:jlpt_learning_app/features/home/domain/initialize_app.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_use_cases.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native storage opens and reopens with an offline shell', (
    tester,
  ) async {
    final store = SqliteLocalStore.platform();
    addTearDown(store.close);
    Future<SqliteContentRepository> openContent() async =>
        SqliteContentRepository(await store.database);
    final useCase = InitializeApp(
      LocalStartupRepository(
        store,
        afterInitialize: () async =>
            B0ContentPackage(const EntityIdGenerator())
                .install(await openContent()),
      ),
    );
    final lessons = SqliteN5LessonRepository(openContent);
    // 完成 native bootstrap 後才對 canonical release 作資料庫斷言。
    await store.initialize();
    await B0ContentPackage(const EntityIdGenerator())
        .install(await openContent());
    final app = JlptLearningApp(
      initializeApp: useCase,
      listN5Lessons: ListN5Lessons(lessons),
      getN5Lesson: GetN5Lesson(lessons),
    );
    await tester.pumpWidget(app);
    // 先完成 native I/O，再等待畫面穩定，避免進度指示器使 settle 永遠等待。
    await store.initialize();
    await tester.pumpAndSettle();
    final content = await openContent();
    expect((await content.currentVersion())?.id, B0ContentIds.version);
    expect(await content.publishedCountByVersion(B0ContentIds.version), 19);
    expect(
      await (await store.database).query('source_references'),
      hasLength(17),
    );
    expect(find.text('從 N5 開始，一步一步學習'), findsOneWidget);
    await tester.tap(find.text('N5 課程'));
    await tester.pumpAndSettle();
    expect(find.text('L01 — 身分／自我介紹'), findsOneWidget);
    await tester.tap(find.text('L01 — 身分／自我介紹'));
    await tester.pumpAndSettle();
    expect(find.text('Support Expression Note — さん'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Step 3 — Original G01 Examples'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Step 3 — Original G01 Examples'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('我是 Mio。'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('我是 Mio。'), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(find.text('你的學習空間'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await store.close();
    await tester.pumpWidget(app);
    await store.initialize();
    await tester.pumpAndSettle();
    expect(find.text('從 N5 開始，一步一步學習'), findsOneWidget);
    expect(
      await (await store.database).query('source_references'),
      hasLength(17),
    );
  });
}
