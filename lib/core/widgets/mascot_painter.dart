import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/widgets/mascot_accessory_painter.dart';

/// Colors of the mascot, taken from the theme.
typedef MascotColors = ({
  Color body,
  Color feet,
  Color eye,
  Color ink,
  Color badge,
  Color cheek,
});

/// Draws the mascot at its [stage], with its [mood] and its
/// [accessories]: it starts small and bare, then gets ears, arms, cheeks
/// and a star as it grows.
///
/// Drawn in a 120 x 120 box scaled to the canvas. The drawing is
/// provisional: final illustrations replace it without touching the
/// callers.
final class MascotPainter extends CustomPainter {
  /// Creates the painter.
  const MascotPainter({
    required this.colors,
    this.stage = 1,
    this.mood = MascotMood.neutral,
    this.accessories = const <MascotAccessory>{},
  });

  static const double _viewBox = 120;
  static const double _strokeWidth = 4;
  static const Rect _body = Rect.fromLTWH(16, 20, 88, 90);
  static const Radius _bodyRadius = Radius.circular(40);
  static const double _smallestScale = 0.72;
  static const double _growthPerStage = 0.07;

  /// Colors from the theme.
  final MascotColors colors;

  /// Stage, from 1 to 5.
  final int stage;

  /// Face it makes.
  final MascotMood mood;

  /// Accessories worn.
  final Set<MascotAccessory> accessories;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / _viewBox);
    final double scale = _smallestScale + _growthPerStage * (stage - 1);
    canvas.translate(_viewBox / 2 * (1 - scale), _viewBox * (1 - scale));
    canvas.scale(scale);
    final MascotAccessoryPainter accessoryPainter = MascotAccessoryPainter(
      accessories: accessories,
    );
    accessoryPainter.paintBehind(canvas);
    _paintBody(canvas);
    _paintFace(canvas);
    accessoryPainter.paintInFront(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(MascotPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.stage != stage ||
        oldDelegate.mood != mood ||
        !setEquals(oldDelegate.accessories, accessories);
  }

  void _paintBody(Canvas canvas) {
    final Paint body = Paint()..color = colors.body;
    final Paint feet = Paint()..color = colors.feet;
    canvas.drawOval(_ellipse(const Offset(42, 110)), feet);
    canvas.drawOval(_ellipse(const Offset(78, 110)), feet);
    if (stage >= 2) {
      canvas.drawCircle(const Offset(32, 24), 10, body);
      canvas.drawCircle(const Offset(88, 24), 10, body);
    }
    if (stage >= 3) {
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(14, 72), width: 14, height: 26),
        body,
      );
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(106, 72), width: 14, height: 26),
        body,
      );
    }
    canvas.drawRRect(RRect.fromRectAndRadius(_body, _bodyRadius), body);
    if (stage >= 4) {
      final Paint cheek = Paint()..color = colors.cheek;
      canvas.drawCircle(const Offset(32, 72), 6, cheek);
      canvas.drawCircle(const Offset(88, 72), 6, cheek);
    }
    if (stage >= 5) _paintStar(canvas);
  }

  void _paintFace(Canvas canvas) {
    final Paint eye = Paint()..color = colors.eye;
    final Paint pupil = Paint()..color = colors.ink;
    if (mood == MascotMood.happy) {
      for (final double x in <double>[45, 75]) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 9, 60)
            ..quadraticBezierTo(x, 46, x + 9, 60),
          _stroke(colors.ink),
        );
      }
    } else {
      canvas.drawCircle(const Offset(45, 56), 11, eye);
      canvas.drawCircle(const Offset(75, 56), 11, eye);
      canvas.drawCircle(const Offset(47, 58), 5, pupil);
      canvas.drawCircle(const Offset(73, 58), 5, pupil);
    }
    if (mood == MascotMood.encouraging) {
      canvas.drawPath(
        Path()
          ..moveTo(36, 40)
          ..lineTo(52, 38)
          ..moveTo(68, 38)
          ..lineTo(84, 40),
        _stroke(colors.ink),
      );
    }
    final Path mouth = Path()..moveTo(50, 78);
    switch (mood) {
      case MascotMood.happy:
        mouth
          ..quadraticBezierTo(60, 94, 70, 78)
          ..close();
        canvas.drawPath(mouth, Paint()..color = colors.ink);
      case MascotMood.neutral || MascotMood.encouraging:
        mouth.quadraticBezierTo(60, 87, 70, 78);
        canvas.drawPath(mouth, _stroke(colors.ink));
    }
    final Path cross = Path()
      ..moveTo(54, 92)
      ..lineTo(66, 102)
      ..moveTo(66, 92)
      ..lineTo(54, 102);
    canvas.drawPath(cross, _stroke(colors.badge));
  }

  void _paintStar(Canvas canvas) {
    final Path star = Path();
    for (int index = 0; index < 10; index++) {
      final double radius = index.isEven ? 9 : 4;
      final double angle = -pi / 2 + index * pi / 5;
      final Offset point = Offset(
        104 + radius * cos(angle),
        10 + radius * sin(angle),
      );
      index == 0
          ? star.moveTo(point.dx, point.dy)
          : star.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(star..close(), Paint()..color = colors.badge);
  }

  static Rect _ellipse(Offset center) {
    return Rect.fromCenter(center: center, width: 24, height: 12);
  }

  static Paint _stroke(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
  }
}
