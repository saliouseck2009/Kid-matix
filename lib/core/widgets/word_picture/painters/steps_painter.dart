import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/scene_palette.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';

/// Draws the steps of a story.
abstract final class StepsPainter {
  static void paint(Canvas canvas, Rect cell, SceneSteps steps) {
    final double slot = cell.width / steps.total;
    final double y = cell.center.dy;
    canvas.drawLine(
      Offset(cell.left + slot / 2, y),
      Offset(cell.right - slot / 2, y),
      Paint()
        ..color = ScenePalette.ink
        ..strokeWidth = 3,
    );
    for (int index = 0; index < steps.total; index++) {
      final bool isCurrent = index == steps.current;
      canvas.drawCircle(
        Offset(cell.left + slot * (index + 0.5), y),
        isCurrent ? 16 : 9,
        Paint()..color = isCurrent ? ScenePalette.accent : ScenePalette.bar,
      );
    }
  }
}
