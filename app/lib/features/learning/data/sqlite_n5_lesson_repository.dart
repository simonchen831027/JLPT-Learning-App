import '../../content/data/b0_content_ids.dart';
import '../../content/data/sqlite_content_repository.dart';
import '../../content/domain/content_models.dart';
import '../domain/n5_lesson_repository.dart';

/// N5 curriculum order comes from the approved B0 manifest. Learner-visible
/// fields are loaded only from the current published SQLite revision.
final class SqliteN5LessonRepository implements N5LessonRepository {
  const SqliteN5LessonRepository(this._openContentRepository);

  final Future<SqliteContentRepository> Function() _openContentRepository;

  @override
  Future<List<N5LessonSummary>> listLessons() async {
    final repository = await _openContentRepository();
    final lesson = await repository.currentPublishedByContentId(
      B0ContentIds.lesson,
    );
    if (lesson == null) return const [];
    if (lesson is! LessonContent) throw StateError('Invalid lesson content.');
    return [
      N5LessonSummary(
        contentId: B0ContentIds.lesson,
        ordinal: 0,
        title: lesson.title,
      ),
    ];
  }

  @override
  Future<N5LessonDetail?> getLesson(String contentId) async {
    if (contentId != B0ContentIds.lesson) return null;
    final repository = await _openContentRepository();
    final lesson = await repository.currentPublishedByContentId(contentId);
    if (lesson == null) return null;
    if (lesson is! LessonContent) throw StateError('Invalid lesson content.');

    Future<List<T>> load<T extends ContentBody>(List<String> contentIds) async {
      final items = <T>[];
      for (final id in contentIds) {
        final body = await repository.currentPublishedByContentId(id);
        if (body is! T) throw StateError('Incomplete published B0 release.');
        items.add(body);
      }
      return items;
    }

    final examples = await load<ExampleSentenceContent>(B0ContentIds.examples);
    if (!lesson.sections.any(
          (section) =>
              section.ordinal == B0ContentIds.g01ExamplesSectionOrdinal,
        ) ||
        !lesson.sections.any(
          (section) =>
              section.ordinal == B0ContentIds.g02ExamplesSectionOrdinal,
        )) {
      throw StateError('Incomplete published B0 lesson flow.');
    }
    return N5LessonDetail(
      lesson: lesson,
      vocabulary: await load<VocabularyContent>(B0ContentIds.vocabulary),
      grammar: await load<GrammarContent>(B0ContentIds.grammar),
      kanji: await load<KanjiContent>(B0ContentIds.kanji),
      examples: examples,
      examplesAfterSection: {
        B0ContentIds.g01ExamplesSectionOrdinal: examples.sublist(0, 3),
        B0ContentIds.g02ExamplesSectionOrdinal: examples.sublist(3),
      },
    );
  }
}
