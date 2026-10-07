import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/presentation/lesson_reading_content.dart';
import 'package:jlpt_learning_app/features/learning/presentation/reading_line.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../test/features/learning/reading_line_test.dart' as geometry;

// Optional local evidence destination. No screenshots are created by default.
const _captureDirectory = String.fromEnvironment('READING_CAPTURE_DIRECTORY');

Future<void> capture(WidgetTester tester, String name) async {
  if (_captureDirectory.isEmpty) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('reading-capture')),
  );
  final image = await boundary.toImage(pixelRatio: 1);
  try {
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await Directory(_captureDirectory).create(recursive: true);
    await File(path.join(_captureDirectory, '$name.png')).writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
  } finally {
    image.dispose();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native fonts align ruby and plain glyphs at multiple scales', (
    tester,
  ) async {
    final measurements = <Map<String, Object>>[];
    for (final fontSize in [16.0, 18.0, 24.0, 32.0]) {
      for (final scale in [1.0, 1.8, 2.5]) {
        measurements.add(
          await geometry.verifyNaturalInline(
            tester,
            fontSize: fontSize,
            scale: scale,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    }
    if (_captureDirectory.isNotEmpty) {
      await Directory(_captureDirectory).create(recursive: true);
      await File(
        path.join(_captureDirectory, 'windows-glyph-measurements.json'),
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(measurements));
    }
  });

  testWidgets('native production lesson and mixed reading visual evidence', (
    tester,
  ) async {
    // Isolated canonical fixture; never opens or resets learner storage.
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp(
      'jlpt_ruby_native_',
    );
    final database = await MigrationRunner(appMigrations)
        .open(databaseFactoryFfi, path.join(directory.path, 'lesson.sqlite3'));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await database.close();
      await directory.delete(recursive: true);
    });
    final content = SqliteContentRepository(database);
    await const B0ContentPackage(EntityIdGenerator()).install(content);
    final lessons = SqliteN5LessonRepository(() async => content);
    final detail = (await lessons.getLesson(
      (await lessons.listLessons()).single.contentId,
    ))!;
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: const ValueKey('reading-capture'),
          child: Scaffold(body: LessonReadingContent(detail: detail)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await capture(tester, 'windows-lesson-top');
    await tester.drag(find.byType(Scrollable), const Offset(0, -480));
    await tester.pumpAndSettle();
    await capture(tester, 'windows-lesson-examples');
    expect(tester.takeException(), isNull);

    final value = geometry.readingText([
      ('ミオさんは', null),
      ('学生', 'がくせい'),
      ('です。\n', null),
      ('日本語', 'にほんご'),
      ('を', null),
      ('勉強', 'べんきょう'),
      ('します。\n', null),
      ('明日', 'あす'),
      ('、ごはんを', null),
      ('食', 'た'),
      ('べます。', null),
    ]);
    for (final fontSize in [16.0, 18.0, 24.0]) {
      for (final scale in [1.0, 2.0]) {
        for (final show in [true, false]) {
          await tester.pumpWidget(
            MaterialApp(
              home: RepaintBoundary(
                key: const ValueKey('reading-capture'),
                child: Scaffold(
                  body: MediaQuery(
                    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                    child: SelectionArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: 320,
                            child: ReadingLine(
                              value,
                              showReadings: show,
                              style: TextStyle(fontSize: fontSize, height: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await capture(
            tester,
            'windows-mixed-font-$fontSize-scale-$scale-readings-$show',
          );
          expect(tester.takeException(), isNull);
        }
      }
    }
  }, skip: !Platform.isWindows);
}
