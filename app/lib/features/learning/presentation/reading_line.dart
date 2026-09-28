import 'package:flutter/material.dart';

import '../../content/domain/content_models.dart';

/// Displays stored contextual readings; never derives readings from surfaces.
class ReadingLine extends StatelessWidget {
  const ReadingLine(this.value, {super.key});
  final ReadingText value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final segment in value.segments)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                segment.reading ?? '',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(segment.surface, style: style),
            ],
          ),
      ],
    );
  }
}
