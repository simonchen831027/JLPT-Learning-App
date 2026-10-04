import 'package:flutter/material.dart';

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
    final textStyle = style ?? Theme.of(context).textTheme.bodyLarge;
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
                  alignment: PlaceholderAlignment.bottom,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SelectionContainer.disabled(
                        child: Text(
                          segment.reading!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: (textStyle?.fontSize ?? 0) >= 24
                                    ? 13
                                    : 12,
                                height: 1.25,
                              ),
                          locale: const Locale('ja'),
                        ),
                      ),
                      Text(
                        segment.surface,
                        style: textStyle,
                        locale: const Locale('ja'),
                      ),
                    ],
                  ),
                ),
          ],
        ),
        style: textStyle,
        locale: const Locale('ja'),
      ),
    );
  }
}
