import '../../content/domain/content_models.dart';

/// DR-L01-01/02: presentation only, bound to the approved L01 v3 release.
/// A future release or another lesson always receives generic core treatment.
abstract final class LessonSectionPresentationPolicy {
  static const contentVersionId = '01a0fbf6-2ffe-72c2-aab3-00cd733ea8ec';
  static const lessonContentId = '01a0e831-72b8-79e2-9331-0496be402d48';
  static const _categories = [
    '學習目標',
    '字彙',
    '補充',
    '句型',
    '例句',
    '問句',
    '回答',
    '小練習',
    '重點複習',
  ];

  static ({String? category, bool supplementary}) resolve(
    ContentRevision lesson,
    int ordinal,
  ) {
    if (lesson.contentVersionId != contentVersionId ||
        lesson.contentId != lessonContentId ||
        ordinal < 0 ||
        ordinal >= _categories.length) {
      return (category: null, supplementary: false);
    }
    return (category: _categories[ordinal], supplementary: ordinal == 2);
  }
}
