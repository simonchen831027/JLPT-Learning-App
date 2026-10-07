import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jlpt_learning_app/features/content/domain/content_models.dart';
import 'package:jlpt_learning_app/features/learning/presentation/reading_line.dart';

ReadingText readingText(List<(String, String?)> parts) => ReadingText(
  id: 'geometry-test',
  surface: parts.map((part) => part.$1).join(),
  segments: [
    for (var i = 0; i < parts.length; i++)
      ReadingSegment(
        id: 'segment-$i',
        ordinal: i,
        surface: parts[i].$1,
        reading: parts[i].$2,
      ),
  ],
);

Finder richLine() => find.byWidgetPredicate(
  (widget) => widget is Text && widget.textSpan != null,
);

RenderParagraph paragraph(WidgetTester tester, Finder text) =>
    tester.renderObject<RenderParagraph>(
      find.descendant(of: text, matching: find.byType(RichText)).first,
    );

Rect glyphs(RenderParagraph paragraph, int start, int end) => paragraph
    .getBoxesForSelection(TextSelection(baseOffset: start, extentOffset: end))
    .map(
      (box) => MatrixUtils.transformRect(
        paragraph.getTransformTo(null),
        box.toRect(),
      ),
    )
    .reduce((a, b) => a.expandToInclude(b));

double baselineDistance(RenderParagraph paragraph) {
  // Baselines are normally queried by a layout parent. The intrinsic-check
  // mode permits inspecting the completed layout without changing its parent.
  final previous = RenderObject.debugCheckingIntrinsics;
  RenderObject.debugCheckingIntrinsics = true;
  try {
    return paragraph.getDistanceToBaseline(TextBaseline.alphabetic)!;
  } finally {
    RenderObject.debugCheckingIntrinsics = previous;
  }
}

double baseline(RenderParagraph paragraph) =>
    paragraph.localToGlobal(Offset(0, baselineDistance(paragraph))).dy;

