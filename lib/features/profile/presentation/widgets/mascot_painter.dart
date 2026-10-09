import 'package:flutter/rendering.dart';

/// Draws the mascot as it appears on "Qui joue ?", traced from the mockup.
///
/// Drawn in a 120 x 120 box scaled to the canvas. The drawing is
/// provisional: the growing mascot of lot F8 replaces it.
final class MascotPainter extends CustomPainter {
  /// Creates a painter with the colors of the mascot.
  const MascotPainter({
    required this.bodyColor,
    required this.feetColor,
    required this.eyeColor,
    required this.inkColor,
    required this.badgeColor,
  });

  static const double _viewBox = 120;
  static const double _strokeWidth = 4;
  static const Rect _body = Rect.fromLTWH(16, 20, 88, 90);
  static const Radius _bodyRadius = Radius.circular(40);

  /// Color of the body and the ears.
  final Color bodyColor;

  /// Color of the feet.
  final Color feetColor;

  /// Color of the white of the eyes.
  final Color eyeColor;

  /// Color of the pupils and the mouth.
  final Color inkColor;

  /// Color of the cross on the belly.
  final Color badgeColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / _viewBox);
    final Paint body = Paint()..color = bodyColor;
    final Paint feet = Paint()..color = feetColor;
    canvas.drawOval(_ellipse(const Offset(42, 110)), feet);
    canvas.drawOval(_ellipse(const Offset(78, 110)), feet);
    canvas.drawCircle(const Offset(32, 24), 10, body);
    canvas.drawCircle(const Offset(88, 24), 10, body);
    canvas.drawRRect(RRect.fromRectAndRadius(_body, _bodyRadius), body);
    _paintFace(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(MascotPainter oldDelegate) {
    return oldDelegate.bodyColor != bodyColor ||
        oldDelegate.feetColor != feetColor ||
        oldDelegate.eyeColor != eyeColor ||
        oldDelegate.inkColor != inkColor ||
        oldDelegate.badgeColor != badgeColor;
  }

  void _paintFace(Canvas canvas) {
    final Paint eye = Paint()..color = eyeColor;
    final Paint pupil = Paint()..color = inkColor;
    canvas.drawCircle(const Offset(45, 56), 11, eye);
    canvas.drawCircle(const Offset(75, 56), 11, eye);
    canvas.drawCircle(const Offset(47, 58), 5, pupil);
    canvas.drawCircle(const Offset(73, 58), 5, pupil);
    final Path mouth = Path()
      ..moveTo(50, 78)
      ..quadraticBezierTo(60, 87, 70, 78);
    canvas.drawPath(mouth, _stroke(inkColor));
    final Path cross = Path()
      ..moveTo(54, 92)
      ..lineTo(66, 102)
      ..moveTo(66, 92)
      ..lineTo(54, 102);
    canvas.drawPath(cross, _stroke(badgeColor));
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
