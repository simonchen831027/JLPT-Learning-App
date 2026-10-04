import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jlpt_learning_app/app/app.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/database/sqlite_local_store.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/home/data/local_startup_repository.dart';
import 'package:jlpt_learning_app/features/home/domain/initialize_app.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_use_cases.dart';
import 'package:jlpt_learning_app/features/settings/data/sqlite_app_setting_repository.dart';
import 'package:jlpt_learning_app/features/settings/domain/app_setting_use_cases.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native storage opens and reopens with an offline shell', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp(
      'jlpt_shell_smoke_',
    );
    debugPrint('Isolated shell smoke database: ${directory.path}');
    final DatabaseFactory factory;
    if (Platform.isWindows) {
      sqfliteFfiInit();
      factory = databaseFactoryFfi;
    } else if (Platform.isAndroid || Platform.isIOS) {
      factory = mobile.databaseFactory;
    } else {
      throw UnsupportedError('Unsupported application platform.');
    }
    final store = SqliteLocalStore(
      openDatabase: () =>
          MigrationRunner(appMigrations)
              .open(factory, path.join(directory.path, 'shell.sqlite3')),
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
    expect(await (await store.database).getVersion(), 4);
    final settingsRepository = SqliteAppSettingRepository(await store.database);
    final defaults = await GetAppSettings(settingsRepository)();
    expect(defaults.showFurigana, isTrue);
    expect(defaults.feedbackSound, isTrue);
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
    final lesson = (await lessons.listLessons()).single;
    expect(find.text(lesson.title.surface), findsOneWidget);
    await tester.tap(find.text(lesson.title.surface));
    await tester.pumpAndSettle();
    expect(find.text('稱呼別人時的さん', findRichText: true), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('讀讀姓名與身分的例句', findRichText: true),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('讀讀姓名與身分的例句', findRichText: true), findsOneWidget);
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
    await SetShowFurigana(settingsRepository)(false);
    await SetFeedbackSound(settingsRepository)(false);
    await tester.pumpWidget(const SizedBox.shrink());
    await store.close();
    await tester.pumpWidget(app);
    await store.initialize();
    await tester.pumpAndSettle();
    expect(find.text('從 N5 開始，一步一步學習'), findsOneWidget);
    final savedSettings = await GetAppSettings(
      SqliteAppSettingRepository(await store.database),
    )();
    expect(savedSettings.showFurigana, isFalse);
    expect(savedSettings.feedbackSound, isFalse);
    expect(
      await (await store.database).query('source_references'),
      hasLength(17),
    );
  });
}
