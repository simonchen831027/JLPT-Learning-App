import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/home/domain/initialize_app.dart';
import '../features/home/presentation/home_page.dart';
import '../features/home/presentation/home_view_model.dart';
import '../features/learning/domain/n5_lesson_use_cases.dart';
import '../features/practice/presentation/practice_view_model.dart';
import 'theme.dart';

class JlptLearningApp extends StatefulWidget {
  const JlptLearningApp({
    required this.initializeApp,
    required this.listN5Lessons,
    required this.getN5Lesson,
    this.practiceActions,
    super.key,
  });
  final InitializeApp initializeApp;
  final ListN5Lessons listN5Lessons;
  final GetN5Lesson getN5Lesson;
  final PracticeActions? practiceActions;
  @override
  State<JlptLearningApp> createState() => _JlptLearningAppState();
}

class _JlptLearningAppState extends State<JlptLearningApp> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(widget.initializeApp);
    unawaited(_viewModel.initialize());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'JLPT 學習',
    debugShowCheckedModeBanner: false,
    locale: const Locale('zh', 'TW'),
    supportedLocales: const [Locale('zh', 'TW')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(),
    home: HomePage(
      viewModel: _viewModel,
      listN5Lessons: widget.listN5Lessons,
      getN5Lesson: widget.getN5Lesson,
      practiceActions: widget.practiceActions,
    ),
  );
}
