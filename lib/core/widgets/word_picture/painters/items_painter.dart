import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/painters/scene_palette.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';

/// Draws a pile of items, in its container.
abstract final class ItemsPainter {
  static const double _padding = 6;

  static void paint(Canvas canvas, Rect cell, SceneItems pile) {
    final bool isFaded = pile.mark == SceneMark.faded;
    canvas.saveLayer(
      cell.inflate(_padding),
      Paint()..color = Colors.white.withValues(alpha: isFaded ? 0.4 : 1),
    );
    final Rect itemsArea = _paintContainer(canvas, cell, pile.container);
    if (pile.count > 0) {
      _paintGrid(canvas, itemsArea, pile);
    }
    canvas.restore();
    if (pile.mark == SceneMark.ring) ScenePalette.paintRing(canvas, cell);
  }

  /// Draws the container and returns the room left for the items.
  static Rect _paintContainer(
    Canvas canvas,
    Rect cell,
    SceneContainer container,
  ) {
    final Paint fill = Paint()..color = ScenePalette.wood;
    final Paint line = Paint()
      ..color = ScenePalette.wood
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final Rect body = Rect.fromLTRB(
      cell.left,
      cell.center.dy + cell.height * 0.1,
      cell.right,
      cell.bottom,
    );
    switch (container) {
      case SceneContainer.none:
        return cell;
      case SceneContainer.basket:
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            body,
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          fill,
        );
        canvas.drawArc(
          Rect.fromLTRB(
            cell.left + 4,
            cell.top,
            cell.right - 4,
            cell.center.dy + 10,
          ),
          math.pi,
          math.pi,
          false,
          line,
        );
        return Rect.fromLTRB(
          cell.left + 6,
          cell.top + cell.height * 0.2,
          cell.right - 6,
          cell.bottom - 8,
        );
      case SceneContainer.plate:
        canvas.drawOval(
          Rect.fromLTRB(
            cell.left,
            cell.bottom - cell.height * 0.3,
            cell.right,
            cell.bottom,
          ),
          Paint()..color = ScenePalette.plate,
        );
        return Rect.fromLTRB(
          cell.left + 4,
          cell.top,
          cell.right - 4,
          cell.bottom - cell.height * 0.1,
        );
      case SceneContainer.box:
        canvas.drawRRect(
          RRect.fromRectAndRadius(body, const Radius.circular(6)),
          line,
        );
        return body.deflate(6);
      case SceneContainer.bag:
        canvas.drawOval(body.deflate(1), fill);
        canvas.drawLine(
          Offset(cell.center.dx, body.top - 2),
          Offset(cell.center.dx, body.top + 8),
          line,
        );
        return body.deflate(10);
      case SceneContainer.jar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(cell.left + 4, cell.top, cell.right - 4, cell.bottom),
            const Radius.circular(10),
          ),
          Paint()
            ..color = ScenePalette.bar.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        return Rect.fromLTRB(
          cell.left + 10,
          cell.top + cell.height * 0.3,
          cell.right - 10,
          cell.bottom - 6,
        );
      case SceneContainer.tag:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              cell.left,
              cell.center.dy - cell.height * 0.3,
              cell.right,
              cell.center.dy + cell.height * 0.4,
            ),
            const Radius.circular(8),
          ),
          Paint()..color = ScenePalette.plate,
        );
        canvas.drawCircle(
          Offset(cell.left + 10, cell.center.dy - cell.height * 0.3 + 10),
          3,
          Paint()..color = ScenePalette.ink,
        );
        return Rect.fromLTRB(
          cell.left + 14,
          cell.center.dy - cell.height * 0.2,
          cell.right - 6,
          cell.center.dy + cell.height * 0.3,
        );
    }
  }

  static void _paintGrid(Canvas canvas, Rect area, SceneItems pile) {
    final int columns = math.min(
      pile.count,
      math.max(1, math.sqrt(pile.count * area.width / area.height).ceil()),
    );
    final int rows = (pile.count / columns).ceil();
    final double slot = math.min(area.width / columns, area.height / rows);
    final double radius = math.min(slot / 2 * 0.85, 14);
    final double gridWidth = slot * columns;
    final double gridHeight = slot * rows;
    final Offset origin = Offset(
      area.center.dx - gridWidth / 2,
      area.center.dy - gridHeight / 2,
    );
    for (int index = 0; index < pile.count; index++) {
      final Offset center =
          origin +
          Offset(
            slot * (index % columns + 0.5),
            slot * (index ~/ columns + 0.5),
          );
      _paintItem(canvas, center, radius, pile, index);
    }
  }

  static void _paintItem(
    Canvas canvas,
    Offset center,
    double radius,
    SceneItems pile,
    int index,
  ) {
    switch (pile.item) {
      case SceneItem.mango:
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: radius * 2,
            height: radius * 1.7,
          ),
          Paint()..color = ScenePalette.mango,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: center + Offset(radius * 0.3, -radius * 0.9),
            width: radius * 0.8,
            height: radius * 0.4,
          ),
          Paint()..color = ScenePalette.leaf,
        );
      case SceneItem.marble:
        final int tone = pile.tone < 0 ? index : pile.tone;
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = ScenePalette.marbles[tone % ScenePalette.marbles.length],
        );
        canvas.drawCircle(
          center + Offset(-radius * 0.3, -radius * 0.3),
          radius * 0.25,
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
      case SceneItem.coin:
        canvas.drawCircle(center, radius, Paint()..color = ScenePalette.coin);
        canvas.drawCircle(
          center,
          radius * 0.65,
          Paint()
            ..color = ScenePalette.coinEdge
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      case SceneItem.biscuit:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: radius * 1.8,
              height: radius * 1.8,
            ),
            Radius.circular(radius * 0.3),
          ),
          Paint()..color = ScenePalette.biscuit,
        );
      case SceneItem.chair:
        final Paint wood = Paint()..color = ScenePalette.wood;
        canvas.drawRect(
          Rect.fromCenter(
            center: center + Offset(0, radius * 0.3),
            width: radius * 1.4,
            height: radius * 0.5,
          ),
          wood,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            center.dx - radius * 0.7,
            center.dy - radius * 0.9,
            radius * 0.3,
            radius * 1.2,
          ),
          wood,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            center.dx - radius * 0.6,
            center.dy + radius * 0.5,
            radius * 0.25,
            radius * 0.5,
          ),
          wood,
        );
    }
  }
}
