import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Dots joining two nodes of the map, from the horizontal place [fromX]
/// of the node above to [toX] of the node below, both from -1 to 1.
class PathDots extends StatelessWidget {
  /// Creates the dots.
  const PathDots({required this.fromX, required this.toX, super.key});

  static const double _height = 36;

  /// Place of the node above.
  final double fromX;

  /// Place of the node below.
  final double toX;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: _height,
        child: CustomPaint(
          painter: _DotsPainter(
            fromX: fromX,
            toX: toX,
            color: context.palette.strongBorder,
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.fromX, required this.toX, required this.color});

  static const int _dotCount = 4;
  static const double _radius = 4;

  /// Half the width of a node, so the dots start under its center.
  static const double _nodeHalf = 44;

  final double fromX;
  final double toX;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final double span = size.width - _nodeHalf * 2;
    double xOf(double place) => _nodeHalf + (place + 1) / 2 * span;
    for (int index = 0; index < _dotCount; index++) {
      final double t = (index + 0.5) / _dotCount;
      canvas.drawCircle(
        Offset(
          xOf(fromX) + (xOf(toX) - xOf(fromX)) * t,
          size.height * t,
        ),
        _radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) {
    return oldDelegate.fromX != fromX ||
        oldDelegate.toX != toX ||
        oldDelegate.color != color;
  }
}
