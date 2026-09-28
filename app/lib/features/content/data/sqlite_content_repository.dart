import 'package:jlpt_learning_app/core/database/persistence_values.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../domain/content_models.dart';
import 'source_reference_values.dart';

/// The narrow content write/read boundary used before learning flows exist.
final class SqliteContentRepository {
  const SqliteContentRepository(this.database);
  const SqliteContentRepository._scoped(this.database);

  final DatabaseExecutor database;

  /// Keeps a multi-item release atomic while reusing the same review methods.
  Future<T> transaction<T>(
    Future<T> Function(SqliteContentRepository repository) action,
  ) {
    final root = database;
    if (root is! Database) {
      throw StateError('A scoped repository cannot start a transaction.');
    }
    return root.transaction(
      (tx) => action(SqliteContentRepository._scoped(tx)),
    );
  }

  Future<T> _write<T>(Future<T> Function(DatabaseExecutor tx) action) {
    final executor = database;
    return executor is Database
        ? executor.transaction(action)
        : action(executor);
  }

  Future<void> insertVersion(ContentVersion version) =>
      database.insert('content_versions', {
        'id': version.id,
        'label': version.label,
        'is_current': version.isCurrent ? 1 : 0,
        'created_at': PersistenceValues.encodeInstant(version.createdAt),
      });

  Future<ContentVersion?> getVersion(String id) async {
    final rows = await database.query(
      'content_versions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return ContentVersion(
      id: row['id']! as String,
      label: row['label']! as String,
      isCurrent: row['is_current'] == 1,
      createdAt: PersistenceValues.decodeInstant(row['created_at']! as String),
    );
  }

