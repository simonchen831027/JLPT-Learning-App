import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../content/domain/content_models.dart';
import '../../learning/presentation/reading_line.dart';
import 'practice_view_model.dart';

TextStyle? _japaneseStyle(BuildContext context) => Theme.of(context)
    .textTheme
    .bodyLarge
    ?.copyWith(
      fontSize: MediaQuery.sizeOf(context).width < 720 ? 22 : 24,
      height: 1.6,
    );

class PracticePage extends StatefulWidget {
  const PracticePage({
    required this.actions,
    required this.contextId,
    super.key,
  });
  final PracticeActions actions;
  final String contextId;
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late final PracticeViewModel _model;
  final _questionFocus = FocusNode(debugLabel: 'Practice question');
  final _validationFocus = FocusNode(debugLabel: 'Option validation');
  final _feedbackFocus = FocusNode(debugLabel: 'Practice feedback');
  final _errorFocus = FocusNode(debugLabel: 'Practice error');
  final _resultFocus = FocusNode(debugLabel: 'Practice result');
  final _scroll = ScrollController();
  final _optionGroup = GlobalKey<_PracticeOptionGroupState>();
  int _lastFocusRevision = -1;

  @override
  void initState() {
    super.initState();
    _model = PracticeViewModel(widget.actions, widget.contextId)
      ..addListener(_focusChanged);
    unawaited(_model.open());
  }

