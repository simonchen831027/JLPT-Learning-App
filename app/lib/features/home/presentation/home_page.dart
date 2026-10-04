import 'package:flutter/material.dart';

import '../../learning/domain/n5_lesson_use_cases.dart';
import '../../learning/presentation/n5_lesson_pages.dart';
import '../../practice/presentation/practice_view_model.dart';
import 'home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.viewModel,
    required this.listN5Lessons,
    required this.getN5Lesson,
    this.practiceActions,
    super.key,
  });
  final HomeViewModel viewModel;
  final ListN5Lessons listN5Lessons;
  final GetN5Lesson getN5Lesson;
  final PracticeActions? practiceActions;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const _labels = ['學習', '複習', '設定'];
  static const _icons = [
    Icons.menu_book_outlined,
    Icons.history_outlined,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final ready = widget.viewModel.status == StartupStatus.ready;
        return Scaffold(
          appBar: AppBar(title: const Text('JLPT 學習')),
          body: SafeArea(
            child: Row(
              children: [
                if (wide && ready) ...[
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: _select,
                    destinations: [
                      for (var i = 0; i < _labels.length; i++)
                        NavigationRailDestination(
                          icon: Icon(_icons[i]),
                          label: Text(_labels[i]),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                ],
                Expanded(child: _body(context)),
              ],
            ),
          ),
          bottomNavigationBar: !wide && ready
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _select,
                  destinations: [
                    for (var i = 0; i < _labels.length; i++)
                      NavigationDestination(
                        icon: Icon(_icons[i]),
                        label: _labels[i],
                      ),
                  ],
                )
              : null,
        );
      },
    ),
  );

  void _select(int index) => setState(() => _selectedIndex = index);

  Widget _body(BuildContext context) => switch (widget.viewModel.status) {
    StartupStatus.loading => const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(semanticsLabel: '正在開啟本機資料'),
          SizedBox(height: 24),
          Text('正在準備學習空間…'),
        ],
      ),
    ),
    StartupStatus.failed => _message(
      context,
      icon: Icons.error_outline,
      title: '暫時無法開啟',
      description: widget.viewModel.errorMessage,
      action: FilledButton.icon(
        onPressed: widget.viewModel.initialize,
        icon: const Icon(Icons.refresh),
        label: const Text('重試'),
      ),
    ),
    StartupStatus.ready => switch (_selectedIndex) {
      0 => _message(
        context,
        icon: Icons.menu_book_outlined,
        title: '從 N5 開始，一步一步學習',
        description: '從第一課認識簡單的身分與自我介紹。',
        action: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => N5LessonListPage(
                listLessons: widget.listN5Lessons,
                getLesson: widget.getN5Lesson,
                practiceActions: widget.practiceActions,
              ),
            ),
          ),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('N5 課程'),
        ),
      ),
      1 => _message(
        context,
        icon: Icons.history_outlined,
        title: '目前沒有複習項目',
        description: '完成學習後，再回到這裡複習。',
      ),
      _ => _message(
        context,
        icon: Icons.privacy_tip_outlined,
        title: '你的學習空間',
        description: '本機儲存已就緒。\n目前不需要登入，也不會傳送學習資料。',
      ),
    },
  };

  Widget _message(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    Widget? action,
  }) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(description, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 24), action],
          ],
        ),
      ),
    ),
  );
}
