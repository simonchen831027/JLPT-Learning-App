import '../../content/domain/content_models.dart';

final class N5LessonSummary {
  const N5LessonSummary({
    required this.contentId,
    required this.ordinal,
    required this.title,
  });

  final String contentId;
  final int ordinal;
  final ReadingText title;
}

final class N5LessonDetail {
  N5LessonDetail({
    required this.lesson,
    required List<VocabularyContent> vocabulary,
    required List<GrammarContent> grammar,
    required List<KanjiContent> kanji,
    required List<ExampleSentenceContent> examples,
    required Map<int, List<ExampleSentenceContent>> examplesAfterSection,
  }) : vocabulary = List.unmodifiable(vocabulary),
       grammar = List.unmodifiable(grammar),
       kanji = List.unmodifiable(kanji),
       examples = List.unmodifiable(examples),
       examplesAfterSection = Map.unmodifiable({
         for (final entry in examplesAfterSection.entries)
           entry.key: List<ExampleSentenceContent>.unmodifiable(entry.value),
       });

  final LessonContent lesson;
  final List<VocabularyContent> vocabulary;
  final List<GrammarContent> grammar;
  final List<KanjiContent> kanji;
  final List<ExampleSentenceContent> examples;
  final Map<int, List<ExampleSentenceContent>> examplesAfterSection;
}

abstract interface class N5LessonRepository {
  Future<List<N5LessonSummary>> listLessons();
  Future<N5LessonDetail?> getLesson(String contentId);
}