  void _focusChanged() {
    if (_lastFocusRevision == _model.focusRevision) return;
    _lastFocusRevision = _model.focusRevision;
    final target = switch (_model.focus) {
      PracticeFocus.question => _questionFocus,
      PracticeFocus.validation => _validationFocus,
      PracticeFocus.feedback => _feedbackFocus,
      PracticeFocus.error => _errorFocus,
      PracticeFocus.result => _resultFocus,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || target.context == null) return;
      target.requestFocus();
      unawaited(Scrollable.ensureVisible(target.context!, alignment: 0.1));
    });
  }

  @override
  void dispose() {
    _model.removeListener(_focusChanged);
    _model.dispose();
    for (final node in [
      _questionFocus,
      _validationFocus,
      _feedbackFocus,
      _errorFocus,
      _resultFocus,
    ]) {
      node.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _model,
    builder: (context, _) => PopScope<void>(
      canPop: !_model.mutationLocked,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('N5｜L01 練習'),
          leading: IconButton(
            tooltip: '返回課程',
            icon: const Icon(Icons.arrow_back),
            onPressed: _model.mutationLocked
                ? null
                : () => Navigator.of(context).pop(),
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final inset = constraints.maxWidth < 720 ? 16.0 : 32.0;
              return SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(
                  inset,
                  24,
                  inset,
                  32 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SelectionArea(
                      child: FocusTraversalGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _contents(context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  List<Widget> _contents(BuildContext context) {
    final theme = Theme.of(context);
    if (_model.phase == PracticePhase.completedResult) {
      final result = _model.result!;
      return [
        _heading('本次練習已完成', _resultFocus, key: const Key('result-heading')),
        const SizedBox(height: 24),
        Text('作答題數：${result.answerCount}'),
        const SizedBox(height: 12),
        Text('答對題數：${result.correctCount}'),
        const SizedBox(height: 12),
        Text('答錯題數：${result.wrongCount}'),
        const SizedBox(height: 24),
        _action('返回課程', () => Navigator.of(context).pop()),
      ];
    }
    if (_model.phase == PracticePhase.resultLoading ||
        _model.phase == PracticePhase.resultReadError) {
      return [
        if (_model.error != null) _errorPanel(),
        if (_model.phase == PracticePhase.resultLoading)
          const PracticeStatus('正在讀取本次結果…'),
      ];
    }
    final state = _model.state;
    if (state == null) {
      return [
        if (_model.error != null)
          _errorPanel()
        else
          const PracticeStatus('正在開啟練習…'),
      ];
    }
    final item = state.currentQuestion;
    final question = item.question;
    final saved = _model.answer;
    final showReading = question.readingAidPolicy != ReadingAidPolicy.hide;
    final error = _model.error;
    return [
      Text(
        '題目 ${state.session.currentOrdinal + 1} / ${state.session.questionCount}',
        key: const Key('question-position'),
      ),
      const SizedBox(height: 16),
      Focus(
        focusNode: _questionFocus,
        skipTraversal: true,
        child: Semantics(
          header: true,
          child: ReadingLine(
            question.prompt,
            showReadings: showReading,
            style: _japaneseStyle(context),
          ),
        ),
      ),
      const SizedBox(height: 24),
      Focus(
        focusNode: _validationFocus,
        skipTraversal: true,
        onKeyEvent: (_, event) {
          if (_model.canSelect &&
              event is KeyDownEvent &&
              [
                LogicalKeyboardKey.space,
                LogicalKeyboardKey.arrowDown,
                LogicalKeyboardKey.arrowRight,
                LogicalKeyboardKey.arrowUp,
                LogicalKeyboardKey.arrowLeft,
              ].contains(event.logicalKey)) {
            _optionGroup.currentState?.enter();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Semantics(
          container: true,
          label: _model.validation ? '選擇一個答案。請先選擇一個答案。' : '選擇一個答案',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_model.validation)
                const ExcludeSemantics(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '請先選擇一個答案。',
                            key: Key('empty-validation'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              PracticeOptionGroup(
                key: _optionGroup,
                question: question,
                selection: _model.selection,
                editable: _model.canSelect,
                savedOptionId: saved?.submittedOptionId,
                correct: saved?.isCorrect,
                showReading: showReading,
                onSelect: _model.select,
              ),
            ],
          ),
        ),
      ),
      if (saved != null) ...[
        const SizedBox(height: 24),
        PracticePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _heading(
                saved.isCorrect ? '✓ 答對了' : '✕ 答錯了',
                _feedbackFocus,
                key: const Key('feedback-heading'),
              ),
              const SizedBox(height: 16),
              Text('你的答案', style: theme.textTheme.titleMedium),
              ReadingLine(
                question.options
                    .singleWhere((o) => o.id == saved.submittedOptionId)
                    .content,
                showReadings: showReading,
                style: _japaneseStyle(context),
              ),
              const SizedBox(height: 16),
              Text('正確答案', style: theme.textTheme.titleMedium),
              ReadingLine(
                question.options
                    .singleWhere((o) => o.id == question.correctOptionId)
                    .content,
                showReadings: showReading,
                style: _japaneseStyle(context),
              ),
              const SizedBox(height: 16),
              Text('解析', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                question.explanation,
                key: const Key('explanation'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.75,
                ),
              ),
            ],
          ),
        ),
      ],
      if (error != null) ...[
        const SizedBox(height: 24),
        _errorPanel(showRetry: !_model.canAdvance),
      ],
      if (_model.busy) ...[
        const SizedBox(height: 16),
        PracticeStatus(switch (_model.phase) {
          PracticePhase.submitting => '正在保存答案…',
          PracticePhase.continuing => '正在開啟下一題…',
          PracticePhase.completing => '正在完成本次練習…',
          PracticePhase.reconciling => '正在確認作答狀態…',
          _ => '正在讀取作答狀態…',
        }),
      ],
      const SizedBox(height: 24),
      if (_model.canSelect || _model.phase == PracticePhase.submitting)
        _action('提交答案', _model.submit, processing: _model.busy),
      if (_model.canAdvance ||
          _model.phase == PracticePhase.continuing ||
          _model.phase == PracticePhase.completing)
        _action(
          _model.isLast ? '查看本次結果' : '下一題',
          _model.advance,
          processing: _model.busy,
        ),
    ];
  }

  Widget _heading(String text, FocusNode node, {Key? key}) => Focus(
    focusNode: node,
    skipTraversal: true,
    child: Semantics(
      header: true,
      child: Text(
        text,
        key: key,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    ),
  );

  Widget _errorPanel({bool showRetry = true}) => PracticePanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(_model.error!, _errorFocus, key: const Key('practice-error')),
        if (showRetry && _model.canRetry) ...[
          const SizedBox(height: 16),
          _action('重新載入', _model.retry),
        ],
      ],
    ),
  );

  Widget _action(
    String label,
    VoidCallback onPressed, {
    bool processing = false,
  }) => Align(
    alignment: Alignment.centerRight,
    child: SizedBox(
      width: MediaQuery.sizeOf(context).width < 720 ? double.infinity : null,
      child: Semantics(
        button: true,
        label: label,
        enabled: !processing,
        onTap: processing ? null : onPressed,
        excludeSemantics: true,
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.all(16),
          ),
          // Keep the focused action attached throughout an asynchronous mutation.
          // The ViewModel guards duplicate actions; no global Enter shortcut.
          onPressed: processing ? () {} : onPressed,
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    ),
  );
}

class PracticePanel extends StatelessWidget {
  const PracticePanel({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

class PracticeStatus extends StatelessWidget {
  const PracticeStatus(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: message,
    excludeSemantics: true,
    child: Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 12),
        Text(message),
      ],
    ),
  );
}

class PracticeOptionGroup extends StatefulWidget {
  const PracticeOptionGroup({
    required this.question,
    required this.selection,
    required this.editable,
    required this.onSelect,
    required this.showReading,
    this.savedOptionId,
    this.correct,
    super.key,
  });
  final QuestionContent question;
  final String? selection;
  final bool editable;
  final bool showReading;
  final String? savedOptionId;
  final bool? correct;
  final ValueChanged<String> onSelect;
  @override
  State<PracticeOptionGroup> createState() => _PracticeOptionGroupState();
}

class _PracticeOptionGroupState extends State<PracticeOptionGroup> {
  late final List<FocusNode> _nodes;
  int _roving = 0;
  @override
  void initState() {
    super.initState();
    _nodes = [
      for (var i = 0; i < widget.question.options.length; i++)
        FocusNode(debugLabel: 'Option $i'),
    ];
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void enter() {
    if (!widget.editable) return;
    _nodes[_roving].requestFocus();
    widget.onSelect(widget.question.options[_roving].id);
  }

  @override
  void didUpdateWidget(PracticeOptionGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.revision.id != widget.question.revision.id) {
      _roving = 0;
    }
  }

  KeyEventResult _key(int index, KeyEvent event) {
    if (!widget.editable || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft) {
      final delta =
          key == LogicalKeyboardKey.arrowDown ||
              key == LogicalKeyboardKey.arrowRight
          ? 1
          : -1;
      final next = (index + delta) % _nodes.length;
      setState(() => _roving = next);
      _nodes[next].requestFocus();
      widget.onSelect(widget.question.options[next].id);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.space) {
      widget.onSelect(widget.question.options[index].id);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var index = 0; index < widget.question.options.length; index++) ...[
        if (index != 0) const SizedBox(height: 12),
        _option(context, index),
      ],
    ],
  );

  Widget _option(BuildContext context, int index) {
    final option = widget.question.options[index];
    final selected = option.id == widget.selection;
    final submitted = option.id == widget.savedOptionId;
    final isAnswer =
        widget.savedOptionId != null &&
        option.id == widget.question.correctOptionId;
    final badge = submitted
        ? (widget.correct! ? '你的答案・正確' : '你的答案・錯誤')
        : isAnswer
        ? '正確答案'
        : null;
    final scheme = Theme.of(context).colorScheme;
    final focused = _nodes[index].hasFocus;
    return Focus(
      focusNode: _nodes[index],
      skipTraversal: !widget.editable || index != _roving,
      onFocusChange: (_) {
        if (mounted) setState(() {});
      },
      onKeyEvent: (_, event) => _key(index, event),
      child: Semantics(
        container: true,
        inMutuallyExclusiveGroup: true,
        checked: selected,
        enabled: widget.editable,
        label:
            '${option.content.surface}${badge == null ? '' : '，$badge'}${widget.savedOptionId == null ? '' : '，已提交，不可更改'}',
        onTap: widget.editable ? () => widget.onSelect(option.id) : null,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: focused ? scheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Material(
                  color: selected ? scheme.primaryContainer : scheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected || isAnswer
                          ? scheme.primary
                          : scheme.outline,
                      width: isAnswer ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    canRequestFocus: false,
                    onTap: widget.editable
                        ? () {
                            setState(() => _roving = index);
                            _nodes[index].requestFocus();
                            widget.onSelect(option.id);
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReadingLine(
                                  option.content,
                                  showReadings: widget.showReading,
                                  style: _japaneseStyle(context),
                                ),
                                if (badge != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        submitted && !widget.correct!
                                            ? Icons.close
                                            : Icons.check,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(badge)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
