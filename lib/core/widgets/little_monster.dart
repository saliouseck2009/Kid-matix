import 'package:flutter/material.dart';

/// Draws a little one-eyed monster of « Mes monstres »: a rounded body,
/// two little horns and one eye, frowning while wild, smiling once tamed.
///
/// Drawn on the 64-unit grid of mockup 14; its body takes one of
/// [bodyColors].
class LittleMonsterPainter extends CustomPainter {
  /// Creates the painter of a monster of [body] color.
  LittleMonsterPainter({required this.body, required this.isTamed});

  /// Side of the drawing in design units.
  static const double _side = 64;

  static const Color _ink = Color(0xFF221A4D);
  static const Color _white = Color(0xFFFFFFFF);
  static const double _stroke = 4;

  /// Body colors of the monsters, from mockup 14.
  static const List<Color> bodyColors = <Color>[
    Color(0xFF8E78FF),
    Color(0xFFFF8A75),
    Color(0xFFFFC531),
    Color(0xFF7FD3A8),
    Color(0xFFA99BF0),
    Color(0xFF6FB7FF),
    Color(0xFFF27BC0),
  ];

  /// Color of the body.
  final Color body;

  /// Whether the monster is tamed: it smiles instead of frowning.
  final bool isTamed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _side, size.height / _side);
    canvas.drawPath(
      Path()
        ..moveTo(14, 16)
        ..lineTo(10, 6)
        ..lineTo(22, 12)
        ..close()
        ..moveTo(50, 16)
        ..lineTo(54, 6)
        ..lineTo(42, 12)
        ..close(),
      Paint()..color = _ink,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 10, 48, 48),
        const Radius.circular(22),
      ),
      Paint()..color = body,
    );
    canvas.drawCircle(const Offset(32, 30), 10, Paint()..color = _white);
    canvas.drawCircle(
      isTamed ? const Offset(32, 31) : const Offset(33, 32),
      4.5,
      Paint()..color = _ink,
    );
    _paintFace(canvas);
    canvas.restore();
  }

  void _paintFace(Canvas canvas) {
    final Paint line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    if (isTamed) {
      canvas.drawPath(
        Path()
          ..moveTo(23, 45)
          ..quadraticBezierTo(32, 53, 41, 45),
        line,
      );
      return;
    }
    canvas.drawLine(const Offset(22, 22), const Offset(42, 18), line);
    canvas.drawPath(
      Path()
        ..moveTo(22, 48)
        ..quadraticBezierTo(32, 44, 42, 48),
      line,
    );
  }

  @override
  bool shouldRepaint(LittleMonsterPainter oldDelegate) {
    return oldDelegate.body != body || oldDelegate.isTamed != isTamed;
  }
}

/// A little monster [size] wide; decorative, the caller names its fact.
class LittleMonster extends StatelessWidget {
  /// Creates the monster drawn in the color of [variant].
  const LittleMonster({
    required this.variant,
    required this.size,
    this.isTamed = false,
    super.key,
  });

  /// Picks the body color, any integer; [variantOf] gives a stable one per
  /// fact.
  final int variant;

  /// Side of the drawing.
  final double size;

  /// Whether the monster is tamed.
  final bool isTamed;

  /// A variant that stays the same for [key] from one launch to the next.
  static int variantOf(String key) {
    return key.codeUnits.fold(
      0,
      (int hash, int unit) => (hash * 31 + unit) & 0x3fffffff,
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<Color> colors = LittleMonsterPainter.bodyColors;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: LittleMonsterPainter(
          body: colors[variant % colors.length],
          isTamed: isTamed,
        ),
      ),
    );
  }
}
