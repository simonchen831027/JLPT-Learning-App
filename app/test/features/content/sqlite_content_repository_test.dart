import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  const ids = EntityIdGenerator();
  final createdAt = DateTime.utc(2024, 1, 2, 3, 4, 5);

  ReadingText reading(String surface, List<(String, String?)> parts) =>
      ReadingText(
        id: ids.generate(),
        surface: surface,
        segments: [
          for (var index = 0; index < parts.length; index++)
            ReadingSegment(
              id: ids.generate(),
              ordinal: index,
              surface: parts[index].$1,
              reading: parts[index].$2,
            ),
        ],
      );

  ContentRevision revision(
    ContentKind kind,
    String contentId,
    String versionId,
  ) => ContentRevision(
    id: ids.generate(),
    contentId: contentId,
    contentVersionId: versionId,
    kind: kind,
    reviewStatus: ContentReviewStatus.draft,
    createdBy: 'fixture-author',
    updatedBy: 'fixture-author',
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  SourceReference source(
    String name, {
    SourceReviewStatus reviewStatus = SourceReviewStatus.approved,
    ContentUsageStatus usageStatus = ContentUsageStatus.originalContent,
  }) => SourceReference(
    id: ids.generate(),
    sourceName: name,
    contentUsageStatus: usageStatus,
    reviewStatus: reviewStatus,
    createdAt: createdAt,
    updatedAt: createdAt,
  );

  late Directory directory;
  late String databasePath;
  late Database database;
  late SqliteContentRepository repository;

  Future<void> open() async {
    database = await MigrationRunner(appMigrations)
        .open(databaseFactoryFfi, databasePath);
    repository = SqliteContentRepository(database);
  }

  Future<VocabularyContent> reviewedVocabulary(
    List<SourceReference> sources,
  ) async {
    final versionId = ids.generate();
    await repository.insertVersion(
      ContentVersion(id: versionId, label: versionId, createdAt: createdAt),
    );
    final body = VocabularyContent(
      revision: revision(ContentKind.vocabulary, ids.generate(), versionId),
      written: reading('fixture', [('fixture', null)]),
      meaning: 'synthetic meaning',
    );
    for (final reference in sources) {
      await repository.insertSource(reference);
    }
    await repository.insertDraft(
      body,
      sourceIds: [for (final reference in sources) reference.id],
    );
    await repository.markReviewed(body.revision.id, 'reviewer', createdAt);
    return body;
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_content_repo_');
    databasePath = path.join(directory.path, 'content.sqlite3');
    await open();
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test(
    'release, stable logical identity, lesson and sources round-trip',
    () async {
      final version1 = ContentVersion(
        id: ids.generate(),
        label: 'fixture-1',
        createdAt: createdAt,
      );
      final version2 = ContentVersion(
        id: ids.generate(),
        label: 'fixture-2',
        createdAt: createdAt,
      );
      await repository.insertVersion(version1);
      await repository.insertVersion(version2);
      expect(
        (await repository.getVersion(version1.id))!.createdAt.isUtc,
        isTrue,
      );

      final original = source('Original fixture');
      final review = source('Review fixture');
      await repository.insertSource(original);
      await repository.insertSource(review);
      expect(
        (await repository.getSource(original.id))!.sourceName,
        'Original fixture',
      );

      final contentId = ids.generate();
      LessonContent lesson(String versionId, String titleText) => LessonContent(
        revision: revision(ContentKind.lesson, contentId, versionId),
        title: reading(titleText, [(titleText, null)]),
        sections: [
          LessonSection(
            id: ids.generate(),
            ordinal: 0,
            title: reading('Section', [('Section', null)]),
            body: reading('日本語を', [('日本語', 'にほんご'), ('を', null)]),
          ),
        ],
      );

      final first = lesson(version1.id, 'First lesson');
      final second = lesson(version2.id, 'Revised lesson');
      await repository.insertDraft(first, sourceIds: [original.id, review.id]);
      await repository.insertDraft(second, sourceIds: [original.id]);
      expect(first.revision.contentId, second.revision.contentId);
      expect(first.revision.id, isNot(second.revision.id));
      expect(first.title.id, isNot(second.title.id));
      final readingOwners = await database.query(
        'reading_texts',
        columns: ['owner_revision_id'],
        where: 'id IN (?, ?)',
        whereArgs: [first.title.id, second.title.id],
      );
      expect(readingOwners.map((row) => row['owner_revision_id']).toSet(), {
        first.revision.id,
        second.revision.id,
      });
      expect(
        await repository.sourceIdsForRevision(first.revision.id),
        containsAll([original.id, review.id]),
      );
      expect(await repository.sourceIdsForRevision(second.revision.id), [
        original.id,
      ]);

      final restored =
          (await repository.getRevision(first.revision.id))! as LessonContent;
      expect(restored.revision.contentVersionId, version1.id);
      expect(restored.revision.createdAt.isUtc, isTrue);
      expect(restored.revision.createdAt, createdAt);
      expect(restored.title.surface, 'First lesson');
      expect(restored.sections.single.title.surface, 'Section');
      expect(restored.sections.single.body.segments.map((s) => s.surface), [
        '日本語',
        'を',
      ]);
      expect(restored.sections.single.body.segments.map((s) => s.reading), [
        'にほんご',
        null,
      ]);
      final row = (await database.query(
        'content_revisions',
        where: 'id = ?',
        whereArgs: [first.revision.id],
      )).single;
      expect(row['id'], isA<String>());
      expect(
        row['id'],
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(row['created_at'], '2024-01-02T03:04:05.000Z');

      await database.close();
      await open();
      expect(
        (await repository.getRevision(second.revision.id))!.revision.contentId,
        contentId,
      );
      expect(
        await repository.sourceIdsForRevision(first.revision.id),
        hasLength(2),
      );

      await repository.markReviewed(first.revision.id, 'reviewer', createdAt);
      await repository.markReviewed(second.revision.id, 'reviewer', createdAt);
      await repository.publish(first.revision.id, 'publisher', createdAt);
      await repository.publish(second.revision.id, 'publisher', createdAt);
      await repository.setCurrentVersion(version1.id);
      expect(
        (await repository.currentPublished(ContentKind.lesson))
            .single
            .revision
            .id,
        first.revision.id,
      );
      await repository.setCurrentVersion(version2.id);
      expect(
        (await repository.currentPublished(ContentKind.lesson))
            .single
            .revision
            .id,
        second.revision.id,
      );
      await repository.withdraw(second.revision.id, 'reviewer', createdAt);
      expect(await repository.currentPublished(ContentKind.lesson), isEmpty);
    },
  );

  test(
    'vocabulary, grammar, kanji, kana and example sentence round-trip',
    () async {
      final versionId = ids.generate();
      await repository.insertVersion(
        ContentVersion(id: versionId, label: 'fixture', createdAt: createdAt),
      );
      final vocabulary = VocabularyContent(
        revision: revision(ContentKind.vocabulary, ids.generate(), versionId),
        written: reading('今日', [('今日', 'きょう')]),
        meaning: 'today',
      );
      final grammar = GrammarContent(
        revision: revision(ContentKind.grammar, ids.generate(), versionId),
        pattern: reading('です', [('です', null)]),
        explanation: 'Synthetic explanation',
      );
      final kanji = KanjiContent(
        revision: revision(ContentKind.kanji, ids.generate(), versionId),
        character: '日',
        context: reading('日本', [('日本', 'にほん')]),
        meaning: 'sun',
      );
      final kana = KanaContent(
        revision: revision(ContentKind.kana, ids.generate(), versionId),
        scriptType: KanaScriptType.hiragana,
        writtenKana: 'あ',
        pronunciation: 'あ',
        readingReference: 'あ',
        learningAvailable: true,
        practiceAvailable: false,
      );
      final sentence = ExampleSentenceContent(
        revision: revision(
          ContentKind.exampleSentence,
          ids.generate(),
          versionId,
        ),
        sentence: reading('今日は晴れ', [('今日', 'きょう'), ('は', null), ('晴れ', 'はれ')]),
        translation: 'Synthetic translation',
      );
      for (final body in [vocabulary, grammar, kanji, kana, sentence]) {
        await repository.insertDraft(body);
      }
      expect(
        (await repository.getRevision(vocabulary.revision.id))!
            as VocabularyContent,
        isA<VocabularyContent>(),
      );
      expect(
        ((await repository.getRevision(vocabulary.revision.id))!
                as VocabularyContent)
            .written
            .segments
            .single
            .reading,
        'きょう',
      );
      expect(
        ((await repository.getRevision(grammar.revision.id))! as GrammarContent)
            .explanation,
        'Synthetic explanation',
      );
      expect(
        ((await repository.getRevision(kanji.revision.id))! as KanjiContent)
            .context
            .surface,
        '日本',
      );
      final restoredKana =
          (await repository.getRevision(kana.revision.id))! as KanaContent;
      expect(restoredKana.scriptType, KanaScriptType.hiragana);
      expect(restoredKana.writtenKana, 'あ');
      expect(restoredKana.readingReference, 'あ');
      expect(restoredKana.learningAvailable, isTrue);
      expect(restoredKana.practiceAvailable, isFalse);
      expect(
        ((await repository.getRevision(sentence.revision.id))!
                as ExampleSentenceContent)
            .sentence
            .segments
            .map((s) => s.ordinal),
        [0, 1, 2],
      );
    },
  );

  test(
    'single-choice answer uses an option ID and keeps offline explanation',
    () async {
      final versionId = ids.generate();
      await repository.insertVersion(
        ContentVersion(id: versionId, label: 'fixture', createdAt: createdAt),
      );
      final rightId = ids.generate();
      final question = QuestionContent(
        revision: revision(ContentKind.question, ids.generate(), versionId),
        prompt: reading('正しいもの', [('正しい', 'ただしい'), ('もの', null)]),
        readingAidPolicy: ReadingAidPolicy.hide,
        explanation: 'Synthetic offline explanation',
        options: [
          QuestionOption(
            id: ids.generate(),
            ordinal: 0,
            content: reading('違う', [('違う', 'ちがう')]),
          ),
          QuestionOption(
            id: rightId,
            ordinal: 1,
            content: reading('正しい', [('正しい', 'ただしい')]),
          ),
        ],
        correctOptionId: rightId,
      );
      await repository.insertDraft(question);
      final restored =
          (await repository.getRevision(question.revision.id))!
              as QuestionContent;
      expect(restored.correctOptionId, rightId);
      expect(restored.options.map((o) => o.ordinal), [0, 1]);
      expect(restored.readingAidPolicy, ReadingAidPolicy.hide);
      expect(restored.explanation, 'Synthetic offline explanation');
      expect(
        (await database.query('questions')).single['answer_mode'],
        'singleChoice',
      );

      final invalid = QuestionContent(
        revision: revision(ContentKind.question, ids.generate(), versionId),
        prompt: reading('Prompt', [('Prompt', null)]),
        readingAidPolicy: ReadingAidPolicy.inherit,
        explanation: 'Explanation',
        options: question.options,
        correctOptionId: ids.generate(),
      );
      expect(() => repository.insertDraft(invalid), throwsArgumentError);
      expect(await database.query('questions'), hasLength(1));
      await expectLater(
        database.update(
          'questions',
          {'correct_option_id': ids.generate()},
          where: 'revision_id = ?',
          whereArgs: [question.revision.id],
        ),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  test(
    'draft validation and database constraints reject invalid data',
    () async {
      final versionId = ids.generate();
      await repository.insertVersion(
        ContentVersion(id: versionId, label: 'fixture', createdAt: createdAt),
      );
      final invalidReading = VocabularyContent(
        revision: revision(ContentKind.vocabulary, ids.generate(), versionId),
        written: ReadingText(
          id: ids.generate(),
          surface: '今日',
          segments: const [],
        ),
        meaning: 'today',
      );
      expect(() => repository.insertDraft(invalidReading), throwsArgumentError);

      final emptySurface = VocabularyContent(
        revision: revision(ContentKind.vocabulary, ids.generate(), versionId),
        written: reading('', [('', null)]),
        meaning: 'invalid segment',
      );
      expect(() => repository.insertDraft(emptySurface), throwsArgumentError);

      final emptyActor = ContentRevision(
        id: ids.generate(),
        contentId: ids.generate(),
        contentVersionId: versionId,
        kind: ContentKind.vocabulary,
        reviewStatus: ContentReviewStatus.draft,
        createdBy: '',
        updatedBy: 'actor',
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      expect(
        () => repository.insertDraft(
          VocabularyContent(
            revision: emptyActor,
            written: reading('文字', [('文字', 'もじ')]),
            meaning: 'text',
          ),
        ),
        throwsArgumentError,
      );
      final emptyModifier = ContentRevision(
        id: ids.generate(),
        contentId: ids.generate(),
        contentVersionId: versionId,
        kind: ContentKind.vocabulary,
        reviewStatus: ContentReviewStatus.draft,
        createdBy: 'actor',
        updatedBy: '',
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      expect(
        () => repository.insertDraft(
          VocabularyContent(
            revision: emptyModifier,
            written: reading('文字', [('文字', 'もじ')]),
            meaning: 'text',
          ),
        ),
        throwsArgumentError,
      );
      await expectLater(
        database.insert('content_revision_sources', {
          'revision_id': ids.generate(),
          'source_id': ids.generate(),
        }),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  test(
    'source review and usage enums persist with approved SQLite values',
    () async {
      final usageValues = <ContentUsageStatus, String>{
        ContentUsageStatus.referenceOnly: 'reference-only',
        ContentUsageStatus.originalContent: 'original-content',
        ContentUsageStatus.licensed: 'licensed',
        ContentUsageStatus.needsReview: 'needs-review',
        ContentUsageStatus.blocked: 'blocked',
      };
      for (final entry in usageValues.entries) {
        final reference = source(entry.value, usageStatus: entry.key);
        await repository.insertSource(reference);
        expect(
          (await repository.getSource(reference.id))!.contentUsageStatus,
          entry.key,
        );
        final row = (await database.query(
          'source_references',
          where: 'id = ?',
          whereArgs: [reference.id],
        )).single;
        expect(row['content_usage_status'], entry.value);
      }
      for (final reviewStatus in SourceReviewStatus.values) {
        final reference = source(reviewStatus.name, reviewStatus: reviewStatus);
        await repository.insertSource(reference);
        expect(
          (await repository.getSource(reference.id))!.reviewStatus,
          reviewStatus,
        );
        final row = (await database.query(
          'source_references',
          where: 'id = ?',
          whereArgs: [reference.id],
        )).single;
        expect(row['review_status'], reviewStatus.name);
      }
      await expectLater(
        database.insert('source_references', {
          'id': ids.generate(),
          'source_name': 'Invalid status',
          'content_usage_status': 'licensed',
          'review_status': 'reviewed',
          'created_at': '2024-01-02T03:04:05.000Z',
          'updated_at': '2024-01-02T03:04:05.000Z',
        }),
        throwsA(isA<DatabaseException>()),
      );
    },
  );

  final publishCases =
      <
        ({
          String name,
          List<(SourceReviewStatus, ContentUsageStatus)> statuses,
          bool allowed,
        })
      >[
        (
          name: 'approved reference-only',
          statuses: [
            (SourceReviewStatus.approved, ContentUsageStatus.referenceOnly),
          ],
          allowed: true,
        ),
        (
          name: 'approved original-content',
          statuses: [
            (SourceReviewStatus.approved, ContentUsageStatus.originalContent),
          ],
          allowed: true,
        ),
        (
          name: 'approved licensed',
          statuses: [
            (SourceReviewStatus.approved, ContentUsageStatus.licensed),
          ],
          allowed: true,
        ),
        (
          name: 'approved needs-review',
          statuses: [
            (SourceReviewStatus.approved, ContentUsageStatus.needsReview),
          ],
          allowed: false,
        ),
        (
          name: 'approved blocked',
          statuses: [(SourceReviewStatus.approved, ContentUsageStatus.blocked)],
          allowed: false,
        ),
        (
          name: 'pending reference-only',
          statuses: [
            (SourceReviewStatus.pending, ContentUsageStatus.referenceOnly),
          ],
          allowed: false,
        ),
        (
          name: 'rejected reference-only',
          statuses: [
            (SourceReviewStatus.rejected, ContentUsageStatus.referenceOnly),
          ],
          allowed: false,
        ),
        (name: 'zero sources', statuses: [], allowed: false),
        (
          name: 'multiple all-valid sources',
          statuses: [
            (SourceReviewStatus.approved, ContentUsageStatus.referenceOnly),
            (SourceReviewStatus.approved, ContentUsageStatus.licensed),
          ],
          allowed: true,
        ),
        (
          name: 'one valid and one blocked source',
          statuses: [
            (SourceReviewStatus.approved, ContentUsageStatus.originalContent),
            (SourceReviewStatus.approved, ContentUsageStatus.blocked),
          ],
          allowed: false,
        ),
      ];

  for (final scenario in publishCases) {
    test('repository publish eligibility: ${scenario.name}', () async {
      final references = [
        for (final (index, pair) in scenario.statuses.indexed)
          source('Source $index', reviewStatus: pair.$1, usageStatus: pair.$2),
      ];
      final body = await reviewedVocabulary(references);
      final publishedAt = DateTime.utc(2024, 4, 5, 6, 7);
      if (scenario.allowed) {
        await repository.publish(body.revision.id, 'publisher', publishedAt);
        final stored = (await repository.getRevision(body.revision.id))!
            .revision;
        expect(stored.reviewStatus, ContentReviewStatus.published);
        expect(stored.updatedBy, 'publisher');
        expect(stored.updatedAt, publishedAt);
        expect(stored.updatedAt.isUtc, isTrue);
        await expectLater(
          repository.publish(body.revision.id, 'publisher', publishedAt),
          throwsStateError,
        );
      } else {
        await expectLater(
          repository.publish(body.revision.id, 'publisher', publishedAt),
          throwsStateError,
        );
        final stored = (await repository.getRevision(body.revision.id))!
            .revision;
        expect(stored.reviewStatus, ContentReviewStatus.reviewed);
        expect(stored.updatedBy, 'reviewer');
        expect(stored.updatedAt, createdAt);
      }
    });
  }

  test('direct SQL cannot bypass publication eligibility', () async {
    for (final scenario in publishCases.where((item) => !item.allowed)) {
      final references = [
        for (final (index, pair) in scenario.statuses.indexed)
          source(
            'Direct source $index',
            reviewStatus: pair.$1,
            usageStatus: pair.$2,
          ),
      ];
      final body = await reviewedVocabulary(references);
      await expectLater(
        database.update(
          'content_revisions',
          {'review_status': 'published'},
          where: 'id = ?',
          whereArgs: [body.revision.id],
        ),
        throwsA(isA<DatabaseException>()),
        reason: scenario.name,
      );
      expect(
        (await repository.getRevision(body.revision.id))!.revision.reviewStatus,
        ContentReviewStatus.reviewed,
      );
    }
  });

  test(
    'invalid source can be detached before, never after, publication',
    () async {
      final valid = source('Valid');
      final blocked = source(
        'Blocked',
        usageStatus: ContentUsageStatus.blocked,
      );
      final body = await reviewedVocabulary([valid, blocked]);
      await expectLater(
        repository.publish(body.revision.id, 'publisher', createdAt),
        throwsStateError,
      );
      await repository.detachSourceBeforePublish(body.revision.id, blocked.id);
      expect(await repository.sourceIdsForRevision(body.revision.id), [
        valid.id,
      ]);
      await repository.publish(body.revision.id, 'publisher', createdAt);
      await expectLater(
        repository.detachSourceBeforePublish(body.revision.id, valid.id),
        throwsStateError,
      );
    },
  );

  test('draft cannot publish and publisher actor is required', () async {
    final versionId = ids.generate();
    await repository.insertVersion(
      ContentVersion(id: versionId, label: versionId, createdAt: createdAt),
    );
    final body = VocabularyContent(
      revision: revision(ContentKind.vocabulary, ids.generate(), versionId),
      written: reading('word', [('word', null)]),
      meaning: 'synthetic meaning',
    );
    await repository.insertDraft(body);
    await expectLater(
      repository.publish(body.revision.id, 'publisher', createdAt),
      throwsStateError,
    );
    expect(
      () => repository.publish(body.revision.id, ' ', createdAt),
      throwsArgumentError,
    );
  });

  test('review, provenance and published immutability are enforced', () async {
    final versionId = ids.generate();
    await repository.insertVersion(
      ContentVersion(id: versionId, label: 'fixture', createdAt: createdAt),
    );
    await repository.setCurrentVersion(versionId);
    final body = VocabularyContent(
      revision: revision(ContentKind.vocabulary, ids.generate(), versionId),
      written: reading('word', [('word', null)]),
      meaning: 'original meaning',
    );
    await repository.insertDraft(body);
    expect(await repository.currentPublished(ContentKind.vocabulary), isEmpty);

    final provenance = source('Publication source');
    await repository.insertSource(provenance);
    await repository.attachSourceToDraft(body.revision.id, provenance.id);

    final reviewedAt = DateTime.utc(2024, 2, 3);
    await repository.markReviewed(body.revision.id, 'reviewer', reviewedAt);
    final reviewed = (await repository.getRevision(body.revision.id))!.revision;
    expect(reviewed.reviewStatus, ContentReviewStatus.reviewed);
    expect(reviewed.updatedBy, 'reviewer');
    expect(reviewed.updatedAt, reviewedAt);
    await expectLater(
      repository.attachSourceToDraft(body.revision.id, ids.generate()),
      throwsStateError,
    );

    final missingSource = VocabularyContent(
      revision: revision(ContentKind.vocabulary, ids.generate(), versionId),
      written: reading('other', [('other', null)]),
      meaning: 'other meaning',
    );
    await repository.insertDraft(missingSource);
    await repository.markReviewed(
      missingSource.revision.id,
      'reviewer',
      reviewedAt,
    );
    await expectLater(
      database.update(
        'content_revisions',
        {'review_status': 'published'},
        where: 'id = ?',
        whereArgs: [missingSource.revision.id],
      ),
      throwsA(isA<DatabaseException>()),
    );

    await repository.publish(body.revision.id, 'publisher', reviewedAt);
    expect(
      await repository.currentPublished(ContentKind.vocabulary),
      hasLength(1),
    );
    await expectLater(
      database.update(
        'vocabulary',
        {'meaning': 'mutated'},
        where: 'revision_id = ?',
        whereArgs: [body.revision.id],
      ),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      database.update(
        'reading_segments',
        {'reading': 'mutated'},
        where: 'reading_text_id = ?',
        whereArgs: [body.written.id],
      ),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      database.delete(
        'content_revision_sources',
        where: 'revision_id = ?',
        whereArgs: [body.revision.id],
      ),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      database.update(
        'source_references',
        {'source_name': 'mutated'},
        where: 'id = ?',
        whereArgs: [provenance.id],
      ),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      database.delete(
        'content_revisions',
        where: 'id = ?',
        whereArgs: [body.revision.id],
      ),
      throwsA(isA<DatabaseException>()),
    );

    await repository.withdraw(
      body.revision.id,
      'reviewer',
      DateTime.utc(2024, 3, 4),
    );
    expect(await repository.currentPublished(ContentKind.vocabulary), isEmpty);
    expect(
      (await repository.getRevision(body.revision.id))!.revision.reviewStatus,
      ContentReviewStatus.withdrawn,
    );
  });
}
