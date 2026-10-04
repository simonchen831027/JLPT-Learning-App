import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/learning/presentation/reading_line.dart';

void main() {
  final text = ReadingText(
    id: 'reading-test',
    surface: '私は学生です。\n第二行。',
    segments: const [
      ReadingSegment(id: 's1', ordinal: 0, surface: '私', reading: 'わたし'),
      ReadingSegment(id: 's2', ordinal: 1, surface: 'は学生です。\n第二行。'),
    ],
  );
  for (final show in [true, false]) {
    testWidgets(
      'stored reading show=$show preserves selectable surface and explicit newline',
      (tester) async {
        String? selected;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionArea(
                onSelectionChanged: (value) => selected = value?.plainText,
                child: ReadingLine(text, showReadings: show),
              ),
            ),
          ),
        );
        final area = tester.state<SelectionAreaState>(
          find.byType(SelectionArea),
        );
        area.selectableRegion.selectAll();
        await tester.pump();
        expect(selected, text.surface);
        expect(find.text('わたし'), show ? findsOneWidget : findsNothing);
        final semantics = tester.ensureSemantics();
        try {
          expect(find.bySemanticsLabel(text.surface), findsOneWidget);
          expect(find.bySemanticsLabel('わたし'), findsNothing);
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}
