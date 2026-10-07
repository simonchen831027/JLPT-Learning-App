import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../content/domain/content_models.dart';

/// Displays stored contextual readings; never derives readings from surfaces.
class ReadingLine extends StatelessWidget {
  const ReadingLine(
    this.value, {
    this.showReadings = true,
    this.style,
    super.key,
  });
  final ReadingText value;
  final bool showReadings;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style
        .merge(style ?? Theme.of(context).textTheme.bodyLarge);
    final scaler = MediaQuery.textScalerOf(context);
    // Resolve font scaling before creating the inline widget. This keeps the
    // surface's tracking and font metrics identical to surrounding plain text;
    // WidgetSpan must not scale an already-shaped paragraph (including tracking).
    final textStyle = baseStyle.copyWith(
      fontSize: scaler.scale(baseStyle.fontSize ?? 14),
    );
    final readingStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: scaler.scale((baseStyle.fontSize ?? 0) >= 24 ? 13 : 12),
      height: 1.25,
    );
    return Semantics(
      label: value.surface,
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            for (final segment in value.segments)
              if (!showReadings || segment.reading == null)
                TextSpan(text: segment.surface)
              else
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: _RubyCluster(
                    children: [
                      SelectionContainer.disabled(
                        child: Text(
                          segment.reading!,
                          style: readingStyle,
                          locale: const Locale('ja'),
                          textAlign: TextAlign.center,
                          textScaler: TextScaler.noScaling,
                        ),
                      ),
                      Text(
                        segment.surface,
                        style: textStyle,
                        locale: const Locale('ja'),
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.noScaling,
                      ),
                    ],
                  ),
                ),
          ],
        ),
        style: textStyle,
        textScaler: TextScaler.noScaling,
        locale: const Locale('ja'),
      ),
    );
  }
}

/// Only the surface contributes inline advance. The annotation may overhang
/// that advance, and its full height is reserved above the surface baseline.
class _RubyCluster extends MultiChildRenderObjectWidget {
  const _RubyCluster({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderRubyCluster();
}

class _RubyParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderRubyCluster extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  RenderBox get _reading => firstChild!;
  RenderBox get _surface => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>) {
      child.parentData = _RubyParentData();
    }
  }

  BoxConstraints _paragraphConstraints(BoxConstraints constraints) =>
      BoxConstraints.tightFor(
        width: constraints.constrainWidth(
          computeMaxIntrinsicWidth(double.infinity),
        ),
      );

  @override
  double computeMinIntrinsicWidth(double height) =>
      computeMaxIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _surface.getMaxIntrinsicWidth(double.infinity);
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeDryLayout(BoxConstraints(maxWidth: width)).height;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childConstraints = _paragraphConstraints(constraints);
    final readingSize = _reading.getDryLayout(const BoxConstraints());
    final surfaceSize = _surface.getDryLayout(childConstraints);
    return constraints.constrain(
      Size(childConstraints.maxWidth, readingSize.height + surfaceSize.height),
    );
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final childConstraints = _paragraphConstraints(constraints);
    final surfaceBaseline = _surface.getDryBaseline(childConstraints, baseline);
    return surfaceBaseline == null
        ? null
        : _reading.getDryLayout(const BoxConstraints()).height +
              surfaceBaseline;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final surfaceBaseline = _surface.getDistanceToActualBaseline(baseline);
    return surfaceBaseline == null
        ? null
        : _reading.size.height + surfaceBaseline;
  }

  @override
  void performLayout() {
    final childConstraints = _paragraphConstraints(constraints);
    _reading.layout(const BoxConstraints(), parentUsesSize: true);
    _surface.layout(childConstraints, parentUsesSize: true);
    (_reading.parentData! as ContainerBoxParentData<RenderBox>).offset = Offset(
      (_surface.size.width - _reading.size.width) / 2,
      0,
    );
    (_surface.parentData! as ContainerBoxParentData<RenderBox>).offset = Offset(
      0,
      _reading.size.height,
    );
    size = constraints.constrain(
      Size(
        childConstraints.maxWidth,
        _reading.size.height + _surface.size.height,
      ),
    );
  }

  @override
  Rect get paintBounds => (Offset.zero & size).expandToInclude(
    (_reading.parentData! as ContainerBoxParentData<RenderBox>).offset &
        _reading.size,
  );

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
