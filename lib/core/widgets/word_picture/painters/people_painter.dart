import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/scene_palette.dart';

/// Draws a row of people as heads.
abstract final class PeoplePainter {
  static void paint(Canvas canvas, Rect cell, int count) {
    final int columns = math.min(count, 2);
    final int rows = (count / columns).ceil();
    final double slot = math.min(cell.width / columns, cell.height / rows);
    final double radius = math.min(slot * 0.35, 16);
    for (int index = 0; index < count; index++) {
      final Offset center = Offset(
        cell.center.dx + (index % columns - (columns - 1) / 2) * slot,
        cell.center.dy + (index ~/ columns - (rows - 1) / 2) * slot,
      );
      canvas.drawCircle(
        center - Offset(0, radius * 0.4),
        radius * 0.6,
        Paint()
          ..color = ScenePalette.marbles[index % ScenePalette.marbles.length],
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(0, radius * 0.7),
          width: radius * 1.6,
          height: radius,
        ),
        Paint()
          ..color = ScenePalette.marbles[index % ScenePalette.marbles.length],
      );
    }
  }
}
