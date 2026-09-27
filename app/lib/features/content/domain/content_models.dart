enum ContentKind {
  lesson,
  vocabulary,
  grammar,
  kanji,
  kana,
  exampleSentence,
  question,
}

enum ContentReviewStatus { draft, reviewed, published, withdrawn }

enum SourceReviewStatus { pending, approved, rejected }

enum ContentUsageStatus {
  referenceOnly,
  originalContent,
  licensed,
  needsReview,
  blocked,
}

enum KanaScriptType { hiragana, katakana }

enum ReadingAidPolicy { inherit, show, hide }

final class ContentVersion {
  const ContentVersion({
    required this.id,
    required this.label,
    required this.createdAt,
    this.isCurrent = false,
  });

  final String id;
  final String label;
  final DateTime createdAt;
  final bool isCurrent;
}

final class ContentRevision {
  const ContentRevision({
    required this.id,
    required this.contentId,
    required this.contentVersionId,
    required this.kind,
    required this.reviewStatus,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String contentId;
  final String contentVersionId;
  final ContentKind kind;
  final ContentReviewStatus reviewStatus;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class ReadingSegment {
  const ReadingSegment({
    required this.id,
    required this.ordinal,
    required this.surface,
    this.reading,
  });

  final String id;
  final int ordinal;
  final String surface;
  final String? reading;
}

final class ReadingText {
  ReadingText({
    required this.id,
    required this.surface,
    required List<ReadingSegment> segments,
  }) : segments = List.unmodifiable(segments);

  final String id;
  final String surface;
  final List<ReadingSegment> segments;

  void validate() {
    if (segments.isEmpty ||
        segments.map((segment) => segment.surface).join() != surface) {
      throw ArgumentError('Reading segments must cover the surface exactly.');
    }
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      if (segment.ordinal != index ||
          segment.surface.isEmpty ||
          segment.reading == '') {
        throw ArgumentError('Reading segments must be ordered and nonempty.');
      }
    }
  }
}

final class SourceReference {
  const SourceReference({
    required this.id,
    required this.sourceName,
    required this.contentUsageStatus,
    required this.reviewStatus,
    required this.createdAt,
    required this.updatedAt,
    this.sourceUrl,
    this.sourceTitle,
    this.topic,
    this.referenceLevel,
    this.accessedAt,
    this.note,
  });

  final String id;
  final String sourceName;
  final String? sourceUrl;
  final String? sourceTitle;
  final String? topic;
  final String? referenceLevel;
  final DateTime? accessedAt;
  final ContentUsageStatus contentUsageStatus;
  final SourceReviewStatus reviewStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;

  bool get isPublicationEligible =>
      reviewStatus == SourceReviewStatus.approved &&
      switch (contentUsageStatus) {
        ContentUsageStatus.referenceOnly ||
        ContentUsageStatus.originalContent ||
        ContentUsageStatus.licensed => true,
        ContentUsageStatus.needsReview || ContentUsageStatus.blocked => false,
      };
}

sealed class ContentBody {
  const ContentBody(this.revision);

  final ContentRevision revision;
  Iterable<ReadingText> get readingTexts;
}

final class LessonContent extends ContentBody {
  LessonContent({
    required ContentRevision revision,
    required this.title,
    required List<LessonSection> sections,
  }) : sections = List.unmodifiable(sections),
       super(revision);

  final ReadingText title;
  final List<LessonSection> sections;

  @override
  Iterable<ReadingText> get readingTexts => [
    title,
    for (final section in sections) ...[section.title, section.body],
  ];
}

final class LessonSection {
  const LessonSection({
    required this.id,
    required this.ordinal,
    required this.title,
    required this.body,
  });

  final String id;
  final int ordinal;
  final ReadingText title;
  final ReadingText body;
}

final class VocabularyContent extends ContentBody {
  const VocabularyContent({
    required ContentRevision revision,
    required this.written,
    required this.meaning,
  }) : super(revision);

  final ReadingText written;
  final String meaning;

  @override
  Iterable<ReadingText> get readingTexts => [written];
}

final class GrammarContent extends ContentBody {
  const GrammarContent({
    required ContentRevision revision,
    required this.pattern,
    required this.explanation,
  }) : super(revision);

  final ReadingText pattern;
  final String explanation;

  @override
  Iterable<ReadingText> get readingTexts => [pattern];
}

final class KanjiContent extends ContentBody {
  const KanjiContent({
    required ContentRevision revision,
    required this.character,
    required this.context,
    required this.meaning,
  }) : super(revision);

  final String character;
  final ReadingText context;
  final String meaning;

  @override
  Iterable<ReadingText> get readingTexts => [context];
}

final class KanaContent extends ContentBody {
  const KanaContent({
    required ContentRevision revision,
    required this.scriptType,
    required this.writtenKana,
    required this.pronunciation,
    required this.readingReference,
    required this.learningAvailable,
    required this.practiceAvailable,
  }) : super(revision);

  final KanaScriptType scriptType;
  final String writtenKana;
  final String pronunciation;
  final String readingReference;
  final bool learningAvailable;
  final bool practiceAvailable;

  @override
  Iterable<ReadingText> get readingTexts => const [];
}

final class ExampleSentenceContent extends ContentBody {
  const ExampleSentenceContent({
    required ContentRevision revision,
    required this.sentence,
    required this.translation,
  }) : super(revision);

  final ReadingText sentence;
  final String translation;

  @override
  Iterable<ReadingText> get readingTexts => [sentence];
}

final class QuestionOption {
  const QuestionOption({
    required this.id,
    required this.ordinal,
    required this.content,
  });

  final String id;
  final int ordinal;
  final ReadingText content;
}

final class QuestionContent extends ContentBody {
  QuestionContent({
    required ContentRevision revision,
    required this.prompt,
    required this.readingAidPolicy,
    required this.explanation,
    required List<QuestionOption> options,
    required this.correctOptionId,
  }) : options = List.unmodifiable(options),
       super(revision);

  final ReadingText prompt;
  final ReadingAidPolicy readingAidPolicy;
  final String explanation;
  final List<QuestionOption> options;
  final String correctOptionId;

  @override
  Iterable<ReadingText> get readingTexts => [
    prompt,
    for (final option in options) option.content,
  ];
}
