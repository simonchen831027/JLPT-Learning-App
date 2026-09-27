import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jlpt_learning_app/app/app.dart';
import 'package:jlpt_learning_app/core/database/sqlite_local_store.dart';
import 'package:jlpt_learning_app/features/home/data/local_startup_repository.dart';
import 'package:jlpt_learning_app/features/home/domain/initialize_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native storage opens and reopens with an offline shell', (
    tester,
  ) async {
    final store = SqliteLocalStore.platform();
    addTearDown(store.close);
    final useCase = InitializeApp(LocalStartupRepository(store));
    await tester.pumpWidget(JlptLearningApp(initializeApp: useCase));
    // 先完成 native I/O，再等待畫面穩定，避免進度指示器使 settle 永遠等待。
    await store.initialize();
    await tester.pumpAndSettle();
    expect(find.text('從 N5 開始，一步一步學習'), findsOneWidget);
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(find.text('你的學習空間'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await store.close();
    await tester.pumpWidget(JlptLearningApp(initializeApp: useCase));
    await store.initialize();
    await tester.pumpAndSettle();
    expect(find.text('從 N5 開始，一步一步學習'), findsOneWidget);
  });
}
