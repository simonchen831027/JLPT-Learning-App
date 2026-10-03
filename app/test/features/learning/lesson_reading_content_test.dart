import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/presentation/lesson_reading_content.dart';
import 'package:jlpt_learning_app/features/learning/presentation/lesson_section_presentation_policy.dart';
import 'package:jlpt_learning_app/features/learning/presentation/reading_line.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late Database database;
  late N5LessonDetail detail;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_lesson_hierarchy_');
    database = await MigrationRunner(appMigrations)
        .open(databaseFactoryFfi, path.join(directory.path, 'lesson.sqlite3'));
    final content = SqliteContentRepository(database);
    await const B0ContentPackage(EntityIdGenerator()).install(content);
    final lessons = SqliteN5LessonRepository(() async => content);
    detail = (await lessons.getLesson(
      (await lessons.listLessons()).single.contentId,
    ))!;
  });
  tearDownAll(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('mapping matches canonical identity and falls back across release/lesson/ordinal', () {
    expect(
      LessonSectionPresentationPolicy.contentVersionId,
      B0ContentIds.version,
    );
    expect(
      LessonSectionPresentationPolicy.lessonContentId,
      B0ContentIds.lesson,
    );
    final revision = detail.lesson.revision;
    expect(LessonSectionPresentationPolicy.resolve(revision, 2), (
      category: '補充',
      supplementary: true,
    ));
    expect(LessonSectionPresentationPolicy.resolve(revision, 1), (
      category: '字彙',
      supplementary: false,
    ));
    for (final ordinal in [-1, 9, 100]) {
      expect(LessonSectionPresentationPolicy.resolve(revision, ordinal), (
        category: null,
        supplementary: false,
      ));
    }
    for (final identity in [
      (version: B0ContentIds.previousVersion, lesson: B0ContentIds.lesson),
      (version: 'future-release', lesson: B0ContentIds.lesson),
      (version: B0ContentIds.version, lesson: 'another-lesson'),
    ]) {
      final other = ContentRevision(
        id: revision.id,
        contentId: identity.lesson,
        contentVersionId: identity.version,
        kind: revision.kind,
        reviewStatus: revision.reviewStatus,
        createdBy: revision.createdBy,
        updatedBy: revision.updatedBy,
        createdAt: revision.createdAt,
        updatedAt: revision.updatedAt,
      );
      expect(LessonSectionPresentationPolicy.resolve(other, 2), (
        category: null,
        supplementary: false,
      ));
    }
    // The role resolver has no title or generated section-id input.
  });

  Future<void> pump(
    WidgetTester tester,
    double width,
    double scale, {
    N5LessonDetail? value,
    List<Widget>? trailing,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
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
          body: trailing == null
              ? LessonReadingContent(detail: value ?? detail)
              : LessonReadingContent(
                  detail: value ?? detail,
                  trailing: trailing,
                ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder line(ReadingText value) => find.byWidgetPredicate(
    (w) => w is ReadingLine && identical(w.value, value),
  );
  Finder text(String value) => find.text(value, findRichText: true);

  testWidgets(
    'default and explicit empty trailing preserve complete Lesson layout without controls or spacing',
    (tester) async {
      await pump(tester, 390, 1);
      final originalLines = tester
          .widgetList<ReadingLine>(find.byType(ReadingLine))
          .map((w) => w.value)
          .toList();
      final originalRects = [
        for (final value in originalLines) tester.getRect(line(value)),
      ];
      final originalText = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data ?? w.textSpan!.toPlainText())
          .toList();
      expect(
        tester
            .widget<LessonReadingContent>(find.byType(LessonReadingContent))
            .trailing,
        isEmpty,
      );
      expect(
        find.byWidgetPredicate((w) => w is ButtonStyleButton),
        findsNothing,
      );
      await pump(tester, 390, 1, trailing: const []);
      expect(
        tester
            .widgetList<ReadingLine>(find.byType(ReadingLine))
            .map((w) => w.value),
        orderedEquals(originalLines),
      );
      expect([
        for (final value in originalLines) tester.getRect(line(value)),
      ], originalRects);
      expect(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((w) => w.data ?? w.textSpan!.toPlainText()),
        originalText,
      );
      expect(
        find.byWidgetPredicate((w) => w is ButtonStyleButton),
        findsNothing,
      );
      expect(find.byType(Scrollable), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'generic trailing is after final reference in the same selection and scroll flow',
    (tester) async {
      const trailing = Text(
        'Generic trailing sentinel',
        key: Key('generic-trailing'),
      );
      await pump(tester, 390, 1.3, trailing: const [trailing]);
      final target = find.byKey(const Key('generic-trailing'));
      expect(target, findsOneWidget);
      expect(
        tester.getTopLeft(target).dy,
        greaterThan(tester.getBottomLeft(text(detail.kanji.last.meaning)).dy),
      );
      expect(
        find.ancestor(of: target, matching: find.byType(SelectionArea)),
        findsOneWidget,
      );
      expect(
        find.ancestor(of: target, matching: find.byType(SingleChildScrollView)),
        findsOneWidget,
      );
      expect(find.byType(Scrollable), findsOneWidget);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      expect(target.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 390.0, 720.0, 1280.0, 1920.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets(
        'Lesson widget simulation width=$width scale=$scale preserves hierarchy and content',
        (tester) async {
          await pump(tester, width, scale);
          expect(tester.takeException(), isNull);
          expect(line(detail.lesson.title), findsOneWidget);
          final titleRect = tester.getRect(line(detail.lesson.title));
          expect(titleRect.width, lessThanOrEqualTo(720));
          expect(
            titleRect.left,
            closeTo(width >= 784 ? (width - 720) / 2 : 16, .1),
          );
          final expected = [
            detail.lesson.title,
            for (final section in detail.lesson.sections) ...[
              section.title,
              section.body,
              for (final example
                  in detail.examplesAfterSection[section.ordinal] ?? [])
                example.sentence,
            ],
            for (final item in detail.vocabulary) item.written,
            for (final item in detail.grammar) item.pattern,
            for (final item in detail.kanji) item.context,
          ];
          final rendered = tester
              .widgetList<ReadingLine>(find.byType(ReadingLine))
              .toList();
          expect(rendered.map((w) => w.value), orderedEquals(expected));
          expect(rendered.every((w) => w.showReadings), isTrue);
          for (final item in expected) {
            final rect = tester.getRect(line(item));
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(width + .1));
          }
          for (var i = 1; i < detail.lesson.sections.length; i++) {
            expect(
              tester.getTopLeft(line(detail.lesson.sections[i].title)).dy,
              greaterThan(
                tester.getTopLeft(line(detail.lesson.sections[i - 1].title)).dy,
              ),
            );
          }
          for (final label in [
            '學習目標',
            '重點複習',
            '字彙',
            '句型',
            '例句',
            '問句',
            '回答',
            '小練習',
            '補充',
            '單字整理',
            '句型整理',
            '漢字整理',
          ]) {
            expect(text(label), findsOneWidget);
          }
          for (final label in [
            'Vocabulary',
            'Grammar',
            'Kanji',
            'Step 1',
            'Step 2',
          ]) {
            expect(text(label), findsNothing);
          }
          expect(detail.vocabulary.length, 6);
          expect(detail.grammar.length, 2);
          expect(detail.kanji.length, 2);
          expect(detail.examples.length, 5);
          expect(detail.examplesAfterSection[4]!.length, 3);
          expect(detail.examplesAfterSection[5]!.length, 2);
          for (final example in detail.examples) {
            expect(text(example.translation), findsOneWidget);
          }
          final vocabularyBody = line(detail.lesson.sections[1].body);
          for (final reading in ['ひと', 'なまえ', 'がくせい', 'にほんじん', 'にほんご']) {
            expect(
              find.descendant(of: vocabularyBody, matching: text(reading)),
              findsWidgets,
            );
          }
          final supplementTitle = line(detail.lesson.sections[2].title);
          final supplement = find.ancestor(
            of: supplementTitle,
            matching: find.byWidgetPredicate(
              (w) =>
                  w is DecoratedBox &&
                  w.decoration is BoxDecoration &&
                  (w.decoration as BoxDecoration).borderRadius ==
                      BorderRadius.circular(12),
            ),
          );
          expect(supplement, findsOneWidget);
          expect(
            find.descendant(
              of: supplement,
              matching: find.byType(ButtonStyleButton),
            ),
            findsNothing,
          );
          expect(
            find.descendant(of: supplement, matching: find.byType(InkWell)),
            findsNothing,
          );
          expect(
            tester.getRect(supplement).height,
            greaterThan(
              tester.getRect(line(detail.lesson.sections[2].body)).height,
            ),
          );
          expect(find.byType(Scrollable), findsOneWidget);
          expect(
            tester.widget<Scrollable>(find.byType(Scrollable)).axisDirection,
            AxisDirection.down,
          );
          expect(find.byType(Card), findsNothing);
        },
      );
    }
  }

  testWidgets(
    'production selection copies canonical surfaces without ruby; headings expose semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await pump(tester, 1280, 1);
        expect(
          tester
              .getSemantics(line(detail.lesson.title))
              .flagsCollection
              .isHeader,
          isTrue,
        );
        for (final section in detail.lesson.sections) {
          expect(
            tester.getSemantics(line(section.title)).flagsCollection.isHeader,
            isTrue,
          );
        }
        for (final label in ['單字整理', '句型整理', '漢字整理']) {
          expect(
            tester.getSemantics(text(label)).flagsCollection.isHeader,
            isTrue,
          );
        }
        expect(
          tester.getSemantics(text('補充')).flagsCollection.isFocused,
          Tristate.none,
        );
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        final area = tester.state<SelectionAreaState>(
          find.byType(SelectionArea),
        );
        area.selectableRegion.selectAll();
        await tester.pump();
        area.selectableRegion.contextMenuButtonItems
            .singleWhere((item) => item.type == ContextMenuButtonType.copy)
            .onPressed!();
        await tester.pump();
        expect(copied, isNotNull);
        for (final section in detail.lesson.sections) {
          expect(copied, contains(section.title.surface));
          expect(copied, contains(section.body.surface));
        }
        final expectedPlain = [
          detail.lesson.title.surface,
          for (final section in detail.lesson.sections) ...[
            if (LessonSectionPresentationPolicy.resolve(
                  detail.lesson.revision,
                  section.ordinal,
                ).category
                case final String label when label != section.title.surface)
              label,
            section.title.surface,
            section.body.surface,
            for (final example
                in detail.examplesAfterSection[section.ordinal] ?? []) ...[
              example.sentence.surface,
              example.translation,
            ],
          ],
          '單字整理',
          for (final item in detail.vocabulary) ...[
            item.written.surface,
            item.meaning,
          ],
          '句型整理',
          for (final item in detail.grammar) ...[
            item.pattern.surface,
            item.explanation,
          ],
          '漢字整理',
          for (final item in detail.kanji) ...[
            item.character,
            item.context.surface,
            item.meaning,
          ],
        ].join();
        // Ignore layout boundary/soft-wrap whitespace for whole-page order;
        // explicit stored section newlines were checked verbatim above.
        String normalize(String text) => text.replaceAll(RegExp(r'\s+'), '');
        expect(normalize(copied!), normalize(expectedPlain));
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'unknown release retains all canonical content with generic core treatment',
    (tester) async {
      final r = detail.lesson.revision;
      final unknown = N5LessonDetail(
        lesson: LessonContent(
          revision: ContentRevision(
            id: r.id,
            contentId: r.contentId,
            contentVersionId: 'future-release',
            kind: r.kind,
            reviewStatus: r.reviewStatus,
            createdBy: r.createdBy,
            updatedBy: r.updatedBy,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
          title: detail.lesson.title,
          sections: detail.lesson.sections,
        ),
        vocabulary: detail.vocabulary,
        grammar: detail.grammar,
        kanji: detail.kanji,
        examples: detail.examples,
        examplesAfterSection: detail.examplesAfterSection,
      );
      await pump(tester, 390, 2, value: unknown);
      for (final section in detail.lesson.sections) {
        expect(line(section.title), findsOneWidget);
        expect(line(section.body), findsOneWidget);
      }
      expect(text('補充'), findsNothing);
      expect(text('字彙'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
