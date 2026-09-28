import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_use_cases.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String databasePath;
  late Database database;
  late SqliteContentRepository repository;
  const package = B0ContentPackage(EntityIdGenerator());

  Future<void> open() async {
    database = await MigrationRunner(appMigrations)
        .open(databaseFactoryFfi, databasePath);
    repository = SqliteContentRepository(database);
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_b0_content_');
    databasePath = path.join(directory.path, 'content.sqlite3');
    await open();
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test(
    'atomic B0 import publishes exact scope and remains idempotent',
    () async {
      await package.install(repository);
      final version = await repository.currentVersion();
      expect(version?.id, B0ContentIds.version);
      expect(version?.label, B0ContentPackage.releaseLabel);
      expect(
        await repository.publishedCountByVersion(B0ContentIds.version),
        19,
      );
      final countByKind = <ContentKind, int>{
        ContentKind.lesson: 1,
        ContentKind.vocabulary: 6,
        ContentKind.grammar: 2,
        ContentKind.kanji: 2,
        ContentKind.exampleSentence: 5,
        ContentKind.question: 3,
      };
      for (final entry in countByKind.entries) {
        expect(
          (await repository.currentPublished(entry.key)).length,
          entry.value,
        );
      }
      expect(await repository.currentPublished(ContentKind.kana), isEmpty);

      final sources = await database.query('source_references');
      expect(sources, hasLength(17));
      expect(
        sources.every(
          (source) =>
              source['review_status'] == 'approved' &&
              source['content_usage_status'] == 'reference-only' &&
              !(source['source_url'] as String).contains('goo.ne.jp'),
        ),
        isTrue,
      );
      final lesson = await repository.currentPublishedByContentId(
        B0ContentIds.lesson,
      );
      expect(lesson, isA<LessonContent>());
      expect(
        await repository.sourceIdsForRevision(lesson!.revision.id),
        hasLength(17),
      );

      final query = SqliteN5LessonRepository(() async => repository);
      final list = await ListN5Lessons(query)();
      expect(list, hasLength(1));
      expect(list.single.title.surface, 'L01 — 身分／自我介紹');
      final detail = await GetN5Lesson(query)(list.single.contentId);
      expect(detail, isNotNull);
      expect(detail!.vocabulary, hasLength(6));
      expect(detail.grammar, hasLength(2));
      expect(detail.kanji.map((item) => item.character), ['人', '学']);
      expect(detail.examples, hasLength(5));
      expect(detail.lesson.sections[2].body.surface, contains('さん'));
      expect(detail.lesson.sections.map((section) => section.title.surface), [
        'Learning Goal',
        'Step 1 — Vocabulary',
        'Support Expression Note — さん',
        'Step 2 — G01',
        'Step 3 — Original G01 Examples',
        'Step 4 — G02',
        'Step 5 — Very Basic Response',
        'Step 6 — Mini Comprehension',
        'Step 7 — Summary / Review Point',
      ]);
      expect(
        detail.examplesAfterSection[B0ContentIds.g01ExamplesSectionOrdinal]!
            .map((item) => item.sentence.surface),
        ['わたしはミオです。', 'ミオさんは学生です。', 'レンさんは日本人です。'],
      );
      expect(
        detail.examplesAfterSection[B0ContentIds.g02ExamplesSectionOrdinal]!
            .map((item) => item.sentence.surface),
        ['ミオさんは学生ですか。', 'レンさんは日本人ですか。'],
      );

      final mini = detail.lesson.sections[7].body;
      expect(mini.surface, '''人物卡
姓名　名前：ミオ
身分　学生
國籍　日本人
語言　日本語

ミオ的身分是什麼？ → 学生
人物卡中表示「日語」的是哪個詞？ → 日本語
這裡只要求辨識資訊，不新增「國籍是～」「會說～」等後續句型。''');
      mini.validate();
      expect(
        mini.segments
            .where((segment) => segment.surface == '名前')
            .map((segment) => segment.reading),
        ['なまえ'],
      );
      expect(
        mini.segments
            .where((segment) => segment.surface == 'ミオ')
            .map((segment) => segment.reading),
        [null, null],
      );
      expect(
        mini.segments
            .where((segment) => segment.surface == '学生')
            .map((segment) => segment.reading),
        ['がくせい', 'がくせい'],
      );
      expect(
        mini.segments
            .where((segment) => segment.surface == '日本人')
            .map((segment) => segment.reading),
        ['にほんじん'],
      );
      expect(
        mini.segments
            .where((segment) => segment.surface == '日本語')
            .map((segment) => segment.reading),
        ['にほんご', 'にほんご'],
      );

      final readings = {
        for (final item in detail.vocabulary)
          item.written.surface: item.written.segments.single.reading,
      };
      expect(readings, {
        'わたし': null,
        '人': 'ひと',
        '名前': 'なまえ',
        '学生': 'がくせい',
        '日本人': 'にほんじん',
        '日本語': 'にほんご',
      });
      final example = detail.examples[1].sentence;
      expect(example.surface, 'ミオさんは学生です。');
      expect(example.segments.map((segment) => segment.surface), [
        'ミオ',
        'さん',
        'は',
        '学生',
        'です',
        '。',
      ]);
      expect(example.segments[3].reading, 'がくせい');
      for (final item in detail.examples) {
        item.sentence.validate();
      }

      final expectedOptions = [
        ['ミオさんは学生です。', 'ミオさんは学生ですか。', 'レンさんは学生です。', 'ミオさんは日本人です。'],
        ['レンさんは日本人ですか。', 'レンさんは日本人です。', 'ミオさんは日本人ですか。', 'レンさんは学生ですか。'],
        ['学生', '日本人', '日本語', '名前'],
      ];
      final expectedPrompts = [
        '哪一句表示「Mio 是學生」？',
        '如果要確認「Ren 是不是日本人」，哪一句最合適？',
        '姓名　名前：ミオ\n身分　学生\n國籍　日本人\n語言　日本語\n\n根據人物卡，哪一項是 Mio 的「身分」？',
      ];
      expect(
        await repository.currentPublished(ContentKind.question),
        hasLength(3),
      );
      for (var index = 0; index < B0ContentIds.questions.length; index++) {
        final question = await repository.currentPublishedByContentId(
          B0ContentIds.questions[index],
        ) as QuestionContent;
        expect(question.options, hasLength(4));
        expect(question.prompt.surface, expectedPrompts[index]);
        expect(
          question.options.map((option) => option.content.surface),
          expectedOptions[index],
        );
        expect(question.readingAidPolicy, ReadingAidPolicy.inherit);
        expect(
          question.correctOptionId,
          B0ContentIds.questionOptions[index][0],
        );
        expect(
          question.options
              .singleWhere((option) => option.id == question.correctOptionId)
              .ordinal,
          0,
        );
        expect(question.explanation, isNotEmpty);
        question.prompt.validate();
        for (final option in question.options) {
          option.content.validate();
        }
      }
      final card = (await repository.currentPublishedByContentId(
        B0ContentIds.questions[2],
      ) as QuestionContent).prompt;
      expect(card.surface, contains('根據人物卡，哪一項是 Mio 的「身分」？'));
      expect(
        card.segments
            .where((segment) => segment.reading != null)
            .map((segment) => segment.reading),
        ['なまえ', 'がくせい', 'にほんじん', 'にほんご'],
      );
      expect(
        card.segments.singleWhere((segment) => segment.surface == 'ミオ').reading,
        isNull,
      );

      await database.close();
      await open();
      await package.install(repository);
      expect((await database.query('content_versions')), hasLength(1));
      expect((await database.query('source_references')), hasLength(17));
      expect(
        await repository.publishedCountByVersion(B0ContentIds.version),
        19,
      );
    },
  );

  test('normal read excludes a draft even in the current release', () async {
    await package.install(repository);
    const ids = EntityIdGenerator();
    final now = DateTime.now().toUtc();
    final contentId = ids.generate();
    final draft = VocabularyContent(
      revision: ContentRevision(
        id: ids.generate(),
        contentId: contentId,
        contentVersionId: B0ContentIds.version,
        kind: ContentKind.vocabulary,
        reviewStatus: ContentReviewStatus.draft,
        createdBy: 'test',
        updatedBy: 'test',
        createdAt: now,
        updatedAt: now,
      ),
      written: ReadingText(
        id: ids.generate(),
        surface: 'fixture',
        segments: [
          ReadingSegment(id: ids.generate(), ordinal: 0, surface: 'fixture'),
        ],
      ),
      meaning: 'fixture',
    );
    await repository.insertDraft(draft);
    expect(await repository.currentPublishedByContentId(contentId), isNull);
  });
}
