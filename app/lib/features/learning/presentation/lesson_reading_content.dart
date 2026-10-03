import 'package:flutter/material.dart';

import '../../content/domain/content_models.dart';
import '../domain/n5_lesson_repository.dart' show N5LessonDetail;
import 'lesson_section_presentation_policy.dart';
import 'reading_line.dart';

/// Lesson-local layout and typography; no global theme or learning policy.
class LessonReadingContent extends StatelessWidget {
  const LessonReadingContent({
    required this.detail,
    this.trailing = const [],
    super.key,
  });
  final N5LessonDetail detail;

  /// Caller-owned presentation after the reference groups in the same scroll.
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 784;
        final theme = Theme.of(context);
        final styles = _LessonStyles(theme, wide);
        return Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              labelSmall: theme.textTheme.labelSmall?.copyWith(
                fontSize: wide ? 13 : 12,
                height: 1.25,
              ),
            ),
          ),
          child: SelectionArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 32 : 16,
                vertical: 32,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ReadingHeading(
                          detail.lesson.title,
                          styles.lessonTitle,
                        ),
                        SizedBox(height: styles.sectionGap),
                        for (
                          var i = 0;
                          i < detail.lesson.sections.length;
                          i++
                        ) ...[
                          _section(detail.lesson.sections[i], styles),
                          SizedBox(height: _gapAfter(i, styles)),
                        ],
                        const Divider(height: 1),
                        SizedBox(height: styles.sectionGap / 2),
                        _ReferenceGroup(
                          title: '單字整理',
                          styles: styles,
                          children: [
                            for (final item in detail.vocabulary)
                              _ReadingRecord(
                                reading: item.written,
                                text: item.meaning,
                                styles: styles,
                              ),
                          ],
                        ),
                        SizedBox(height: styles.sectionGap),
                        _ReferenceGroup(
                          title: '句型整理',
                          styles: styles,
                          children: [
                            for (final item in detail.grammar)
                              _ReadingRecord(
                                reading: item.pattern,
                                text: item.explanation,
                                styles: styles,
                              ),
                          ],
                        ),
                        SizedBox(height: styles.sectionGap),
                        _ReferenceGroup(
                          title: '漢字整理',
                          styles: styles,
                          children: [
                            for (final item in detail.kanji)
                              Padding(
                                padding: EdgeInsets.only(bottom: styles.rowGap),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Text(
                                        item.character,
                                        style: styles.japanese,
                                      ),
                                    ),
                                    Expanded(
                                      child: _ReadingRecord(
                                        reading: item.context,
                                        text: item.meaning,
                                        styles: styles,
                                        bottomGap: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        ...trailing,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  double _gapAfter(int index, _LessonStyles styles) {
    final sections = detail.lesson.sections;
    if (index == sections.length - 1) return styles.sectionGap / 2;
    final current = LessonSectionPresentationPolicy.resolve(
      detail.lesson.revision,
      sections[index].ordinal,
    );
    final next = index + 1 < sections.length
        ? LessonSectionPresentationPolicy.resolve(
            detail.lesson.revision,
            sections[index + 1].ordinal,
          )
        : null;
    return current.supplementary || (next?.supplementary ?? false)
        ? styles.supplementGap
        : styles.sectionGap;
  }

  Widget _section(LessonSection section, _LessonStyles styles) {
    final presentation = LessonSectionPresentationPolicy.resolve(
      detail.lesson.revision,
      section.ordinal,
    );
    final supplementary = presentation.supplementary;
    final category = presentation.category;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (category != null && category != section.title.surface) ...[
          Text(category, style: styles.category),
          const SizedBox(height: 8),
        ],
        _ReadingHeading(
          section.title,
          supplementary ? styles.calloutTitle : styles.sectionTitle,
        ),
        SizedBox(height: supplementary ? 12 : styles.headingGap),
        ReadingLine(section.body, style: styles.body),
        for (final example
            in detail.examplesAfterSection[section.ordinal] ?? [])
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _ReadingRecord(
              reading: example.sentence,
              text: example.translation,
              styles: styles,
              bottomGap: 0,
            ),
          ),
      ],
    );
    if (!supplementary) return content;
    return Builder(
      builder: (context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: content),
      ),
    );
  }
}

class _ReadingHeading extends StatelessWidget {
  const _ReadingHeading(this.value, this.style);
  final ReadingText value;
  final TextStyle style;
  @override
  Widget build(BuildContext context) =>
      Semantics(header: true, child: ReadingLine(value, style: style));
}

class _ReferenceGroup extends StatelessWidget {
  const _ReferenceGroup({
    required this.title,
    required this.children,
    required this.styles,
  });
  final String title;
  final List<Widget> children;
  final _LessonStyles styles;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(header: true, child: Text(title, style: styles.referenceTitle)),
      SizedBox(height: styles.headingGap),
      ...children,
    ],
  );
}

class _ReadingRecord extends StatelessWidget {
  const _ReadingRecord({
    required this.reading,
    required this.text,
    required this.styles,
    this.bottomGap,
  });
  final ReadingText reading;
  final String text;
  final _LessonStyles styles;
  final double? bottomGap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: bottomGap ?? styles.rowGap),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReadingLine(reading, style: styles.japanese),
        const SizedBox(height: 8),
        Text(text, style: styles.body),
      ],
    ),
  );
}

class _LessonStyles {
  _LessonStyles(ThemeData theme, bool wide)
    : lessonTitle = (theme.textTheme.headlineMedium ?? const TextStyle())
          .copyWith(
            fontSize: wide ? 30 : 26,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
      sectionTitle = (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
        fontSize: wide ? 24 : 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      calloutTitle = (theme.textTheme.titleMedium ?? const TextStyle())
          .copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
      category = (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
        fontSize: 14,
      ),
      referenceTitle = (theme.textTheme.titleLarge ?? const TextStyle())
          .copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      body = (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
        fontSize: 18,
        height: 1.75,
      ),
      japanese = (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
        fontSize: wide ? 24 : 22,
        height: 1.5,
      ),
      sectionGap = wide ? 48 : 32,
      headingGap = wide ? 16 : 12,
      rowGap = wide ? 16 : 12,
      supplementGap = wide ? 32 : 24;
  final TextStyle lessonTitle,
      sectionTitle,
      calloutTitle,
      category,
      referenceTitle,
      body,
      japanese;
  final double sectionGap, headingGap, rowGap, supplementGap;
}
