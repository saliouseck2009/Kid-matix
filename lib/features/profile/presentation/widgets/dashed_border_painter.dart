import 'dart:ui';

import 'package:flutter/rendering.dart';

/// Paints a dashed outline along a rounded rectangle filling the canvas.
final class DashedBorderPainter extends CustomPainter {
  /// Creates a dashed outline in [color], [strokeWidth] thick.
  const DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  static const double _dashLength = 9;
  static const double _gapLength = 6;

  /// Color of the dashes.
  final Color color;

  /// Thickness of the dashes.
  final double strokeWidth;

  /// Corner radius of the outline.
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = (Offset.zero & size).deflate(strokeWidth / 2);
    final Path outline = Path()
      ..addRRect(RRect.fromRectAndRadius(bounds, Radius.circular(radius)));
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    for (final PathMetric metric in outline.computeMetrics()) {
      for (
        double start = 0;
        start < metric.length;
        start += _dashLength + _gapLength
      ) {
        canvas.drawPath(metric.extractPath(start, start + _dashLength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
