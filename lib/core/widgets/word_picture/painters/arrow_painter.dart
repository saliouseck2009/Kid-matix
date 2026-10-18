import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/scene_palette.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';

/// Draws an arrow between two elements.
abstract final class ArrowPainter {
  static void paint(Canvas canvas, Rect cell, SceneDirection direction) {
    final Paint paint = Paint()
      ..color = ScenePalette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Offset c = cell.center;
    final double reach = math.min(cell.width, cell.height) * 0.35;
    final (Offset, Offset) axis = switch (direction) {
      SceneDirection.right => (c - Offset(reach, 0), c + Offset(reach, 0)),
      SceneDirection.up => (c + Offset(0, reach), c - Offset(0, reach)),
      SceneDirection.down => (c - Offset(0, reach), c + Offset(0, reach)),
    };
    final Offset tail = axis.$1;
    final Offset tip = axis.$2;
    final Offset forward = (tip - tail) / (tip - tail).distance;
    final Offset side = Offset(-forward.dy, forward.dx);
    canvas.drawLine(tail, tip, paint);
    canvas.drawLine(tip, tip - forward * 9 + side * 7, paint);
    canvas.drawLine(tip, tip - forward * 9 - side * 7, paint);
  }
}
