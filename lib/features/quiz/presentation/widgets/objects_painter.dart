import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws [count] mangoes in blocks of ten, two rows of five, side by side:
/// a child sees 7 as five and two, 14 as ten and four. The empty places
/// of a block are faint rings. The mango is a provisional drawing.
class ObjectsPainter extends CustomPainter {
  /// Creates the painter of [count] mangoes; [frameColor] fills the
  /// blocks and [slotColor] rings their empty places.
  ObjectsPainter({
    required this.count,
    required this.frameColor,
    required this.slotColor,
  });

  /// Objects per row of a block.
  static const int perRow = 5;

  /// Objects per block.
  static const int perBlock = 10;

  static const double _cell = 44;
  static const double _padding = 8;
  static const double _blockGap = 20;
  static const double _radius = 16;
  static const Color _body = Color(0xFFFFB020);
  static const Color _blush = Color(0xFFF07A24);
  static const Color _leaf = Color(0xFF2F8F46);

  /// Number of mangoes.
  final int count;

  /// Background of a block.
  final Color frameColor;

  /// Ring of an empty place.
  final Color slotColor;

  int get _blocks => math.max(1, (count + perBlock - 1) ~/ perBlock);

  double get _blockWidth => perRow * _cell + 2 * _padding;

  double get _blockHeight => 2 * _cell + 2 * _padding;

  /// Size of the drawing in design units.
  Size get designSize => Size(
    _blocks * _blockWidth + (_blocks - 1) * _blockGap,
    _blockHeight,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Size design = designSize;
    canvas.save();
    canvas.scale(size.width / design.width, size.height / design.height);
    for (int block = 0; block < _blocks; block++) {
      final double left = block * (_blockWidth + _blockGap);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, 0, _blockWidth, _blockHeight),
          const Radius.circular(_radius),
        ),
        Paint()..color = frameColor,
      );
      for (int place = 0; place < perBlock; place++) {
        final Offset center = Offset(
          left + _padding + (place % perRow + 0.5) * _cell,
          _padding + (place ~/ perRow + 0.5) * _cell,
        );
        if (block * perBlock + place < count) {
          _paintMango(canvas, center);
        } else {
          _paintSlot(canvas, center);
        }
      }
    }
    canvas.restore();
  }

  void _paintSlot(Canvas canvas, Offset center) {
    canvas.drawCircle(
      center,
      _cell * 0.3,
      Paint()
        ..color = slotColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintMango(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.5);
    const Rect body = Rect.fromLTWH(-18, -14, 34, 28);
    canvas.drawOval(body, Paint()..color = _body);
    canvas.drawOval(
      const Rect.fromLTWH(-16, -2, 22, 14),
      Paint()..color = _blush.withValues(alpha: 0.6),
    );
    canvas.drawOval(
      const Rect.fromLTWH(10, -20, 14, 8),
      Paint()..color = _leaf,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ObjectsPainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.frameColor != frameColor ||
        oldDelegate.slotColor != slotColor;
  }
}
