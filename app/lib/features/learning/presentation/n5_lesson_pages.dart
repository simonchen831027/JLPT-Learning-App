import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/n5_lesson_use_cases.dart';
import 'n5_lesson_view_models.dart';
import 'reading_line.dart';

class N5LessonListPage extends StatefulWidget {
  const N5LessonListPage({
    required this.listLessons,
    required this.getLesson,
    super.key,
  });
  final ListN5Lessons listLessons;
  final GetN5Lesson getLesson;

  @override
  State<N5LessonListPage> createState() => _N5LessonListPageState();
}

class _N5LessonListPageState extends State<N5LessonListPage> {
  late final N5LessonListViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = N5LessonListViewModel(widget.listLessons);
    unawaited(_model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('N5 課程')),
    body: ListenableBuilder(
      listenable: _model,
      builder: (context, _) => switch (_model.status) {
        LessonLoadStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        LessonLoadStatus.empty => const Center(child: Text('目前沒有可閱讀的 N5 課程。')),
        LessonLoadStatus.failed => _Retry(
          onRetry: _model.load,
          message: '無法讀取 N5 課程。',
        ),
        LessonLoadStatus.ready => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _model.lessons.length,
          itemBuilder: (context, index) {
            final lesson = _model.lessons[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(lesson.title.surface),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => N5LessonDetailPage(
                      contentId: lesson.contentId,
                      getLesson: widget.getLesson,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      },
    ),
  );
}

class N5LessonDetailPage extends StatefulWidget {
  const N5LessonDetailPage({
    required this.contentId,
    required this.getLesson,
    super.key,
  });
  final String contentId;
  final GetN5Lesson getLesson;

  @override
  State<N5LessonDetailPage> createState() => _N5LessonDetailPageState();
}

class _N5LessonDetailPageState extends State<N5LessonDetailPage> {
  late final N5LessonDetailViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = N5LessonDetailViewModel(widget.getLesson, widget.contentId);
    unawaited(_model.load());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('N5｜L01')),
    body: ListenableBuilder(
      listenable: _model,
      builder: (context, _) => switch (_model.status) {
        LessonLoadStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        LessonLoadStatus.empty => const Center(child: Text('找不到已發布的課程。')),
        LessonLoadStatus.failed => _Retry(
          onRetry: _model.load,
          message: '無法讀取課程內容。',
        ),
        LessonLoadStatus.ready => _content(context),
      },
    ),
  );

  Widget _content(BuildContext context) {
    final detail = _model.detail!;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          detail.lesson.title.surface,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        for (final section in detail.lesson.sections) ...[
          Text(section.title.surface, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(section.body.surface),
          for (final item in detail.examplesAfterSection[section.ordinal] ?? [])
            Card(
              child: ListTile(
                title: ReadingLine(item.sentence),
                subtitle: Text(item.translation),
              ),
            ),
          const SizedBox(height: 24),
        ],
        Text('Vocabulary', style: theme.textTheme.titleLarge),
        for (final item in detail.vocabulary)
          Card(
            child: ListTile(
              title: ReadingLine(item.written),
              subtitle: Text(item.meaning),
            ),
          ),
        const SizedBox(height: 20),
        Text('Grammar', style: theme.textTheme.titleLarge),
        for (final item in detail.grammar)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReadingLine(item.pattern),
                  const SizedBox(height: 8),
                  Text(item.explanation),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text('Kanji', style: theme.textTheme.titleLarge),
        for (final item in detail.kanji)
          Card(
            child: ListTile(
              leading: Text(
                item.character,
                style: theme.textTheme.headlineSmall,
              ),
              title: ReadingLine(item.context),
              subtitle: Text(item.meaning),
            ),
          ),
      ],
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry, required this.message});
  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: 16),
        FilledButton(onPressed: onRetry, child: const Text('重試')),
      ],
    ),
  );
}
