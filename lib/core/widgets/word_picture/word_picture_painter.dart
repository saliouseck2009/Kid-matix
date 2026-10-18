import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/widgets/word_picture/word_scene.dart';

/// Draws a scene of simple shapes: the provisional drawing of a math
/// word. It keeps the proportions of its design size.
class WordPicturePainter extends CustomPainter {
  /// Creates the painter of [scene].
  WordPicturePainter({required this.scene});

  /// Width of the drawing in design units.
  static const double designWidth = 240;

  /// Height of the drawing in design units.
  static const double designHeight = 140;

  /// Ratio of the drawing, width over height.
  static const double aspectRatio = designWidth / designHeight;

  static const double _padding = 6;
  static const Color _ink = Color(0xFF221A4D);
  static const Color _accent = Color(0xFFF27BC0);
  static const Color _mango = Color(0xFFFF9F43);
  static const Color _leaf = Color(0xFF4CAF50);
  static const Color _coin = Color(0xFFFFC531);
  static const Color _coinEdge = Color(0xFFE0A100);
  static const Color _biscuit = Color(0xFFE6B87A);
  static const Color _wood = Color(0xFFB7794A);
  static const Color _plate = Color(0xFFE9E4FF);
  static const List<Color> _marbles = <Color>[
    Color(0xFF6FB7FF),
    Color(0xFFFF8A75),
    Color(0xFF7FD3A8),
  ];
  static const Color _bar = Color(0xFF8E78FF);

  /// The row of elements drawn.
  final List<SceneElement> scene;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / designWidth, size.height / designHeight);
    final double totalWeight = scene.fold(
      0,
      (double sum, SceneElement element) => sum + element.weight,
    );
    double left = 0;
    for (final SceneElement element in scene) {
      final double width = designWidth * element.weight / totalWeight;
      final Rect cell = Rect.fromLTWH(
        left,
        0,
        width,
        designHeight,
      ).deflate(_padding);
      _paintElement(canvas, cell, element);
      left += width;
    }
    canvas.restore();
  }

  void _paintElement(Canvas canvas, Rect cell, SceneElement element) {
    switch (element) {
      case SceneItems():
        _paintItems(canvas, cell, element);
      case SceneArrow():
        _paintArrow(canvas, cell, element.direction);
      case SceneBar():
        _paintBar(canvas, cell, element);
      case ScenePie():
        _paintPie(canvas, cell, element);
      case ScenePeople():
        _paintPeople(canvas, cell, element.count);
      case SceneMystery():
        _paintMystery(canvas, cell);
      case SceneSteps():
        _paintSteps(canvas, cell, element);
    }
  }

  // Items.

  void _paintItems(Canvas canvas, Rect cell, SceneItems pile) {
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
    if (pile.mark == SceneMark.ring) _paintRing(canvas, cell);
  }

  /// Draws the container and returns the room left for the items.
  Rect _paintContainer(Canvas canvas, Rect cell, SceneContainer container) {
    final Paint fill = Paint()..color = _wood;
    final Paint line = Paint()
      ..color = _wood
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
          Paint()..color = _plate,
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
            ..color = _bar.withValues(alpha: 0.5)
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
          Paint()..color = _plate,
        );
        canvas.drawCircle(
          Offset(cell.left + 10, cell.center.dy - cell.height * 0.3 + 10),
          3,
          Paint()..color = _ink,
        );
        return Rect.fromLTRB(
          cell.left + 14,
          cell.center.dy - cell.height * 0.2,
          cell.right - 6,
          cell.center.dy + cell.height * 0.3,
        );
    }
  }

  void _paintGrid(Canvas canvas, Rect area, SceneItems pile) {
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

  void _paintItem(
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
          Paint()..color = _mango,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: center + Offset(radius * 0.3, -radius * 0.9),
            width: radius * 0.8,
            height: radius * 0.4,
          ),
          Paint()..color = _leaf,
        );
      case SceneItem.marble:
        final int tone = pile.tone < 0 ? index : pile.tone;
        canvas.drawCircle(
          center,
          radius,
          Paint()..color = _marbles[tone % _marbles.length],
        );
        canvas.drawCircle(
          center + Offset(-radius * 0.3, -radius * 0.3),
          radius * 0.25,
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
      case SceneItem.coin:
        canvas.drawCircle(center, radius, Paint()..color = _coin);
        canvas.drawCircle(
          center,
          radius * 0.65,
          Paint()
            ..color = _coinEdge
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
          Paint()..color = _biscuit,
        );
      case SceneItem.chair:
        final Paint wood = Paint()..color = _wood;
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

  void _paintRing(Canvas canvas, Rect cell) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(cell.inflate(3), const Radius.circular(14)),
      Paint()
        ..color = _accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  // Other elements.

  void _paintArrow(Canvas canvas, Rect cell, SceneDirection direction) {
    final Paint paint = Paint()
      ..color = _ink
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

  void _paintBar(Canvas canvas, Rect cell, SceneBar bar) {
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
          ..color = index < bar.filled ? (isAccent ? _accent : _bar) : _plate,
      );
    }
    if (bar.mark == SceneMark.ring) {
      _paintRing(
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

  void _paintGroupedBar(Canvas canvas, Rect cell, SceneBar bar) {
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
        Paint()..color = group.isEven ? _bar : _accent,
      );
    }
  }

  void _paintPie(Canvas canvas, Rect cell, ScenePie pie) {
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
              ? (index.isEven ? _bar : _accent)
              : _plate,
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

  void _paintPeople(Canvas canvas, Rect cell, int count) {
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
        Paint()..color = _marbles[index % _marbles.length],
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(0, radius * 0.7),
          width: radius * 1.6,
          height: radius,
        ),
        Paint()..color = _marbles[index % _marbles.length],
      );
    }
  }

  void _paintMystery(Canvas canvas, Rect cell) {
    final double radius = math.min(cell.width, cell.height) * 0.38;
    canvas.drawCircle(cell.center, radius, Paint()..color = _plate);
    final TextPainter mark = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: _ink,
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

  void _paintSteps(Canvas canvas, Rect cell, SceneSteps steps) {
    final double slot = cell.width / steps.total;
    final double y = cell.center.dy;
    canvas.drawLine(
      Offset(cell.left + slot / 2, y),
      Offset(cell.right - slot / 2, y),
      Paint()
        ..color = _ink
        ..strokeWidth = 3,
    );
    for (int index = 0; index < steps.total; index++) {
      final bool isCurrent = index == steps.current;
      canvas.drawCircle(
        Offset(cell.left + slot * (index + 0.5), y),
        isCurrent ? 16 : 9,
        Paint()..color = isCurrent ? _accent : _bar,
      );
    }
  }

  @override
  bool shouldRepaint(WordPicturePainter oldDelegate) {
    return !identical(oldDelegate.scene, scene);
  }
}
