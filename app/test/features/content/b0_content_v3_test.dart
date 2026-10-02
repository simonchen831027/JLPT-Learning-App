import 'dart:convert';
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
import 'package:jlpt_learning_app/features/practice/data/sqlite_practice_repository.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/b0_v2_fixture_package.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String databasePath;
  late Database database;
  late SqliteContentRepository repository;
  const package = B0ContentPackage(EntityIdGenerator());
  const historical = B0V2FixturePackage(EntityIdGenerator());

  Future<void> open() async {
    database = await MigrationRunner(appMigrations)
        .open(databaseFactoryFfi, databasePath);
    repository = SqliteContentRepository(database);
  }

  Future<Map<String, List<Map<String, Object?>>>> rows() async {
    final tables = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    return {
      for (final row in tables)
        row['name']! as String: await database.query(row['name']! as String),
    };
  }

  Future<List<ContentBody>> currentBodies() async => [
    for (final id in B0ContentIds.allContent)
      (await repository.currentPublishedByContentId(id))!,
  ];
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('jlpt_b0_v3_');
    databasePath = '${directory.path}/content.sqlite3';
    await open();
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test(
    'fresh v3 matches all approved fields, alignments and option identities',
    () async {
      await package.install(repository);
      // 從核准 Candidate 擷取的獨立 oracle，可於 clean checkout 使用。
      final oracle = jsonDecode(
        await File('test/fixtures/b0_learner_facing_v3.json').readAsString(),
      ) as Map<String, dynamic>;
      expect(
        oracle['candidateSha256'],
        '8B698FDDE858B6BFEF76CC39F23412ADAD621B2BB5A53E0CD98DD8DF25744C8B',
      );
      final bodies = await currentBodies();
      final fields = <String, String>{};
      final readings = <String, ReadingText>{};
      void reading(String field, ReadingText value) {
        fields[field] = value.surface;
        readings[field] = value;
        value.validate();
      }

      final lesson = bodies.first as LessonContent;
      reading('lesson.title', lesson.title);
      expect(lesson.sections.map((s) => s.ordinal), List.generate(9, (i) => i));
      for (final section in lesson.sections) {
        reading('lesson.sections.${section.ordinal}.title', section.title);
        reading('lesson.sections.${section.ordinal}.body', section.body);
      }
      for (var i = 0; i < 6; i++) {
        final body = bodies[1 + i] as VocabularyContent;
        reading('vocabulary.$i.written', body.written);
        fields['vocabulary.$i.meaning'] = body.meaning;
      }
      for (var i = 0; i < 2; i++) {
        final grammar = bodies[7 + i] as GrammarContent;
        reading('grammar.$i.pattern', grammar.pattern);
        fields['grammar.$i.explanation'] = grammar.explanation;
        final kanji = bodies[9 + i] as KanjiContent;
        reading('kanji.$i.context', kanji.context);
        fields['kanji.$i.character'] = kanji.character;
        fields['kanji.$i.meaning'] = kanji.meaning;
      }
      for (var i = 0; i < 5; i++) {
        final body = bodies[11 + i] as ExampleSentenceContent;
        reading('examples.$i.sentence', body.sentence);
        fields['examples.$i.translation'] = body.translation;
      }
      for (var i = 0; i < 3; i++) {
        final question = bodies[16 + i] as QuestionContent;
        reading('questions.$i.prompt', question.prompt);
        fields['questions.$i.explanation'] = question.explanation;
        expect(question.readingAidPolicy, ReadingAidPolicy.inherit);
        expect(question.options.map((o) => o.ordinal), [0, 1, 2, 3]);
        expect(
          question.options.map((o) => o.id),
          B0ContentIds.questionOptions[i],
        );
        for (final option in question.options) {
          reading(
            'questions.$i.options.${option.ordinal}.content',
            option.content,
          );
        }
        final correct = question.options.singleWhere(
          (o) => o.id == question.correctOptionId,
        );
        expect(correct.ordinal, (oracle['correctOrdinals'] as List)[i]);
        expect(
          correct.content.surface,
          ['ミオさんは学生です。', 'レンさんは日本人ですか。', '学生'][i],
        );
        expect(
          question.options
              .map((o) => o.id)
              .toSet()
              .intersection(B0ContentIds.previousQuestionOptions[i].toSet()),
          isEmpty,
        );
      }
      expect(fields, oracle['fields']);
      expect(fields, hasLength(69));
      expect(readings, hasLength(49));
      for (final expected in oracle['readingTexts'] as List) {
        final actual = readings[expected['field']]!;
        expect(
          actual.surface,
          expected['surface'],
          reason: expected['field'] as String,
        );
        expect(
          [
            for (final segment in actual.segments)
              {
                'ordinal': segment.ordinal,
                'surface': segment.surface,
                'reading': segment.reading,
              },
          ],
          expected['segments'],
          reason: expected['field'] as String,
        );
      }
      final segments = readings.values.expand((r) => r.segments).toList();
      expect(segments, hasLength(175));
      expect(segments.where((s) => s.reading != null), hasLength(51));
      final identities = [
        B0ContentIds.version,
        ...B0ContentIds.allContent,
        for (final body in bodies) body.revision.id,
        for (final section in lesson.sections) section.id,
        for (final r in readings.values) r.id,
        for (final s in segments) s.id,
        ...B0ContentIds.questionOptions.expand((row) => row),
      ];
      expect(identities.toSet(), hasLength(identities.length));
      for (final id in identities) {
        expect(
          id,
          matches(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        );
      }
      expect(
        bodies.map((b) => b.revision.contentId),
        B0V2FixtureIds.allContent,
      );
      expect(
        bodies.every(
          (b) => b.revision.reviewStatus == ContentReviewStatus.published,
        ),
        isTrue,
      );
      expect(await repository.currentPublished(ContentKind.kana), isEmpty);
      expect(
        await repository.publishedCountByVersion(B0ContentIds.version),
        19,
      );
      expect((await repository.currentVersion())!.label, 'n5-l01-b0-v3');
      expect(await database.query('source_references'), hasLength(17));
      for (final body in bodies) {
        final sources = await repository.sourceIdsForRevision(body.revision.id);
        expect(sources, isNotEmpty);
        for (final id in sources) {
          expect(
            (await repository.getSource(id))!.isPublicationEligible,
            isTrue,
          );
        }
      }
      expect(
        await repository.sourceIdsForRevision(lesson.revision.id),
        hasLength(17),
      );
      final learning = SqliteN5LessonRepository(() async => repository);
      expect(
        (await ListN5Lessons(learning)()).single.title.surface,
        oracle['fields']['lesson.title'],
      );
      final detail = (await GetN5Lesson(learning)(B0ContentIds.lesson))!;
      expect(
        detail.examplesAfterSection[B0ContentIds.g01ExamplesSectionOrdinal],
        hasLength(3),
      );
      expect(
        detail.examplesAfterSection[B0ContentIds.g02ExamplesSectionOrdinal],
        hasLength(2),
      );
    },
  );

  test('reopen and repeated initialization preserve every v3 row', () async {
    await package.install(repository);
    final before = await rows();
    await package.install(repository);
    expect(await rows(), before);
    await database.close();
    await open();
    await package.install(repository);
    expect(await rows(), before);
    expect(await database.query('content_versions'), hasLength(1));
    expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  for (final legacy in [false, true]) {
    test(
      '${legacy ? 'v1-compatible fixture' : 'actual v2 fixture'} upgrade preserves all historical rows',
      () async {
        await B0V2FixturePackage(
          const EntityIdGenerator(),
          legacy: legacy,
        ).install(repository);
        final oldVersion = (await repository.currentVersion())!;
        final oldBodies = await currentBodies();
        final before = await rows();
        await package.install(repository);
        final after = await rows();
        expect((await repository.currentVersion())!.id, B0ContentIds.version);
        expect(await repository.publishedCountByVersion(oldVersion.id), 19);
        expect(
          await repository.publishedCountByVersion(B0ContentIds.version),
          19,
        );
        expect(after['content_items'], before['content_items']);
        expect(after['source_references'], before['source_references']);
        for (final table in before.keys.where(
          (name) => name != 'content_versions',
        )) {
          for (final row in before[table]!) {
            expect(
              after[table],
              contains(equals(row)),
              reason: 'Historical $table row must not change',
            );
          }
        }
        final revised = await currentBodies();
        final oldReadings = oldBodies.expand((b) => b.readingTexts).toList();
        final newReadings = revised.expand((b) => b.readingTexts).toList();
        expect(
          newReadings
              .map((r) => r.id)
              .toSet()
              .intersection(oldReadings.map((r) => r.id).toSet()),
          isEmpty,
        );
        expect(
          newReadings
              .expand((r) => r.segments)
              .map((s) => s.id)
              .toSet()
              .intersection(
                oldReadings.expand((r) => r.segments).map((s) => s.id).toSet(),
              ),
          isEmpty,
        );
        for (var i = 0; i < oldBodies.length; i++) {
          expect(revised[i].revision.id, isNot(oldBodies[i].revision.id));
          expect(
            await repository.sourceIdsForRevision(revised[i].revision.id),
            await repository.sourceIdsForRevision(oldBodies[i].revision.id),
          );
        }
        for (var i = 11; i < 16; i++) {
          final old = oldBodies[i] as ExampleSentenceContent;
          final current = revised[i] as ExampleSentenceContent;
          expect(current.sentence.surface, old.sentence.surface);
          expect(current.translation, old.translation);
        }
        await expectLater(
          database.update(
            'content_revisions',
            {'created_by': 'overwrite'},
            where: 'id = ?',
            whereArgs: [oldBodies.first.revision.id],
          ),
          throwsA(isA<DatabaseException>()),
        );
        await database.close();
        await open();
        await package.install(repository);
        expect(await rows(), after);
        expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      },
    );
  }

  test(
    'v2 frozen session survives v3 publication, restart, completion and Result',
    () async {
      await historical.install(repository);
      var practice = SqlitePracticeRepository(database);
      final old = await practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      await practice.submitAnswer(
        old.session.id,
        old.currentQuestion.id,
        old.currentQuestion.question.correctOptionId,
      );
      final oldSessions = await database.query('quiz_sessions');
      final oldSnapshots = await database.query('quiz_session_questions');
      final oldAnswers = await database.query('quiz_answers');
      await package.install(repository);
      expect(await database.query('quiz_sessions'), oldSessions);
      expect(await database.query('quiz_session_questions'), oldSnapshots);
      expect(await database.query('quiz_answers'), oldAnswers);
      await database.close();
      await open();
      await package.install(repository);
      practice = SqlitePracticeRepository(database);
      var resumed = await practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      expect(resumed.session.id, old.session.id);
      expect(resumed.session.contentVersionId, B0ContentIds.previousVersion);
      expect(
        resumed.currentProgress,
        QuestionProgress.answeredAwaitingContinue,
      );
      expect(
        resumed.questions.map((q) => q.question.revision.id),
        old.questions.map((q) => q.question.revision.id),
      );
      for (var i = 0; i < 3; i++) {
        expect(
          resumed.questions[i].question.options.map((o) => o.id),
          B0ContentIds.previousQuestionOptions[i],
        );
        expect(
          resumed.questions[i].question.options.map((o) => o.content.surface),
          old.questions[i].question.options.map((o) => o.content.surface),
        );
      }
      final review = await practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.review,
      );
      expect(review.session.contentVersionId, B0ContentIds.version);
      for (var i = 0; i < 3; i++) {
        expect(
          review.questions[i].question.options.map((o) => o.id),
          B0ContentIds.questionOptions[i],
        );
      }
      for (var i = 0; i < 3; i++) {
        final q = resumed.currentQuestion;
        if (i > 0) {
          await practice.submitAnswer(
            resumed.session.id,
            q.id,
            q.question.correctOptionId,
          );
        }
        if (i < 2) {
          resumed = await practice.continueQuestion(resumed.session.id, q.id);
        }
      }
      await practice.completeSession(resumed.session.id);
      final result = await practice.getResult(resumed.session.id);
      expect(result.correctCount, 3);
      expect(
        result.state.session.contentVersionId,
        B0ContentIds.previousVersion,
      );
      final next = await practice.startOrResume(
        B0ContentIds.lesson,
        QuizMode.practice,
      );
      expect(next.session.id, isNot(old.session.id));
      expect(next.session.contentVersionId, B0ContentIds.version);
      expect(await database.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  final failureStages = <String, (String, String, String)>{
    'version insert': (
      'content_versions',
      'INSERT',
      "NEW.id = '${B0ContentIds.version}'",
    ),
    'revision insert': (
      'content_revisions',
      'INSERT',
      "NEW.content_version_id = '${B0ContentIds.version}' AND NEW.content_id = '${B0ContentIds.questions[1]}'",
    ),
    'review': (
      'content_revisions',
      'UPDATE',
      "NEW.content_version_id = '${B0ContentIds.version}' AND NEW.review_status = 'reviewed' AND NEW.content_id = '${B0ContentIds.questions[1]}'",
    ),
    'publication': (
      'content_revisions',
      'UPDATE',
      "NEW.content_version_id = '${B0ContentIds.version}' AND NEW.review_status = 'published' AND NEW.content_id = '${B0ContentIds.questions[1]}'",
    ),
    'current switch': (
      'content_versions',
      'UPDATE',
      "NEW.id = '${B0ContentIds.version}' AND NEW.is_current = 1",
    ),
  };
  for (final stage in failureStages.entries) {
    test('${stage.key} failure rolls back full v3 and permits safe retry', () async {
      await historical.install(repository);
      final before = await rows();
      final (table, event, condition) = stage.value;
      // TEMP trigger 僅注入本次測試連線的故障，無 production schema 變更。
      await database.execute(
        'CREATE TEMP TRIGGER fail_import BEFORE $event ON $table '
        "WHEN $condition BEGIN SELECT RAISE(ABORT, 'test injected failure'); END",
      );
      await expectLater(
        package.install(repository),
        throwsA(isA<DatabaseException>()),
      );
      expect(await rows(), before);
      expect(
        (await repository.currentVersion())!.id,
        B0ContentIds.previousVersion,
      );
      expect(await repository.getVersion(B0ContentIds.version), isNull);
      await database.execute('DROP TRIGGER fail_import');
      await package.install(repository);
      expect((await repository.currentVersion())!.id, B0ContentIds.version);
      expect(
        await repository.publishedCountByVersion(B0ContentIds.version),
        19,
      );
    });
  }

  for (final status in ['pending', 'rejected', 'needs-review', 'blocked']) {
    test('one required $status source blocks v3 without changing v2', () async {
      await historical.install(repository);
      final before = await rows();
      final sourceId = before['source_references']!.last['id']! as String;
      final column = status == 'pending' || status == 'rejected'
          ? 'review_status'
          : 'content_usage_status';
      final columns = await database.rawQuery(
        'PRAGMA table_info(source_references)',
      );
      final projection = columns
          .map((row) {
            final name = row['name']! as String;
            return name == column
                ? "CASE WHEN id = '$sourceId' THEN '$status' ELSE $name END AS $name"
                : name;
          })
          .join(', ');
      // 唯讀 TEMP overlay 模擬 lookup 回傳一筆不合格來源，不改 immutable source。
      await database.execute(
        'CREATE TEMP VIEW source_references AS SELECT $projection FROM main.source_references',
      );
      await expectLater(package.install(repository), throwsStateError);
      await database.execute('DROP VIEW source_references');
      expect(await rows(), before);
      expect(
        (await repository.currentVersion())!.id,
        B0ContentIds.previousVersion,
      );
      expect(await repository.getVersion(B0ContentIds.version), isNull);
    });
  }
}
