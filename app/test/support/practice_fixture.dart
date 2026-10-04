import 'dart:io';

import 'package:jlpt_learning_app/core/database/migration_runner.dart';
import 'package:jlpt_learning_app/core/database/migrations.dart';
import 'package:jlpt_learning_app/core/identity/entity_id_generator.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_package.dart';
import 'package:jlpt_learning_app/features/content/data/sqlite_content_repository.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/practice/data/sqlite_practice_repository.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final class PracticeFixture {
  PracticeFixture._(this.directory, this.database, this.factory);
  final Directory directory;
  final DatabaseFactory factory;
  Database database;
  DateTime now = DateTime.utc(2026, 10, 1, 1, 2, 3);
  String get databasePath => path.join(directory.path, 'practice.sqlite3');
  SqliteContentRepository get content => SqliteContentRepository(database);
  SqlitePracticeRepository get practice =>
      SqlitePracticeRepository(database, now: () => now);

  static Future<PracticeFixture> create({
    int version = 3,
    DatabaseFactory? factory,
  }) async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp('jlpt_practice_');
    final selectedFactory = factory ?? databaseFactoryFfi;
    final database = await MigrationRunner(appMigrations.take(version).toList())
        .open(selectedFactory, path.join(directory.path, 'practice.sqlite3'));
    final fixture = PracticeFixture._(directory, database, selectedFactory);
    await const B0ContentPackage(EntityIdGenerator()).install(fixture.content);
    return fixture;
  }

  Future<void> reopen({int version = 3}) async {
    await database.close();
    database = await MigrationRunner(appMigrations.take(version).toList())
        .open(factory, databasePath);
  }

  Future<void> dispose() async {
    await database.close();
    await directory.delete(recursive: true);
  }

  Future<Map<String, List<Map<String, Object?>>>> contentRows() async {
    final names = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name != 'schema_migrations' AND name NOT LIKE 'quiz_%' ORDER BY name",
    );
    return {
      for (final item in names)
        item['name']! as String: await database.query(item['name']! as String),
    };
  }

  /// Synthetic test-only release: same logical context/questions, new
  /// immutable revisions/options with different correct options.
  Future<String> publishNextVersion() async {
    const ids = EntityIdGenerator();
    final nextVersionId = ids.generate();
    final oldLesson =
        (await content.currentPublishedByContentId(B0ContentIds.lesson))!
            as LessonContent;
    final oldQuestions = <QuestionContent>[
      for (final id in B0ContentIds.questions)
        (await content.currentPublishedByContentId(id))! as QuestionContent,
    ];
    final sources = await content.sourceIdsForRevision(oldLesson.revision.id);
    ReadingText copyReading(ReadingText old) => ReadingText(
      id: ids.generate(),
      surface: old.surface,
      segments: [
        for (final segment in old.segments)
          ReadingSegment(
            id: ids.generate(),
            ordinal: segment.ordinal,
            surface: segment.surface,
            reading: segment.reading,
          ),
      ],
    );
    ContentRevision revision(ContentRevision old) => ContentRevision(
      id: ids.generate(),
      contentId: old.contentId,
      contentVersionId: nextVersionId,
      kind: old.kind,
      reviewStatus: ContentReviewStatus.draft,
      createdBy: 'synthetic-test',
      updatedBy: 'synthetic-test',
      createdAt: now,
      updatedAt: now,
    );
    await content.transaction((tx) async {
      await tx.insertVersion(
        ContentVersion(id: nextVersionId, label: nextVersionId, createdAt: now),
      );
      final bodies = <ContentBody>[
        LessonContent(
          revision: revision(oldLesson.revision),
          title: copyReading(oldLesson.title),
          sections: [
            for (final section in oldLesson.sections)
              LessonSection(
                id: ids.generate(),
                ordinal: section.ordinal,
                title: copyReading(section.title),
                body: copyReading(section.body),
              ),
          ],
        ),
        for (final old in oldQuestions)
          _copyQuestion(old, revision(old.revision), copyReading, ids),
      ];
      for (final body in bodies) {
        await tx.insertDraft(body, sourceIds: sources);
        await tx.markReviewed(body.revision.id, 'synthetic-test', now);
        await tx.publish(body.revision.id, 'synthetic-test', now);
      }
      await tx.setCurrentVersion(nextVersionId);
    });
    return nextVersionId;
  }

  QuestionContent _copyQuestion(
    QuestionContent old,
    ContentRevision revision,
    ReadingText Function(ReadingText) copyReading,
    EntityIdGenerator ids,
  ) {
    final options = [
      for (final option in old.options)
        QuestionOption(
          id: ids.generate(),
          ordinal: option.ordinal,
          content: copyReading(option.content),
        ),
    ];
    return QuestionContent(
      revision: revision,
      prompt: copyReading(old.prompt),
      readingAidPolicy: old.readingAidPolicy,
      explanation: 'Synthetic revision explanation',
      options: options,
      correctOptionId: options[1].id,
    );
  }
}
