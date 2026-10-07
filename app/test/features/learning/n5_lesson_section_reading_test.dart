import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/presentation/reading_line.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late Database database;
  late ReadingText body;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_f03_');
    database = await MigrationRunner(appMigrations).open(
      databaseFactoryFfi,
      path.join(directory.path, 'section_reading.sqlite3'),
    );
    final content = SqliteContentRepository(database);
    await const B0ContentPackage(EntityIdGenerator()).install(content);
    final lessons = SqliteN5LessonRepository(() async => content);
    final summary = (await lessons.listLessons()).single;
    final detail = (await lessons.getLesson(summary.contentId))!;
    body = detail.lesson.sections
        .singleWhere((section) => section.ordinal == 1)
        .body;
  });

  tearDownAll(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  for (final width in [390.0, 1200.0]) {
    for (final scale in [1.0, 1.8]) {
      for (final showReadings in [true, false]) {
        testWidgets(
          'stored section body width=$width scale=$scale readings=$showReadings',
          (tester) async {
            String? selectedSurface;
            tester.view.physicalSize = Size(width, 1200);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              MaterialApp(
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: SelectionArea(
                      onSelectionChanged: (selection) =>
                          selectedSurface = selection?.plainText,
                      child: ReadingLine(body, showReadings: showReadings),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();

            const expectedReadings = {
              '人': 'ひと',
              '名前': 'なまえ',
              '学生': 'がくせい',
              '日本人': 'にほんじん',
              '日本語': 'にほんご',
            };
            expect({
              for (final segment in body.segments)
                if (segment.reading != null) segment.surface: segment.reading,
            }, expectedReadings);
            final watashi = body.segments.singleWhere(
              (segment) => segment.surface.contains('わたし'),
            );
            expect(watashi.reading, isNull);

            final richText = tester.widget<Text>(
              find.byWidgetPredicate(
                (widget) => widget is Text && widget.textSpan != null,
              ),
            );
            final spans = (richText.textSpan! as TextSpan).children!;
            expect(spans.length, body.segments.length);
            final renderedSurfaces = <String>[];
            for (var index = 0; index < body.segments.length; index++) {
              final segment = body.segments[index];
              final span = spans[index];
              if (showReadings && segment.reading != null) {
                expect(span, isA<WidgetSpan>());
                final ruby = (span as WidgetSpan).child;
                final texts = tester
                    .widgetList<Text>(
                      find.descendant(
                        of: find.byWidget(ruby),
                        matching: find.byType(Text),
                      ),
                    )
                    .toList();
                final reading = texts.first;
                final surface = texts.last;
                expect(reading.data, segment.reading);
                expect(surface.data, segment.surface);
                renderedSurfaces.add(surface.data!);
              } else {
                expect(span, isA<TextSpan>());
                expect((span as TextSpan).text, segment.surface);
                renderedSurfaces.add(span.text!);
              }
            }
            expect(renderedSurfaces.join(), body.surface);
            expect(body.surface, contains('\n'));
            for (final reading in expectedReadings.values) {
              final storedCount = body.segments
                  .where((segment) => segment.reading == reading)
                  .length;
              expect(
                find.text(reading),
                showReadings ? findsNWidgets(storedCount) : findsNothing,
              );
            }
            if (!showReadings) {
              expect(richText.textSpan!.toPlainText(), body.surface);
              expect(spans.whereType<WidgetSpan>(), isEmpty);
            }
            final selection = tester.state<SelectionAreaState>(
              find.byType(SelectionArea),
            );
            selection.selectableRegion.selectAll();
            await tester.pump();
            expect(selectedSurface, body.surface);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
