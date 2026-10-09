import 'package:flutter/rendering.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';

/// Draws one of the 12 avatars, traced from the design mockups.
///
/// Each avatar is a round face with one of six ear shapes and one of two
/// mouths, drawn in a 64 x 64 box scaled to the canvas. The drawings are
/// provisional; final illustrations replace them without changing the
/// [ProfileAvatar] values.
final class ProfileAvatarPainter extends CustomPainter {
  /// Creates a painter of [avatar] on [background], with [faceColor] for the
  /// eyes and the mouth.
  const ProfileAvatarPainter({
    required this.avatar,
    required this.background,
    required this.faceColor,
  });

  /// Number of different ear shapes.
  static const int earShapeCount = 6;

  static const double _viewBox = 64;
  static const Offset _headCenter = Offset(32, 34);
  static const double _headRadius = 26;
  static const Offset _leftEye = Offset(23, 31);
  static const Offset _rightEye = Offset(41, 31);
  static const double _eyeRadius = 4;
  static const double _mouthWidth = 4;
  static const List<Path Function()> _earBuilders = <Path Function()>[
    _buildHornEars,
    _buildRoundEars,
    _buildTuft,
    _buildCatEars,
    _buildAntennae,
    Path.new,
  ];

  /// Avatar to draw.
  final ProfileAvatar avatar;

  /// Color of the head and ears.
  final Color background;

  /// Color of the eyes and the mouth.
  final Color faceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / _viewBox;
    canvas.save();
    canvas.scale(scale);
    final Paint fill = Paint()..color = background;
    final Paint face = Paint()..color = faceColor;
    canvas.drawPath(_earBuilders[avatar.index % earShapeCount](), fill);
    canvas.drawCircle(_headCenter, _headRadius, fill);
    canvas.drawCircle(_leftEye, _eyeRadius, face);
    canvas.drawCircle(_rightEye, _eyeRadius, face);
    canvas.drawPath(
      _hasOpenMouth ? _buildOpenMouth() : _buildSmile(),
      Paint()
        ..color = faceColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _mouthWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ProfileAvatarPainter oldDelegate) {
    return oldDelegate.avatar != avatar ||
        oldDelegate.background != background ||
        oldDelegate.faceColor != faceColor;
  }

  /// The second half of the avatars has an open mouth instead of a smile.
  bool get _hasOpenMouth => avatar.index >= earShapeCount;

  static Path _buildHornEars() {
    return Path()
      ..addPolygon(const <Offset>[
        Offset(10, 6),
        Offset(18, 26),
        Offset(32, 16),
      ], true)
      ..addPolygon(const <Offset>[
        Offset(54, 6),
        Offset(46, 26),
        Offset(32, 16),
      ], true);
  }

  static Path _buildRoundEars() {
    return Path()
      ..addOval(Rect.fromCircle(center: const Offset(13, 14), radius: 9))
      ..addOval(Rect.fromCircle(center: const Offset(51, 14), radius: 9));
  }

  static Path _buildTuft() {
    return Path()..addPolygon(const <Offset>[
      Offset(32, 2),
      Offset(38, 12),
      Offset(26, 12),
    ], true);
  }

  static Path _buildCatEars() {
    return Path()
      ..moveTo(17, 24)
      ..lineTo(17, 5)
      ..quadraticBezierTo(24, 3, 26, 11)
      ..lineTo(26, 22)
      ..close()
      ..moveTo(47, 24)
      ..lineTo(47, 5)
      ..quadraticBezierTo(40, 3, 38, 11)
      ..lineTo(38, 22)
      ..close();
  }

  static Path _buildAntennae() {
    return Path()
      ..addPolygon(const <Offset>[
        Offset(22, 12),
        Offset(18, 2),
        Offset(22, 2),
        Offset(26, 11),
      ], true)
      ..addPolygon(const <Offset>[
        Offset(42, 12),
        Offset(46, 2),
        Offset(42, 2),
        Offset(38, 11),
      ], true);
  }

  static Path _buildSmile() {
    return Path()
      ..moveTo(23, 43)
      ..quadraticBezierTo(32, 51, 41, 43);
  }

  static Path _buildOpenMouth() {
    return Path()
      ..moveTo(25, 42)
      ..lineTo(39, 42)
      ..quadraticBezierTo(32, 52, 25, 42)
      ..close();
  }
}
