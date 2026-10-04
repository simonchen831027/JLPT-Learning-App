import 'dart:async';
import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jlpt_learning_app/app/theme.dart';
import 'package:jlpt_learning_app/features/content/data/b0_content_ids.dart';
import 'package:jlpt_learning_app/features/learning/data/sqlite_n5_lesson_repository.dart';
import 'package:jlpt_learning_app/features/learning/domain/n5_lesson_use_cases.dart';
import 'package:jlpt_learning_app/features/learning/presentation/n5_lesson_pages.dart';
import 'package:jlpt_learning_app/features/learning/presentation/reading_line.dart';
import 'package:jlpt_learning_app/features/practice/presentation/practice_page.dart';
import 'package:jlpt_learning_app/features/practice/domain/practice_models.dart';
import 'package:jlpt_learning_app/features/practice/presentation/practice_view_model.dart';

import '../../support/controlled_practice_repository.dart';
import '../../support/practice_fixture.dart';

void main() {
  late PracticeFixture fixture;
  late ControlledPracticeRepository repository;
  setUp(() async {
    fixture = await PracticeFixture.create(
      factory: databaseFactoryFfiNoIsolate,
    );
    repository = ControlledPracticeRepository(fixture.practice);
  });
  tearDown(() => fixture.dispose());

  PracticeViewModel model(WidgetTester tester) =>
      tester
              .widget<ListenableBuilder>(
                find.byWidgetPredicate(
                  (w) =>
                      w is ListenableBuilder &&
                      w.listenable is PracticeViewModel,
                ),
              )
              .listenable
          as PracticeViewModel;

  Future<void> ticks(WidgetTester tester) async {
    // Real SQLite FFI callbacks need real event-loop time, not only fake pumps.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump();
  }

  Future<void> ready(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await ticks(tester);
      final phase = model(tester).phase;
      if (![
        PracticePhase.initialLoading,
        PracticePhase.submitting,
        PracticePhase.continuing,
        PracticePhase.completing,
        PracticePhase.reconciling,
        PracticePhase.resultLoading,
      ].contains(phase)) {
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        return;
      }
    }
    fail('Practice did not reach a settled state');
  }

  Future<void> mount(
    WidgetTester tester, {
    double width = 800,
    double scale = 1,
    bool lesson = false,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final actions = PracticeActions.fromRepository(repository);
    final lessons = SqliteN5LessonRepository(() async => fixture.content);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: lesson
            ? N5LessonDetailPage(
                contentId: B0ContentIds.lesson,
                getLesson: GetN5Lesson(lessons),
                practiceActions: actions,
              )
            : Builder(
                builder: (context) => Scaffold(
                  body: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PracticePage(
                          actions: actions,
                          contextId: B0ContentIds.lesson,
                        ),
                      ),
                    ),
                    child: const Text('開始練習'),
                  ),
                ),
              ),
      ),
    );
    if (lesson) {
      for (
        var i = 0;
        i < 10 && find.text('Kanji', skipOffstage: false).evaluate().isEmpty;
        i++
      ) {
        await ticks(tester);
      }
      await tester.scrollUntilVisible(
        find.text('開始練習'),
        600,
        scrollable: find.byType(Scrollable).last,
      );
    }
    await tester.tap(find.text('開始練習'));
    await tester.pump(const Duration(milliseconds: 400));
    await ready(tester);
  }

  Future<void> tapAction(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(label));
    await ready(tester);
  }

  Future<void> submit(WidgetTester tester, {bool correct = true}) async {
    final vm = model(tester);
    final question = vm.state!.currentQuestion.question;
    vm.select(
      correct
          ? question.correctOptionId
          : question.options
                .firstWhere((o) => o.id != question.correctOptionId)
                .id,
    );
    await tester.pump();
    await tapAction(tester, '提交答案');
  }

  testWidgets(
    'L01 entry, empty validation, role separation, explicit Result and return',
    (tester) async {
      await mount(tester, lesson: true);
      final vm = model(tester);
      final submitButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, '提交答案'),
      );
      expect(submitButton.onPressed, isNotNull);
      await tapAction(tester, '提交答案');
      expect(find.text('請先選擇一個答案。'), findsOneWidget);
      expect(repository.submitCalls, 0);
      expect(find.byKey(const Key('feedback-heading')), findsNothing);
      expect(find.byKey(const Key('explanation')), findsNothing);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'Option validation',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(vm.selection, isNotNull);
      expect(vm.validation, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(vm.selection, vm.state!.currentQuestion.question.options[1].id);
      if (vm.selection == vm.state!.currentQuestion.question.correctOptionId) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
      }
      expect(
        vm.selection,
        isNot(vm.state!.currentQuestion.question.correctOptionId),
      );
      await tapAction(tester, '提交答案');
      expect(find.text('✕ 答錯了'), findsOneWidget);
      expect(find.text('你的答案'), findsOneWidget);
      expect(find.text('正確答案'), findsWidgets);
      expect(
        tester.widget<Text>(find.byKey(const Key('explanation'))).data,
        vm.state!.currentQuestion.question.explanation,
      );
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'Practice feedback',
      );
      final selected = vm.selection;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(vm.selection, selected);
      await tapAction(tester, '下一題');
      await submit(tester);
      expect(find.text('✓ 答對了'), findsOneWidget);
      await tapAction(tester, '下一題');
      await submit(tester);
      expect(find.text('查看本次結果'), findsOneWidget);
      expect(find.byKey(const Key('result-heading')), findsNothing);
      expect(vm.state!.session.completedAt, isNull);
      await tapAction(tester, '查看本次結果');
      expect(find.text('作答題數：3'), findsOneWidget);
      expect(find.text('答對題數：2'), findsOneWidget);
      expect(find.text('答錯題數：1'), findsOneWidget);
      await tester.tap(find.text('返回課程'));
      await tester.pumpAndSettle();
      expect(find.text('N5｜L01'), findsOneWidget);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'Lesson Practice entry',
      );
    },
  );

  testWidgets(
    'delayed Submit hides answers, preserves action focus, blocks Back and duplicates',
    (tester) async {
      await mount(tester);
      final vm = model(tester);
      repository.submitGate = Completer<void>();
      vm.select(vm.state!.currentQuestion.question.correctOptionId);
      await tester.pump();
      await tester.ensureVisible(find.text('提交答案'));
      await tester.tap(find.text('提交答案'));
      await tester.pump();
      expect(find.text('正在保存答案…'), findsOneWidget);
      expect(find.text('正確答案'), findsNothing);
      expect(find.byKey(const Key('explanation')), findsNothing);
      await tester.tap(find.text('提交答案'));
      expect(repository.submitCalls, 1);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      expect(await navigator.maybePop(), isTrue);
      await tester.pump();
      expect(find.byType(PracticePage), findsOneWidget);
      repository.submitGate!.complete();
      await ready(tester);
      expect(vm.canSelect, isFalse);
      await tester.tap(find.byTooltip('返回課程'));
      await tester.pumpAndSettle();
      expect(find.byType(PracticePage), findsNothing);
    },
  );

  testWidgets(
    'unknown Submit reconciliation blocks Back and only read retry reveals original answer',
    (tester) async {
      await mount(tester);
      repository.throwAfterSubmit = true;
      repository.failRead = true;
      await submit(tester);
      expect(model(tester).phase, PracticePhase.reconciliationError);
      expect(find.byKey(const Key('feedback-heading')), findsNothing);
      expect(find.byKey(const Key('explanation')), findsNothing);
      expect(find.byKey(const Key('result-heading')), findsNothing);
      expect(
        tester.widget<PopScope<void>>(find.byType(PopScope<void>)).canPop,
        isFalse,
      );
      expect(
        await tester.runAsync(() => fixture.database.query('quiz_answers')),
        hasLength(1),
      );
      expect(find.byTooltip('返回課程'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.arrow_back),
            )
            .onPressed,
        isNull,
      );
      await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
      await tester.pump();
      expect(find.byType(PracticePage), findsOneWidget);
      await tapAction(tester, '重新載入');
      expect(model(tester).phase, PracticePhase.reconciliationError);
      expect(repository.submitCalls, 1);
      repository.failRead = false;
      await tapAction(tester, '重新載入');
      expect(find.text('✓ 答對了'), findsOneWidget);
      expect(repository.submitCalls, 1);
    },
  );

  testWidgets(
    'explicit Submit failure with read failure unlocks Back and returns to L01',
    (tester) async {
      await mount(tester, lesson: true);
      repository.failSubmit = true;
      repository.failRead = true;
      await submit(tester, correct: false);
      final vm = model(tester);
      expect(
        await tester.runAsync(() => fixture.database.query('quiz_answers')),
        isEmpty,
      );
      expect(vm.selection, isNotNull);
      expect(vm.answer, isNull);
      expect(vm.result, isNull);
      expect(find.byKey(const Key('practice-error')), findsOneWidget);
      expect(find.byKey(const Key('feedback-heading')), findsNothing);
      expect(find.byKey(const Key('explanation')), findsNothing);
      expect(find.byKey(const Key('result-heading')), findsNothing);
      expect(find.text('✕ 答錯了'), findsNothing);
      expect(find.text('✓ 答對了'), findsNothing);
      expect(find.text('正確答案'), findsNothing);
      expect(
        tester.widget<PopScope<void>>(find.byType(PopScope<void>)).canPop,
        isTrue,
      );
      expect(vm.canSelect, isTrue);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.arrow_back),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byTooltip('返回課程'));
      await tester.pumpAndSettle();
      expect(find.byType(PracticePage), findsNothing);
      expect(find.text('N5｜L01'), findsOneWidget);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'Lesson Practice entry',
      );
      expect(repository.submitCalls, 1);
    },
  );
  testWidgets(
    'Submit explicit failure keeps draft without false incorrect or reveal',
    (tester) async {
      await mount(tester);
      repository.failSubmit = true;
      await submit(tester, correct: false);
      expect(find.byKey(const Key('practice-error')), findsOneWidget);
      expect(find.text('✕ 答錯了'), findsNothing);
      expect(find.text('正確答案'), findsNothing);
      expect(model(tester).canSelect, isTrue);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.arrow_back),
            )
            .onPressed,
        isNotNull,
      );
      repository.failSubmit = false;
      await tapAction(tester, '提交答案');
      expect(find.text('✕ 答錯了'), findsOneWidget);
    },
  );

  testWidgets(
    'Continue and completion failure retain full feedback; result read retry never completes twice',
    (tester) async {
      await mount(tester);
      await submit(tester);
      repository.failNext = true;
      await tapAction(tester, '下一題');
      expect(find.text('✓ 答對了'), findsOneWidget);
      expect(find.byKey(const Key('explanation')), findsOneWidget);
      expect(model(tester).state!.session.currentOrdinal, 0);
      repository.failNext = false;
      await tapAction(tester, '下一題');
      await submit(tester);
      await tapAction(tester, '下一題');
      await submit(tester);
      repository.failComplete = true;
      await tapAction(tester, '查看本次結果');
      expect(find.byKey(const Key('result-heading')), findsNothing);
      expect(find.byKey(const Key('explanation')), findsOneWidget);
      repository.failComplete = false;
      repository.failResult = true;
      await tapAction(tester, '查看本次結果');
      expect(find.text('作答題數：3'), findsNothing);
      final completionCount = repository.completeCalls;
      repository.failResult = false;
      await tapAction(tester, '重新載入');
      expect(repository.completeCalls, completionCount);
      expect(find.text('作答題數：3'), findsOneWidget);
    },
  );

  testWidgets(
    'keyboard-only option group and primary actions complete all three questions',
    (tester) async {
      await mount(tester);
      for (var i = 0; i < 3; i++) {
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'Practice question',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(model(tester).selection, isNull);
        expect(FocusManager.instance.primaryFocus?.debugLabel, 'Option 0');
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        final question = model(tester).state!.currentQuestion.question;
        final correctIndex = question.options.indexWhere(
          (o) => o.id == question.correctOptionId,
        );
        expect(correctIndex, isNonNegative);
        for (var step = 0; step < correctIndex; step++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
        }
        expect(model(tester).selection, question.correctOptionId);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await ready(tester);
        expect(find.text('✓ 答對了'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await ready(tester);
      }
      expect(find.text('本次練習已完成'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(PracticePage), findsNothing);
    },
  );

  testWidgets(
    'Continue / Complete lock Back; pure initial / Result read do not',
    (tester) async {
      await mount(tester);
      repository.startGate = Completer<void>();
      final loading = model(tester).open();
      await tester.pump();
      expect(
        tester.widget<PopScope<void>>(find.byType(PopScope<void>)).canPop,
        isTrue,
      );
      repository.startGate!.complete();
      await tester.runAsync(() => loading);
      await ready(tester);
      await submit(tester);
      repository.nextGate = Completer<void>();
      final next = model(tester).advance();
      await tester.pump();
      expect(
        tester.widget<PopScope<void>>(find.byType(PopScope<void>)).canPop,
        isFalse,
      );
      expect(find.byKey(const Key('explanation')), findsOneWidget);
      repository.nextGate!.complete();
      await tester.runAsync(() => next);
      await ready(tester);
      await submit(tester);
      await tapAction(tester, '下一題');
      await submit(tester);
      repository.completeGate = Completer<void>();
      repository.resultGate = Completer<void>();
      final complete = model(tester).advance();
      await tester.pump();
      expect(
        tester.widget<PopScope<void>>(find.byType(PopScope<void>)).canPop,
        isFalse,
      );
      repository.completeGate!.complete();
      for (
        var i = 0;
        i < 20 && model(tester).phase != PracticePhase.resultLoading;
        i++
      ) {
        await ticks(tester);
      }
      expect(model(tester).phase, PracticePhase.resultLoading);
      expect(
        tester.widget<PopScope<void>>(find.byType(PopScope<void>)).canPop,
        isTrue,
      );
      expect(find.text('作答題數：3'), findsNothing);
      repository.resultGate!.complete();
      await tester.runAsync(() => complete);
      await ready(tester);
    },
  );

  testWidgets('durable acknowledged answer stays locked on read failure', (
    tester,
  ) async {
    await mount(tester);
    repository.failRead = true;
    await submit(tester);
    expect(model(tester).canSelect, isFalse);
    expect(find.text('✓ 答對了'), findsOneWidget);
    expect(find.text('提交答案'), findsNothing);
    expect(find.text('下一題'), findsNothing);
    repository.failRead = false;
    await tapAction(tester, '重新載入');
    expect(find.text('下一題'), findsOneWidget);
    expect(repository.submitCalls, 1);
  });

  testWidgets(
    'readonly semantics preserve learner checked choice and distinct correct answer',
    (tester) async {
      await mount(tester);
      final semantics = tester.ensureSemantics();
      try {
        await submit(tester, correct: false);
        final vm = model(tester);
        final question = vm.state!.currentQuestion.question;
        final selected = question.options.singleWhere(
          (o) => o.id == vm.answer!.submittedOptionId,
        );
        final correct = question.options.singleWhere(
          (o) => o.id == question.correctOptionId,
        );
        final learnerNode = tester.getSemantics(
          find.bySemanticsLabel('${selected.content.surface}，你的答案・錯誤，已提交，不可更改'),
        );
        final correctNode = tester.getSemantics(
          find.bySemanticsLabel('${correct.content.surface}，正確答案，已提交，不可更改'),
        );
        expect(
          learnerNode.getSemanticsData().flagsCollection.isChecked,
          CheckedState.isTrue,
        );
        expect(
          correctNode.getSemanticsData().flagsCollection.isChecked,
          CheckedState.isFalse,
        );
        expect(
          learnerNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
        expect(
          correctNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
        expect(
          learnerNode.getSemanticsData().flagsCollection.isEnabled,
          Tristate.isFalse,
        );
        expect(
          correctNode.getSemanticsData().flagsCollection.isEnabled,
          Tristate.isFalse,
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'R1 / R2 / R3 / R4 real SQLite reopen maps to matching Widget states',
    (tester) async {
      await mount(tester);
      await submit(tester);
      Future<void> reopen() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(() => fixture.reopen());
        repository = ControlledPracticeRepository(fixture.practice);
        await mount(tester);
      }

      await reopen();
      expect(find.text('題目 1 / 3'), findsOneWidget);
      expect(find.text('✓ 答對了'), findsOneWidget);
      await tapAction(tester, '下一題');
      await reopen();
      expect(find.text('題目 2 / 3'), findsOneWidget);
      expect(find.byKey(const Key('feedback-heading')), findsNothing);
      await submit(tester);
      await tapAction(tester, '下一題');
      await submit(tester);
      await reopen();
      expect(find.text('題目 3 / 3'), findsOneWidget);
      expect(find.text('查看本次結果'), findsOneWidget);
      repository.failComplete = true;
      await tapAction(tester, '查看本次結果');
      await reopen();
      expect(find.byKey(const Key('result-heading')), findsNothing);
      expect(find.text('查看本次結果'), findsOneWidget);
      await tapAction(tester, '查看本次結果');
      expect(find.text('作答題數：3'), findsOneWidget);
    },
  );

  testWidgets(
    'R5 / R6 / R7 repeated entry and version update preserve session authority',
    (tester) async {
      await mount(tester);
      final firstId = model(tester).state!.session.id;
      final revision = model(tester)
          .state!
          .currentQuestion
          .question
          .revision
          .id;
      await tester.runAsync(() => fixture.publishNextVersion());
      await tester.tap(find.byTooltip('返回課程'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('開始練習'));
      await tester.pump(const Duration(milliseconds: 400));
      await ready(tester);
      expect(model(tester).state!.session.id, firstId);
      expect(
        model(tester).state!.currentQuestion.question.revision.id,
        revision,
      );
      expect(find.text('題目 1 / 3'), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        await submit(tester);
        await tapAction(tester, i == 2 ? '查看本次結果' : '下一題');
      }
      await tester.tap(find.text('返回課程'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('開始練習'));
      await tester.pump(const Duration(milliseconds: 400));
      await ready(tester);
      expect(model(tester).state!.session.id, isNot(firstId));
      expect(
        model(tester).state!.currentQuestion.question.revision.id,
        isNot(revision),
      );
      expect(find.text('題目 1 / 3'), findsOneWidget);
      expect(find.byKey(const Key('feedback-heading')), findsNothing);
    },
  );

  test(
    'Practice Theme text / control / focus contrast satisfies family baseline',
    () {
      final c = buildAppTheme().colorScheme;
      double contrast(Color a, Color b) {
        final x = a.computeLuminance(), y = b.computeLuminance();
        return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
      }

      expect(contrast(c.onSurface, c.surface), greaterThanOrEqualTo(4.5));
      expect(
        contrast(c.onSurface, c.surfaceContainerLow),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(c.onSurface, c.primaryContainer),
        greaterThanOrEqualTo(4.5),
      );
      expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
      expect(contrast(c.outline, c.surface), greaterThanOrEqualTo(3));
      expect(contrast(c.primary, c.surface), greaterThanOrEqualTo(3));
    },
  );

  for (final width in [320.0, 390.0, 720.0, 1200.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      testWidgets(
        'responsive $width / $scale: Q3 ruby and full explanation reflow, Result reachable',
        (tester) async {
          var saved = await fixture.practice.startOrResume(
            B0ContentIds.lesson,
            /* formal mode */
            // Initial setup remains in the production repository.
            QuizMode.practice,
          );
          for (var i = 0; i < 2; i++) {
            await fixture.practice.submitAnswer(
              saved.session.id,
              saved.currentQuestion.id,
              saved.currentQuestion.question.correctOptionId,
            );
            saved = await fixture.practice.continueQuestion(
              saved.session.id,
              saved.currentQuestion.id,
            );
          }
          await mount(tester, width: width, scale: scale);
          expect(find.text('題目 3 / 3'), findsOneWidget);
          final prompt = model(tester).state!.currentQuestion.question.prompt;
          expect(prompt.surface, contains('\n'));
          expect(
            find.byWidgetPredicate(
              (w) => w is ReadingLine && w.value.surface == prompt.surface,
            ),
            findsWidgets,
          );
          expect(tester.takeException(), isNull);
          await submit(tester);
          expect(tester.takeException(), isNull);
          await tapAction(tester, '查看本次結果');
          expect(find.text('作答題數：3'), findsOneWidget);
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.widgetWithText(FilledButton, '返回課程')).height,
            greaterThanOrEqualTo(48),
          );
        },
      );
    }
  }
}
