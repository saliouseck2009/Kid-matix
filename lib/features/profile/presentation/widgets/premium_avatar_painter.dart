import 'package:flutter/rendering.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';

/// Draws one of the avatars of the shop, in its own colors.
///
/// Like the free avatars, each one is a face drawn in a 64 x 64 box
/// scaled to the canvas, with its own shape on top. The drawings are
/// provisional; final illustrations replace them without changing the
/// [ProfileAvatar] values.
final class PremiumAvatarPainter extends CustomPainter {
  /// Creates a painter of [avatar], one of the avatars of the shop; a
  /// free avatar is drawn as the king.
  const PremiumAvatarPainter({required this.avatar});

  static const double _viewBox = 64;
  static const Offset _headCenter = Offset(32, 34);
  static const double _headRadius = 26;
  static const Offset _leftEye = Offset(23, 31);
  static const Offset _rightEye = Offset(41, 31);
  static const double _eyeRadius = 4;
  static const double _strokeWidth = 4;
  static const Color _ink = Color(0xFF221A4D);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _gold = Color(0xFFFFC531);
  static const Color _goldDark = Color(0xFFE0A100);
  static const Color _coral = Color(0xFFE8604C);

  /// Avatar to draw.
  final ProfileAvatar avatar;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / _viewBox);
    switch (avatar) {
      case ProfileAvatar.fox:
        _paintFox(canvas);
      case ProfileAvatar.panda:
        _paintPanda(canvas);
      case ProfileAvatar.robot:
        _paintRobot(canvas);
      case ProfileAvatar.alien:
        _paintAlien(canvas);
      case ProfileAvatar.unicorn:
        _paintUnicorn(canvas);
      case ProfileAvatar.dragon:
        _paintDragon(canvas);
      case ProfileAvatar.ninja:
        _paintNinja(canvas);
      default:
        _paintKing(canvas);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PremiumAvatarPainter oldDelegate) {
    return oldDelegate.avatar != avatar;
  }

  static Paint _fill(Color color) => Paint()..color = color;

  static Path _polygon(List<Offset> points) {
    return Path()..addPolygon(points, true);
  }

  static void _paintHead(Canvas canvas, Color color) {
    canvas.drawCircle(_headCenter, _headRadius, _fill(color));
  }

  static void _paintFace(Canvas canvas, Color color) {
    canvas.drawCircle(_leftEye, _eyeRadius, _fill(color));
    canvas.drawCircle(_rightEye, _eyeRadius, _fill(color));
    canvas.drawPath(
      Path()
        ..moveTo(23, 43)
        ..quadraticBezierTo(32, 51, 41, 43),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  static void _paintFox(Canvas canvas) {
    const Color orange = Color(0xFFE8742A);
    const Color brown = Color(0xFF8F3A12);
    canvas.drawPath(
      _polygon(const <Offset>[Offset(8, 3), Offset(28, 14), Offset(14, 30)])
        ..addPolygon(const <Offset>[
          Offset(56, 3),
          Offset(36, 14),
          Offset(50, 30),
        ], true),
      _fill(orange),
    );
    canvas.drawPath(
      _polygon(const <Offset>[Offset(11, 8), Offset(22, 15), Offset(14, 23)])
        ..addPolygon(const <Offset>[
          Offset(53, 8),
          Offset(42, 15),
          Offset(50, 23),
        ], true),
      _fill(brown),
    );
    _paintHead(canvas, orange);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(32, 46), width: 30, height: 18),
      _fill(_white),
    );
    _paintFace(canvas, _ink);
  }

  static void _paintPanda(Canvas canvas) {
    canvas.drawCircle(const Offset(13, 14), 9, _fill(_ink));
    canvas.drawCircle(const Offset(51, 14), 9, _fill(_ink));
    _paintHead(canvas, const Color(0xFFF1EEF8));
    for (final Offset eye in <Offset>[_leftEye, _rightEye]) {
      canvas.drawOval(
        Rect.fromCenter(center: eye, width: 14, height: 16),
        _fill(_ink),
      );
    }
    _paintFace(canvas, _ink);
    canvas.drawCircle(_leftEye, 2.5, _fill(_white));
    canvas.drawCircle(_rightEye, 2.5, _fill(_white));
  }

  static void _paintRobot(Canvas canvas) {
    const Color steel = Color(0xFF6F86A6);
    const Color darkSteel = Color(0xFF4A5B70);
    canvas.drawRect(const Rect.fromLTRB(30, 4, 34, 12), _fill(darkSteel));
    canvas.drawCircle(const Offset(32, 5), 4.5, _fill(_coral));
    canvas.drawRect(const Rect.fromLTRB(2, 28, 9, 42), _fill(darkSteel));
    canvas.drawRect(const Rect.fromLTRB(55, 28, 62, 42), _fill(darkSteel));
    canvas.drawRRect(
      RRect.fromLTRBR(7, 11, 57, 59, const Radius.circular(12)),
      _fill(steel),
    );
    for (final Offset eye in <Offset>[_leftEye, _rightEye]) {
      canvas.drawRect(
        Rect.fromCenter(center: eye, width: 9, height: 9),
        _fill(_white),
      );
    }
    canvas.drawRRect(
      RRect.fromLTRBR(21, 42, 43, 49, const Radius.circular(3)),
      _fill(_white),
    );
  }

  static void _paintAlien(Canvas canvas) {
    const Color green = Color(0xFF3DBE7A);
    final Paint stalk = Paint()
      ..color = const Color(0xFF1F8A55)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(25, 12), const Offset(16, 4), stalk);
    canvas.drawLine(const Offset(39, 12), const Offset(48, 4), stalk);
    canvas.drawCircle(const Offset(16, 4), 4, _fill(_gold));
    canvas.drawCircle(const Offset(48, 4), 4, _fill(_gold));
    _paintHead(canvas, green);
    for (final Offset eye in <Offset>[_leftEye, _rightEye]) {
      canvas.drawOval(
        Rect.fromCenter(center: eye, width: 11, height: 14),
        _fill(_ink),
      );
    }
    _paintFace(canvas, _ink);
  }

  static void _paintUnicorn(Canvas canvas) {
    const Color mane = Color(0xFFB8328A);
    canvas.drawCircle(const Offset(13, 21), 8, _fill(mane));
    canvas.drawCircle(const Offset(9, 33), 7, _fill(mane));
    canvas.drawCircle(const Offset(12, 45), 6, _fill(mane));
    canvas.drawPath(
      _polygon(const <Offset>[Offset(26, 12), Offset(32, 0), Offset(38, 12)]),
      _fill(_goldDark),
    );
    _paintHead(canvas, const Color(0xFFF7D6EC));
    _paintFace(canvas, _ink);
  }

  static void _paintDragon(Canvas canvas) {
    canvas.drawPath(
      _polygon(const <Offset>[
        Offset(10, 24),
        Offset(15, 7),
        Offset(23, 15),
        Offset(32, 2),
        Offset(41, 15),
        Offset(49, 7),
        Offset(54, 24),
      ]),
      _fill(_gold),
    );
    _paintHead(canvas, const Color(0xFF137A4B));
    _paintFace(canvas, _white);
  }

  static void _paintNinja(Canvas canvas) {
    canvas.drawPath(
      _polygon(const <Offset>[Offset(52, 16), Offset(63, 9), Offset(62, 21)]),
      _fill(_coral),
    );
    _paintHead(canvas, _ink);
    canvas.drawRRect(
      RRect.fromLTRBR(9, 13, 55, 19, const Radius.circular(3)),
      _fill(_coral),
    );
    canvas.drawRRect(
      RRect.fromLTRBR(8, 24, 56, 38, const Radius.circular(7)),
      _fill(const Color(0xFFF6C9A0)),
    );
    canvas.drawCircle(_leftEye, 3.5, _fill(_ink));
    canvas.drawCircle(_rightEye, 3.5, _fill(_ink));
  }

  static void _paintKing(Canvas canvas) {
    canvas.drawPath(
      _polygon(const <Offset>[
        Offset(16, 14),
        Offset(20, 2),
        Offset(26, 9),
        Offset(32, 1),
        Offset(38, 9),
        Offset(44, 2),
        Offset(48, 14),
      ]),
      _fill(_goldDark),
    );
    _paintHead(canvas, _gold);
    _paintFace(canvas, _ink);
  }
}
