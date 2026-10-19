import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/scene_palette.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';

/// Draws a bar of cells, or a bar cut in groups.
abstract final class BarPainter {
  static void paint(Canvas canvas, Rect cell, SceneBar bar) {
    const double maxCells = 12;
    final double cellHeight = (cell.height - 4) / maxCells;
    final double cellWidth = math.min(cell.width * 0.7, 40);
    final double left = cell.center.dx - cellWidth / 2;
    final bool vertical = bar.groupSize == null;
    if (!vertical) {
      _paintGroupedBar(canvas, cell, bar);
      return;
    }
    for (int index = 0; index < bar.cells; index++) {
      final bool isAccent = bar.accentFrom != null && index >= bar.accentFrom!;
      final Rect rect = Rect.fromLTWH(
        left,
        cell.bottom - cellHeight * (index + 1),
        cellWidth,
        cellHeight - 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = index < bar.filled
              ? (isAccent ? ScenePalette.accent : ScenePalette.bar)
              : ScenePalette.plate,
      );
    }
    if (bar.mark == SceneMark.ring) {
      ScenePalette.paintRing(
        canvas,
        Rect.fromLTRB(
          left,
          cell.bottom - cellHeight * bar.cells,
          left + cellWidth,
          cell.bottom,
        ),
      );
    }
  }

  static void _paintGroupedBar(Canvas canvas, Rect cell, SceneBar bar) {
    final int groupSize = bar.groupSize!;
    final int groups = (bar.cells / groupSize).ceil();
    const double gap = 6;
    final double width = (cell.width - gap * (groups - 1)) / bar.cells;
    final double height = math.min(cell.height * 0.4, 40);
    final double top = cell.center.dy - height / 2;
    for (int index = 0; index < bar.cells; index++) {
      final int group = index ~/ groupSize;
      final double left = cell.left + index * width + group * gap;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, width - 1.5, height),
          const Radius.circular(2),
        ),
        Paint()..color = group.isEven ? ScenePalette.bar : ScenePalette.accent,
      );
    }
  }
}
