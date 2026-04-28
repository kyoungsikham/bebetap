import 'package:flutter/widgets.dart';

double measureMaxTextWidth({
  required List<String> texts,
  required TextStyle style,
  required TextDirection textDirection,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  if (texts.isEmpty) return 0;
  var maxWidth = 0.0;
  for (final text in texts) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout();
    if (painter.size.width > maxWidth) maxWidth = painter.size.width;
  }
  return maxWidth;
}

double computeAdaptiveCardWidth({
  required List<String> labels,
  required TextStyle style,
  required TextDirection textDirection,
  TextScaler textScaler = TextScaler.noScaling,
  required double baseline,
  double horizontalPadding = 8,
  required double maxCap,
}) {
  final measured = measureMaxTextWidth(
    texts: labels,
    style: style,
    textDirection: textDirection,
    textScaler: textScaler,
  );
  return (measured + horizontalPadding).ceilToDouble().clamp(baseline, maxCap);
}
