import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/scene_palette.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';

/// Draws a round shape cut in equal parts.
abstract final class PiePainter {
  static void paint(Canvas canvas, Rect cell, ScenePie pie) {
    final double radius = math.min(cell.width, cell.height) / 2 * 0.9;
    final Rect circle = Rect.fromCircle(center: cell.center, radius: radius);
    final double sweep = 2 * math.pi / pie.parts;
    for (int index = 0; index < pie.parts; index++) {
      canvas.drawArc(
        circle,
        -math.pi / 2 + sweep * index,
        sweep,
        true,
        Paint()
          ..color = index < pie.shown
              ? (index.isEven ? ScenePalette.bar : ScenePalette.accent)
              : ScenePalette.plate,
      );
    }
    final Paint cut = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (int index = 0; index < pie.parts; index++) {
      final double angle = -math.pi / 2 + sweep * index;
      canvas.drawLine(
        cell.center,
        cell.center + Offset(math.cos(angle), math.sin(angle)) * radius,
        cut,
      );
    }
  }
}
