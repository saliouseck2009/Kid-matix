import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// The coin of the shop: a yellow coin marked with a cross, [size] wide.
///
/// Decorative: the number next to it carries the meaning.
class CoinIcon extends StatelessWidget {
  /// Creates the coin.
  const CoinIcon({this.size = 22, super.key});

  /// Width and height of the coin.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: CoinPainter(
          rim: context.palette.secondaryDepth,
          face: colors.secondary,
          mark: colors.onSecondary,
        ),
      ),
    );
  }
}

/// Draws the coin in a 24 x 24 box scaled to the canvas, traced from
/// mockup 22.
final class CoinPainter extends CustomPainter {
  /// Creates the painter.
  const CoinPainter({
    required this.rim,
    required this.face,
    required this.mark,
  });

  static const double _viewBox = 24;
  static const Offset _center = Offset(12, 12);
  static const double _rimRadius = 11;
  static const double _faceRadius = 8;
  static const double _markWidth = 2.2;

  /// Color of the edge.
  final Color rim;

  /// Color of the face.
  final Color face;

  /// Color of the cross.
  final Color mark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / _viewBox);
    canvas.drawCircle(_center, _rimRadius, Paint()..color = rim);
    canvas.drawCircle(_center, _faceRadius, Paint()..color = face);
    final Paint cross = Paint()
      ..color = mark
      ..strokeWidth = _markWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(9, 9), const Offset(15, 15), cross);
    canvas.drawLine(const Offset(15, 9), const Offset(9, 15), cross);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CoinPainter oldDelegate) {
    return oldDelegate.rim != rim ||
        oldDelegate.face != face ||
        oldDelegate.mark != mark;
  }
}
