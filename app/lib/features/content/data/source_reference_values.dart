import '../domain/content_models.dart';

/// The only conversion point between source governance enums and SQLite text.
abstract final class SourceReferenceValues {
  static String encodeReviewStatus(SourceReviewStatus value) => value.name;

  static SourceReviewStatus decodeReviewStatus(String value) =>
      SourceReviewStatus.values.byName(value);

  static String encodeUsageStatus(ContentUsageStatus value) => switch (value) {
    ContentUsageStatus.referenceOnly => 'reference-only',
    ContentUsageStatus.originalContent => 'original-content',
    ContentUsageStatus.licensed => 'licensed',
    ContentUsageStatus.needsReview => 'needs-review',
    ContentUsageStatus.blocked => 'blocked',
  };

  static ContentUsageStatus decodeUsageStatus(String value) => switch (value) {
    'reference-only' => ContentUsageStatus.referenceOnly,
    'original-content' => ContentUsageStatus.originalContent,
    'licensed' => ContentUsageStatus.licensed,
    'needs-review' => ContentUsageStatus.needsReview,
    'blocked' => ContentUsageStatus.blocked,
    _ => throw FormatException('Unknown content usage status.', value),
  };
}
