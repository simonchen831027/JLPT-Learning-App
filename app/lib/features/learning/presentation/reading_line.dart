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
    return Text.rich(
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
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    Text(segment.surface, style: textStyle),
                  ],
                ),
              ),
        ],
      ),
      style: textStyle,
    );
  }
}
