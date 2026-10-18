import 'package:flutter/material.dart';

/// The yellow crown above the first player of the leaderboard.
/// Decorative.
class LeaderboardCrown extends StatelessWidget {
  /// Creates the crown, [size] wide.
  const LeaderboardCrown({required this.size, super.key});

  /// Width and height of the drawing.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _CrownPainter(fill: scheme.secondary, ink: scheme.onSurface),
      ),
    );
  }
}

/// Draws the crown of mockup 19 in its 24 x 24 box.
class _CrownPainter extends CustomPainter {
  const _CrownPainter({required this.fill, required this.ink});

  static const double _box = 24;
  static const double _strokeWidth = 1.6;

  final Color fill;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _box, size.height / _box);
    final Path crown = Path()
      ..moveTo(3, 8)
      ..lineTo(7.5, 12)
      ..lineTo(12, 5)
      ..lineTo(16.5, 12)
      ..lineTo(21, 8)
      ..lineTo(19, 18)
      ..lineTo(5, 18)
      ..close();
    canvas
      ..drawPath(crown, Paint()..color = fill)
      ..drawPath(
        crown,
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_CrownPainter oldDelegate) {
    return oldDelegate.fill != fill || oldDelegate.ink != ink;
  }
}