  Future<void> setCurrentVersion(String id) => _write((tx) async {
    await tx.update('content_versions', {'is_current': 0});
    final changed = await tx.update(
      'content_versions',
      {'is_current': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (changed != 1) throw StateError('Content version does not exist.');
  });

  Future<ContentVersion?> currentVersion() async {
    final rows = await database.query(
      'content_versions',
      columns: ['id'],
      where: 'is_current = 1',
    );
    if (rows.isEmpty) return null;
    return getVersion(rows.single['id']! as String);
  }

  Future<void> insertSource(SourceReference source) =>
      database.insert('source_references', {
        'id': source.id,
        'source_name': source.sourceName,
        'source_url': source.sourceUrl,
        'source_title': source.sourceTitle,
        'topic': source.topic,
        'reference_level': source.referenceLevel,
        'accessed_at': source.accessedAt == null
            ? null
            : PersistenceValues.encodeInstant(source.accessedAt!),
        'content_usage_status': SourceReferenceValues.encodeUsageStatus(
          source.contentUsageStatus,
        ),
        'review_status': SourceReferenceValues.encodeReviewStatus(
          source.reviewStatus,
        ),
        'created_at': PersistenceValues.encodeInstant(source.createdAt),
        'updated_at': PersistenceValues.encodeInstant(source.updatedAt),
        'note': source.note,
      });

  Future<SourceReference?> getSource(String id) async {
    final rows = await database.query(
      'source_references',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return _sourceFromRow(rows.single);
  }

  SourceReference _sourceFromRow(Map<String, Object?> row) {
    final accessedAt = row['accessed_at'] as String?;
    return SourceReference(
      id: row['id']! as String,
      sourceName: row['source_name']! as String,
      sourceUrl: row['source_url'] as String?,
      sourceTitle: row['source_title'] as String?,
      topic: row['topic'] as String?,
      referenceLevel: row['reference_level'] as String?,
      accessedAt: accessedAt == null
          ? null
          : PersistenceValues.decodeInstant(accessedAt),
      contentUsageStatus: SourceReferenceValues.decodeUsageStatus(
        row['content_usage_status']! as String,
      ),
      reviewStatus: SourceReferenceValues.decodeReviewStatus(
        row['review_status']! as String,
      ),
      createdAt: PersistenceValues.decodeInstant(row['created_at']! as String),
      updatedAt: PersistenceValues.decodeInstant(row['updated_at']! as String),
      note: row['note'] as String?,
    );
  }

  Future<List<String>> sourceIdsForRevision(String revisionId) async {
    final rows = await database.query(
      'content_revision_sources',
      columns: ['source_id'],
      where: 'revision_id = ?',
      whereArgs: [revisionId],
      orderBy: 'source_id',
    );
    return [for (final row in rows) row['source_id']! as String];
  }

  Future<void> insertDraft(
    ContentBody body, {
    List<String> sourceIds = const [],
  }) {
    final revision = body.revision;
    if (revision.reviewStatus != ContentReviewStatus.draft ||
        revision.kind != _kindOf(body) ||
        revision.createdBy.trim().isEmpty ||
        revision.updatedBy.trim().isEmpty) {
      throw ArgumentError('Invalid draft revision.');
    }
    final readingTexts = body.readingTexts.toList();
    if (readingTexts.map((reading) => reading.id).toSet().length !=
        readingTexts.length) {
      throw ArgumentError('ReadingText aggregates must not be shared.');
    }
    for (final reading in readingTexts) {
      reading.validate();
    }
    if (body is QuestionContent &&
        (body.options.isEmpty ||
            body.options
                    .where((option) => option.id == body.correctOptionId)
                    .length !=
                1)) {
      throw ArgumentError('Single-choice answer must identify one option.');
    }

    return _write((tx) async {
      final existing = await tx.query(
        'content_items',
        where: 'id = ?',
        whereArgs: [revision.contentId],
      );
      if (existing.isEmpty) {
        await tx.insert('content_items', {
          'id': revision.contentId,
          'kind': revision.kind.name,
        });
      } else if (existing.single['kind'] != revision.kind.name) {
        throw ArgumentError('A contentId cannot change kind.');
      }

      await tx.insert('content_revisions', {
        'id': revision.id,
        'content_id': revision.contentId,
        'content_version_id': revision.contentVersionId,
        'review_status': revision.reviewStatus.name,
        'created_by': revision.createdBy,
        'updated_by': revision.updatedBy,
        'created_at': PersistenceValues.encodeInstant(revision.createdAt),
        'updated_at': PersistenceValues.encodeInstant(revision.updatedAt),
      });
      for (var index = 0; index < readingTexts.length; index++) {
        await _insertReading(tx, revision.id, index, readingTexts[index]);
      }
      await _insertBody(tx, body);
      for (final sourceId in sourceIds.toSet()) {
        await tx.insert('content_revision_sources', {
          'revision_id': revision.id,
          'source_id': sourceId,
        });
      }
    });
  }

  Future<void> markReviewed(String revisionId, String actor, DateTime at) =>
      _transition(
        revisionId,
        ContentReviewStatus.draft,
        ContentReviewStatus.reviewed,
        actor,
        at,
      );

  Future<void> publish(String revisionId, String actor, DateTime at) {
    if (actor.trim().isEmpty) throw ArgumentError('Actor is required.');
    return _write((tx) async {
      final revisions = await tx.query(
        'content_revisions',
        columns: ['review_status'],
        where: 'id = ?',
        whereArgs: [revisionId],
      );
      if (revisions.length != 1 ||
          revisions.single['review_status'] !=
              ContentReviewStatus.reviewed.name) {
        throw StateError('Only a reviewed revision can be published.');
      }

      final sourceRows = await tx.rawQuery(
        '''SELECT r.* FROM content_revision_sources s
           JOIN source_references r ON r.id = s.source_id
           WHERE s.revision_id = ?''',
        [revisionId],
      );
      if (sourceRows.isEmpty ||
          sourceRows.any((row) => !_sourceFromRow(row).isPublicationEligible)) {
        throw StateError('All attached sources must support publication.');
      }

      final changed = await tx.update(
        'content_revisions',
        {
          'review_status': ContentReviewStatus.published.name,
          'updated_by': actor,
          'updated_at': PersistenceValues.encodeInstant(at),
        },
        where: 'id = ? AND review_status = ?',
        whereArgs: [revisionId, ContentReviewStatus.reviewed.name],
      );
      if (changed != 1) throw StateError('Invalid review transition.');
    });
  }

  Future<void> attachSourceToDraft(String revisionId, String sourceId) =>
      _write((tx) async {
        final rows = await tx.query(
          'content_revisions',
          columns: ['review_status'],
          where: 'id = ?',
          whereArgs: [revisionId],
        );
        if (rows.length != 1 ||
            rows.single['review_status'] != ContentReviewStatus.draft.name) {
          throw StateError('Only a draft can gain provenance.');
        }
        await tx.insert('content_revision_sources', {
          'revision_id': revisionId,
          'source_id': sourceId,
        });
      });

  Future<void> detachSourceBeforePublish(String revisionId, String sourceId) =>
      _write((tx) async {
        final rows = await tx.query(
          'content_revisions',
          columns: ['review_status'],
          where: 'id = ?',
          whereArgs: [revisionId],
        );
        if (rows.length != 1 ||
            !{
              ContentReviewStatus.draft.name,
              ContentReviewStatus.reviewed.name,
            }.contains(rows.single['review_status'])) {
          throw StateError('Published provenance cannot be detached.');
        }
        final changed = await tx.delete(
          'content_revision_sources',
          where: 'revision_id = ? AND source_id = ?',
          whereArgs: [revisionId, sourceId],
        );
        if (changed != 1) throw StateError('Source relation does not exist.');
      });

  Future<void> withdraw(String revisionId, String actor, DateTime at) =>
      _transition(
        revisionId,
        ContentReviewStatus.published,
        ContentReviewStatus.withdrawn,
        actor,
        at,
      );

  Future<List<ContentBody>> currentPublished(ContentKind kind) async {
    final rows = await database.rawQuery(
      '''SELECT r.id FROM content_revisions r
         JOIN content_items i ON i.id = r.content_id
         JOIN content_versions v ON v.id = r.content_version_id
         WHERE i.kind = ? AND r.review_status = 'published'
           AND v.is_current = 1''',
      [kind.name],
    );
    final result = <ContentBody>[];
    for (final row in rows) {
      final body = await getRevision(row['id']! as String);
      if (body != null) result.add(body);
    }
    return result;
  }

  Future<ContentBody?> currentPublishedByContentId(String contentId) async {
    final rows = await database.rawQuery(
      '''SELECT r.id FROM content_revisions r
         JOIN content_versions v ON v.id = r.content_version_id
         WHERE r.content_id = ? AND r.review_status = 'published'
           AND v.is_current = 1''',
      [contentId],
    );
    if (rows.isEmpty) return null;
    return getRevision(rows.single['id']! as String);
  }

  Future<int> publishedCountByVersion(String versionId) async {
    final rows = await database.rawQuery(
      '''SELECT COUNT(*) AS total FROM content_revisions
         WHERE content_version_id = ? AND review_status = 'published' ''',
      [versionId],
    );
    return rows.single['total']! as int;
  }

  Future<ContentBody?> getRevision(String id) async {
    final rows = await database.rawQuery(
      '''SELECT r.*, i.kind FROM content_revisions r
         JOIN content_items i ON i.id = r.content_id WHERE r.id = ?''',
      [id],
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final kind = ContentKind.values.byName(row['kind']! as String);
    final revision = ContentRevision(
      id: id,
      contentId: row['content_id']! as String,
      contentVersionId: row['content_version_id']! as String,
      kind: kind,
      reviewStatus: ContentReviewStatus.values.byName(
        row['review_status']! as String,
      ),
      createdBy: row['created_by']! as String,
      updatedBy: row['updated_by']! as String,
      createdAt: PersistenceValues.decodeInstant(row['created_at']! as String),
      updatedAt: PersistenceValues.decodeInstant(row['updated_at']! as String),
    );
    final table = switch (kind) {
      ContentKind.lesson => 'lessons',
      ContentKind.vocabulary => 'vocabulary',
      ContentKind.grammar => 'grammar',
      ContentKind.kanji => 'kanji',
      ContentKind.kana => 'kana_content',
      ContentKind.exampleSentence => 'example_sentences',
      ContentKind.question => 'questions',
    };
    final content = (await database.query(
      table,
      where: 'revision_id = ?',
      whereArgs: [id],
    )).single;
    switch (kind) {
      case ContentKind.lesson:
        final sectionRows = await database.query(
          'lesson_sections',
          where: 'lesson_revision_id = ?',
          whereArgs: [id],
          orderBy: 'ordinal',
        );
        final sections = <LessonSection>[];
        for (final section in sectionRows) {
          sections.add(
            LessonSection(
              id: section['id']! as String,
              ordinal: section['ordinal']! as int,
              title: await _getReading(
                section['title_reading_text_id']! as String,
              ),
              body: await _getReading(
                section['body_reading_text_id']! as String,
              ),
            ),
          );
        }
        return LessonContent(
          revision: revision,
          title: await _getReading(content['title_reading_text_id']! as String),
          sections: sections,
        );
      case ContentKind.vocabulary:
        return VocabularyContent(
          revision: revision,
          written: await _getReading(
            content['written_reading_text_id']! as String,
          ),
          meaning: content['meaning']! as String,
        );
      case ContentKind.grammar:
        return GrammarContent(
          revision: revision,
          pattern: await _getReading(
            content['pattern_reading_text_id']! as String,
          ),
          explanation: content['explanation']! as String,
        );
      case ContentKind.kanji:
        return KanjiContent(
          revision: revision,
          character: content['character']! as String,
          context: await _getReading(
            content['contextual_reading_text_id']! as String,
          ),
          meaning: content['meaning']! as String,
        );
      case ContentKind.kana:
        return KanaContent(
          revision: revision,
          scriptType: KanaScriptType.values.byName(
            content['script_type']! as String,
          ),
          writtenKana: content['written_kana']! as String,
          pronunciation: content['pronunciation']! as String,
          readingReference: content['reading_reference']! as String,
          learningAvailable: content['learning_available'] == 1,
          practiceAvailable: content['practice_available'] == 1,
        );
      case ContentKind.exampleSentence:
        return ExampleSentenceContent(
          revision: revision,
          sentence: await _getReading(
            content['sentence_reading_text_id']! as String,
          ),
          translation: content['translation']! as String,
        );
      case ContentKind.question:
        final optionRows = await database.query(
          'question_options',
          where: 'question_revision_id = ?',
          whereArgs: [id],
          orderBy: 'ordinal',
        );
        final options = <QuestionOption>[];
        for (final option in optionRows) {
          options.add(
            QuestionOption(
              id: option['id']! as String,
              ordinal: option['ordinal']! as int,
              content: await _getReading(
                option['content_reading_text_id']! as String,
              ),
            ),
          );
        }
        return QuestionContent(
          revision: revision,
          prompt: await _getReading(
            content['prompt_reading_text_id']! as String,
          ),
          readingAidPolicy: ReadingAidPolicy.values.byName(
            content['reading_aid_policy']! as String,
          ),
          explanation: content['explanation']! as String,
          options: options,
          correctOptionId: content['correct_option_id']! as String,
        );
    }
  }

  Future<void> _transition(
    String id,
    ContentReviewStatus from,
    ContentReviewStatus to,
    String actor,
    DateTime at,
  ) async {
    if (actor.trim().isEmpty) throw ArgumentError('Actor is required.');
    final changed = await database.update(
      'content_revisions',
      {
        'review_status': to.name,
        'updated_by': actor,
        'updated_at': PersistenceValues.encodeInstant(at),
      },
      where: 'id = ? AND review_status = ?',
      whereArgs: [id, from.name],
    );
    if (changed != 1) throw StateError('Invalid review transition.');
  }

  Future<void> _insertReading(
    DatabaseExecutor tx,
    String revisionId,
    int fieldOrdinal,
    ReadingText reading,
  ) async {
    await tx.insert('reading_texts', {
      'id': reading.id,
      'owner_revision_id': revisionId,
      'field_ordinal': fieldOrdinal,
      'surface': reading.surface,
    });
    for (final segment in reading.segments) {
      await tx.insert('reading_segments', {
        'id': segment.id,
        'reading_text_id': reading.id,
        'ordinal': segment.ordinal,
        'surface': segment.surface,
        'reading': segment.reading,
      });
    }
  }

  Future<ReadingText> _getReading(String id) async {
    final text = (await database.query(
      'reading_texts',
      where: 'id = ?',
      whereArgs: [id],
    )).single;
    final segmentRows = await database.query(
      'reading_segments',
      where: 'reading_text_id = ?',
      whereArgs: [id],
      orderBy: 'ordinal',
    );
    return ReadingText(
      id: id,
      surface: text['surface']! as String,
      segments: [
        for (final row in segmentRows)
          ReadingSegment(
            id: row['id']! as String,
            ordinal: row['ordinal']! as int,
            surface: row['surface']! as String,
            reading: row['reading'] as String?,
          ),
      ],
    );
  }

  Future<void> _insertBody(DatabaseExecutor tx, ContentBody body) async {
    final id = body.revision.id;
    switch (body) {
      case LessonContent(:final title, :final sections):
        await tx.insert('lessons', {
          'revision_id': id,
          'title_reading_text_id': title.id,
        });
        for (final section in sections) {
          await tx.insert('lesson_sections', {
            'id': section.id,
            'lesson_revision_id': id,
            'ordinal': section.ordinal,
            'title_reading_text_id': section.title.id,
            'body_reading_text_id': section.body.id,
          });
        }
      case VocabularyContent(:final written, :final meaning):
        await tx.insert('vocabulary', {
          'revision_id': id,
          'written_reading_text_id': written.id,
          'meaning': meaning,
        });
      case GrammarContent(:final pattern, :final explanation):
        await tx.insert('grammar', {
          'revision_id': id,
          'pattern_reading_text_id': pattern.id,
          'explanation': explanation,
        });
      case KanjiContent(:final character, :final context, :final meaning):
        await tx.insert('kanji', {
          'revision_id': id,
          'character': character,
          'contextual_reading_text_id': context.id,
          'meaning': meaning,
        });
      case KanaContent(
        :final scriptType,
        :final writtenKana,
        :final pronunciation,
        :final readingReference,
        :final learningAvailable,
        :final practiceAvailable,
      ):
        await tx.insert('kana_content', {
          'revision_id': id,
          'script_type': scriptType.name,
          'written_kana': writtenKana,
          'pronunciation': pronunciation,
          'reading_reference': readingReference,
          'learning_available': learningAvailable ? 1 : 0,
          'practice_available': practiceAvailable ? 1 : 0,
        });
      case ExampleSentenceContent(:final sentence, :final translation):
        await tx.insert('example_sentences', {
          'revision_id': id,
          'sentence_reading_text_id': sentence.id,
          'translation': translation,
        });
      case QuestionContent(
        :final prompt,
        :final readingAidPolicy,
        :final explanation,
        :final correctOptionId,
        :final options,
      ):
        await tx.insert('questions', {
          'revision_id': id,
          'prompt_reading_text_id': prompt.id,
          'answer_mode': 'singleChoice',
          'reading_aid_policy': readingAidPolicy.name,
          'explanation': explanation,
          'correct_option_id': correctOptionId,
        });
        for (final option in options) {
          await tx.insert('question_options', {
            'id': option.id,
            'question_revision_id': id,
            'ordinal': option.ordinal,
            'content_reading_text_id': option.content.id,
          });
        }
    }
  }

  ContentKind _kindOf(ContentBody body) => switch (body) {
    LessonContent() => ContentKind.lesson,
    VocabularyContent() => ContentKind.vocabulary,
    GrammarContent() => ContentKind.grammar,
    KanjiContent() => ContentKind.kanji,
    KanaContent() => ContentKind.kana,
    ExampleSentenceContent() => ContentKind.exampleSentence,
    QuestionContent() => ContentKind.question,
  };
}