Future<void> pumpLine(
  WidgetTester tester,
  ReadingText value, {
  double width = 600,
  double scale = 1,
  double fontSize = 24,
  double height = 1.5,
  bool show = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: SelectionArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: ReadingLine(
                  value,
                  showReadings: show,
                  style: TextStyle(fontSize: fontSize, height: height),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void expectCluster(WidgetTester tester, String surface, String reading) {
  final base = paragraph(tester, find.text(surface));
  final ruby = paragraph(tester, find.text(reading));
  final baseRect = glyphs(base, 0, surface.length);
  final rubyRect = glyphs(ruby, 0, reading.length);
  final baseBox = MatrixUtils.transformRect(
    base.getTransformTo(null),
    Offset.zero & base.size,
  );
  final rubyBox = MatrixUtils.transformRect(
    ruby.getTransformTo(null),
    Offset.zero & ruby.size,
  );
  expect(rubyBox.center.dx, closeTo(baseBox.center.dx, 0.01));
  // Glyph boxes include font tracking and engine pixel rounding; the two
  // paragraph boxes must still have exactly the same horizontal center.
  expect(rubyRect.center.dx, closeTo(baseRect.center.dx, 1));
  // Annotation width is deliberately independent of surface advance.
  expect(baseBox.width, greaterThanOrEqualTo(baseRect.width - 0.5));
  expect(rubyBox.width, greaterThanOrEqualTo(rubyRect.width - 0.01));
  expect(rubyBox.bottom, closeTo(baseBox.top, 0.01));
  expect(rubyRect.bottom, lessThanOrEqualTo(baseRect.top));
  expect(base.didExceedMaxLines, isFalse);
  expect(ruby.didExceedMaxLines, isFalse);
}

Future<Map<String, Object>> verifyNaturalInline(
  WidgetTester tester, {
  required double fontSize,
  required double scale,
}) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final value = readingText([('ミオさんは', null), ('学生', 'がくせい'), ('です。', null)]);
  await pumpLine(tester, value, fontSize: fontSize, scale: scale, width: 1200);
  final outer = paragraph(tester, richLine());
  final base = paragraph(tester, find.text('学生'));
  final onBaseline = baseline(outer);
  final baseBaseline = baseline(base);
  final on = [
    for (var i = 0; i < 5; i++) glyphs(outer, i, i + 1),
    for (var i = 0; i < 2; i++) glyphs(base, i, i + 1),
    for (var i = 6; i < 9; i++) glyphs(outer, i, i + 1),
  ];
  final reading = paragraph(tester, find.text('がくせい'));
  final annotation = glyphs(reading, 0, 4);
  expect(annotation.bottom, lessThanOrEqualTo(on[5].top));
  expect(baseBaseline, closeTo(onBaseline, 0.5));
  for (final rect in on.take(9)) {
    expect(rect.bottom, closeTo(on.first.bottom, 0.5));
    expect(rect.height, closeTo(on.first.height, 0.01));
  }
  await pumpLine(
    tester,
    value,
    fontSize: fontSize,
    scale: scale,
    width: 1200,
    show: false,
  );
  final off = paragraph(tester, richLine());
  final reference = TextPainter(
    text: TextSpan(
      text: value.surface,
      style: off.text.style!.copyWith(fontSize: fontSize),
    ),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.linear(scale),
    locale: const Locale('ja'),
  )..layout(maxWidth: 1200);
  final offRects = [
    for (var i = 0; i < value.surface.length; i++) glyphs(off, i, i + 1),
  ];
  // Remove only the whole-line annotation band when comparing vertical layout.
  final lineOffset = on.first.bottom - offRects.first.bottom;
  try {
    for (var i = 0; i < value.surface.length; i++) {
      final plain = reference
          .getBoxesForSelection(
            TextSelection(baseOffset: i, extentOffset: i + 1),
          )
          .single
          .toRect();
      expect(offRects[i].left, closeTo(plain.left, 0.01));
      expect(offRects[i].right, closeTo(plain.right, 0.01));
      // WidgetSpan restarts half-letter-spacing at a run boundary. Allow only
      // a quarter logical pixel, never the extra width of the annotation.
      expect(
        on[i].left,
        closeTo(offRects[i].left, 0.25),
        reason: '${value.surface[i]} left',
      );
      expect(
        on[i].right,
        closeTo(offRects[i].right, 0.25),
        reason: '${value.surface[i]} right',
      );
      expect(
        on[i].bottom - lineOffset,
        closeTo(offRects[i].bottom, 0.5),
        reason: '${value.surface[i]} bottom',
      );
    }
    expect(baseBaseline - lineOffset, closeTo(baseline(off), 0.5));
    expect(
      on[5].left - on[4].right,
      closeTo(offRects[5].left - offRects[4].right, 0.25),
    );
    expect(
      on[7].left - on[6].right,
      closeTo(offRects[7].left - offRects[6].right, 0.25),
    );
    expect(
      on[6].right - on[5].left,
      closeTo(offRects[6].right - offRects[5].left, 0.01),
    );
  } finally {
    reference.dispose();
  }
  List<double> coordinates(Rect rect) => [
    rect.left,
    rect.top,
    rect.right,
    rect.bottom,
  ];
  return {
    'fontSize': fontSize,
    'scale': scale,
    'surface': value.surface,
    'onGlyphs': on.map(coordinates).toList(),
    'offGlyphs': offRects.map(coordinates).toList(),
    'onPlainBaseline': onBaseline,
    'onBaseBaseline': baseBaseline,
    'offBaseline': baseline(off),
    'annotationBandOffset': lineOffset,
    'annotation': coordinates(annotation),
  };
}

void main() {
  for (final fontSize in [16.0, 18.0, 24.0, 32.0]) {
    for (final scale in [1.0, 1.8, 2.5]) {
      testWidgets(
        'developer regression: ON glyphs equal OFF font=$fontSize scale=$scale',
        (tester) async {
          await verifyNaturalInline(tester, fontSize: fontSize, scale: scale);
        },
      );
    }
  }
  final positions = <String, List<(String, String?)>>{
    'start': [('学生', 'がくせい'), ('です。', null)],
    'middle': [('ミオさんは', null), ('学生', 'がくせい'), ('です。', null)],
    'end': [('ミオさんは', null), ('学生', 'がくせい')],
  };
  for (final entry in positions.entries) {
    for (final fontSize in [16.0, 24.0, 32.0]) {
      for (final scale in [1.0, 1.8, 2.5]) {
        testWidgets(
          'ruby ${entry.key} baseline / coverage font=$fontSize scale=$scale',
          (tester) async {
            final value = readingText(entry.value);
            await pumpLine(tester, value, fontSize: fontSize, scale: scale);
            final outer = paragraph(tester, richLine());
            final base = paragraph(tester, find.text('学生'));
            expect(baseline(base), closeTo(baseline(outer), 1));
            // Measure glyphs too: matching baselines alone does not detect
            // WidgetSpan scaling the already-scaled inner Text a second time.
            final plainOffset = entry.key == 'start' ? 1 : 0;
            final plainRect = glyphs(outer, plainOffset, plainOffset + 1);
            final baseRect = glyphs(base, 0, 2);
            expect(baseRect.bottom, closeTo(plainRect.bottom, 1));
            expect(baseRect.height, closeTo(plainRect.height, 1));
            expectCluster(tester, '学生', 'がくせい');
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets(
    'consecutive ruby, multi-kanji and okurigana retain their own anchors',
    (tester) async {
      await pumpLine(
        tester,
        readingText([
          ('日本語', 'にほんご'),
          ('勉強', 'べんきょう'),
          ('を', null),
          ('食', 'た'),
          ('べます。', null),
        ]),
      );
      final outer = paragraph(tester, richLine());
      for (final pair in [('日本語', 'にほんご'), ('勉強', 'べんきょう'), ('食', 'た')]) {
        expectCluster(tester, pair.$1, pair.$2);
        expect(
          baseline(paragraph(tester, find.text(pair.$1))),
          closeTo(baseline(outer), 0.01),
        );
      }
      final first = glyphs(paragraph(tester, find.text('にほんご')), 0, 4);
      final second = glyphs(paragraph(tester, find.text('べんきょう')), 0, 5);
      expect(first.right, lessThanOrEqualTo(second.left + 0.25));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'short reading stays centered over the complete wider base cluster',
    (tester) async {
      await pumpLine(
        tester,
        readingText([('明日', 'あす'), ('です。', null)]),
        fontSize: 32,
      );
      expectCluster(tester, '明日', 'あす');
      final outer = paragraph(tester, richLine());
      final base = paragraph(tester, find.text('明日'));
      expect(baseline(base), closeTo(baseline(outer), 0.01));
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'newline and narrow wrapping keep each ruby intact scale=$scale',
      (tester) async {
        await pumpLine(
          tester,
          readingText([
            ('あいうえお\nあいうえお', null),
            ('学生', 'がくせい'),
            ('です。\n', null),
            ('日本語', 'にほんご'),
            ('を読みます。', null),
          ]),
          width: 150,
          scale: scale,
        );
        final outer = paragraph(tester, richLine());
        final firstLine = glyphs(outer, 0, 1);
        final student = paragraph(tester, find.text('学生'));
        final japanese = paragraph(tester, find.text('日本語'));
        expect(baseline(student), greaterThan(firstLine.bottom));
        expect(baseline(japanese), greaterThan(baseline(student)));
        for (final pair in [('学生', 'がくせい'), ('日本語', 'にほんご')]) {
          expectCluster(tester, pair.$1, pair.$2);
          final ruby = paragraph(tester, find.text(pair.$2));
          final rubyRect = glyphs(ruby, 0, pair.$2.length);
          final outerRect = Offset.zero & outer.size;
          final relativeRect = rubyRect.shift(
            -outer.localToGlobal(Offset.zero),
          );
          final base = paragraph(tester, find.text(pair.$1));
          final overhang =
              (ruby.size.width - base.size.width).clamp(0, double.infinity) / 2;
          expect(
            relativeRect.left,
            greaterThanOrEqualTo(outerRect.left - overhang - 0.5),
          );
          expect(
            relativeRect.right,
            lessThanOrEqualTo(outerRect.right + overhang + 0.5),
          );
          expect(relativeRect.top, greaterThanOrEqualTo(outerRect.top - 0.01));
          expect(
            relativeRect.bottom,
            lessThanOrEqualTo(outerRect.bottom + 0.01),
          );
          final previousGlyphs = [
            for (var i = 0; i < 11; i++)
              if (i != 5) glyphs(outer, i, i + 1),
          ].where((rect) => rect.bottom < rubyRect.bottom);
          for (final previous in previousGlyphs) {
            expect(previous.bottom, lessThanOrEqualTo(rubyRect.top));
          }
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('dry size and baseline agree with live layout', (tester) async {
    await pumpLine(
      tester,
      readingText([('あ', null), ('学生', 'がくせい')]),
      scale: 1.8,
    );
    final outer = paragraph(tester, richLine());
    for (final width in [90.0, 240.0, 600.0]) {
      final constraints = BoxConstraints.tightFor(width: width);
      final drySize = outer.getDryLayout(constraints);
      final dryBaseline = outer.getDryBaseline(
        constraints,
        TextBaseline.alphabetic,
      );
      await pumpLine(
        tester,
        readingText([('あ', null), ('学生', 'がくせい')]),
        scale: 1.8,
        width: width,
      );
      final live = paragraph(tester, richLine());
      expect(live.size.width, closeTo(drySize.width, 0.01));
      expect(live.size.height, closeTo(drySize.height, 0.01));
      expect(baselineDistance(live), closeTo(dryBaseline!, 0.01));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Furigana OFF matches normal text geometry including wrapping and newline',
    (tester) async {
      final value = readingText([
        ('ミオさんは', null),
        ('学生', 'がくせい'),
        ('です。\n', null),
        ('日本語', 'にほんご'),
        ('を勉強します。', null),
      ]);
      await pumpLine(tester, value, width: 160, scale: 1.8, show: false);
      final outer = paragraph(tester, richLine());
      final reference = TextPainter(
        text: TextSpan(text: value.surface, style: outer.text.style),
        textDirection: TextDirection.ltr,
        textScaler: outer.textScaler,
        locale: const Locale('ja'),
      )..layout(maxWidth: 160);
      addTearDown(reference.dispose);
      expect(outer.size.height, closeTo(reference.height, 0.01));
      expect(
        baselineDistance(outer),
        closeTo(
          reference.computeDistanceToActualBaseline(TextBaseline.alphabetic),
          0.01,
        ),
      );
      final actual = outer.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: value.surface.length),
      );
      final expected = reference.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: value.surface.length),
      );
      expect(
        actual.map((box) => box.toRect()),
        expected.map((box) => box.toRect()),
      );
      expect(find.byType(SelectionContainer), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

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
