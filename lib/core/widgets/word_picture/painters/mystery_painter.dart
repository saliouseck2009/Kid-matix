import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/scene_palette.dart';

/// Draws the question mark in its bubble.
abstract final class MysteryPainter {
  static void paint(Canvas canvas, Rect cell) {
    final double radius = math.min(cell.width, cell.height) * 0.38;
    canvas.drawCircle(cell.center, radius, Paint()..color = ScenePalette.plate);
    final TextPainter mark = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: ScenePalette.ink,
          fontSize: radius * 1.5,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    mark.paint(
      canvas,
      cell.center - Offset(mark.width / 2, mark.height / 2),
    );
  }
}
