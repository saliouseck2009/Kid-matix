import 'package:flutter/material.dart';

/// Draws one of the 12 monsters, provisional variants of the one-eyed
/// boss of the design: the body color, the horns and the eyes change with
/// [number]. Final illustrations replace this painter without touching
/// the callers.
class MonsterPainter extends CustomPainter {
  /// Creates the painter of the monster [number], from 1.
  MonsterPainter({required this.number});

  /// Width of the drawing in design units; its height is [_height].
  static const double _width = 200;
  static const double _height = 170;

  static const List<Color> _bodies = <Color>[
    Color(0xFF8E78FF),
    Color(0xFFFF8A75),
    Color(0xFF7FD3A8),
    Color(0xFF6FB7FF),
    Color(0xFFF27BC0),
    Color(0xFFFFB347),
  ];
  static const Color _horn = Color(0xFFFFC531);
  static const Color _ink = Color(0xFF221A4D);
  static const Color _white = Color(0xFFFFFFFF);

  /// Ratio of the drawing, width over height.
  static const double aspectRatio = _width / _height;

  /// Number of the monster, from 1; one per table.
  final int number;

  Color get _body => _bodies[(number - 1) % _bodies.length];

  bool get _hasTwoEyes => number > _bodies.length;

  bool get _hasPointedHorns => number.isOdd;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _width, size.height / _height);
    _paintHorns(canvas);
    _paintArms(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 28, 140, 132),
        const Radius.circular(60),
      ),
      Paint()..color = _body,
    );
    _paintEyes(canvas);
    _paintMouth(canvas);
    canvas.restore();
  }

  void _paintHorns(Canvas canvas) {
    final Paint paint = Paint()..color = _horn;
    if (_hasPointedHorns) {
      canvas.drawPath(
        Path()
          ..moveTo(52, 40)
          ..lineTo(38, 10)
          ..lineTo(72, 26)
          ..close(),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(148, 40)
          ..lineTo(162, 10)
          ..lineTo(128, 26)
          ..close(),
        paint,
      );
      return;
    }
    canvas.drawCircle(const Offset(52, 30), 16, paint);
    canvas.drawCircle(const Offset(148, 30), 16, paint);
  }

  void _paintArms(Canvas canvas) {
    final Paint paint = Paint()
      ..color = _body
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(32, 100)
        ..quadraticBezierTo(8, 104, 12, 130),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(168, 100)
        ..quadraticBezierTo(192, 104, 188, 130),
      paint,
    );
  }

  void _paintEyes(Canvas canvas) {
    final Paint white = Paint()..color = _white;
    final Paint ink = Paint()..color = _ink;
    if (_hasTwoEyes) {
      for (final double x in <double>[74, 126]) {
        canvas.drawCircle(Offset(x, 80), 20, white);
        canvas.drawCircle(Offset(x + 3, 84), 9, ink);
      }
    } else {
      canvas.drawCircle(const Offset(100, 78), 30, white);
      canvas.drawCircle(const Offset(104, 83), 13, ink);
    }
    canvas.drawPath(
      Path()
        ..moveTo(64, 46)
        ..quadraticBezierTo(100, 32, 136, 46),
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintMouth(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(64, 120, 72, 24),
        const Radius.circular(10),
      ),
      Paint()..color = _ink,
    );
    final Paint white = Paint()..color = _white;
    for (final double x in <double>[72, 89, 106]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 120)
          ..lineTo(x + 7, 131)
          ..lineTo(x + 14, 120)
          ..close(),
        white,
      );
    }
  }

  @override
  bool shouldRepaint(MonsterPainter oldDelegate) {
    return oldDelegate.number != number;
  }
}

/// The monster [number], [width] wide; decorative.
class MonsterIllustration extends StatelessWidget {
  /// Creates the illustration.
  const MonsterIllustration({
    required this.number,
    required this.width,
    super.key,
  });

  /// Number of the monster, from 1; one per table.
  final int number;

  /// Width of the drawing.
  final double width;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, width / MonsterPainter.aspectRatio),
        painter: MonsterPainter(number: number),
      ),
    );
  }
}
