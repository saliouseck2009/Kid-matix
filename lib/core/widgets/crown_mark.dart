import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Round mark with a crown, set on the badge of a table whose boss is
/// defeated: yellow when the crown is golden, white otherwise.
///
/// Decorative: the label of the table tells screen readers about it.
class CrownMark extends StatelessWidget {
  /// Creates the mark.
  const CrownMark({required this.isGolden, this.size = 32, super.key});

  static const double _ringWidth = 3;

  /// Whether every fact of the table is mastered.
  final bool isGolden;

  /// Diameter of the mark.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.22),
        decoration: BoxDecoration(
          color: isGolden ? scheme.secondary : scheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: _ringWidth,
          ),
        ),
        child: CustomPaint(
          painter: _CrownPainter(
            color: isGolden
                ? scheme.onSecondary
                : context.palette.secondaryDepth,
          ),
        ),
      ),
    );
  }
}

/// A bare crown of [size], painted in [color]; decorative.
class CrownGlyph extends StatelessWidget {
  /// Creates the crown.
  const CrownGlyph({required this.color, this.size = 18, super.key});

  /// Color of the crown.
  final Color color;

  /// Width and height of the crown.
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _CrownPainter(color: color),
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  _CrownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Path crown = Path()
      ..moveTo(0, h * 0.25)
      ..lineTo(w * 0.28, h * 0.55)
      ..lineTo(w * 0.5, h * 0.12)
      ..lineTo(w * 0.72, h * 0.55)
      ..lineTo(w, h * 0.25)
      ..lineTo(w * 0.88, h * 0.88)
      ..lineTo(w * 0.12, h * 0.88)
      ..close();
    canvas.drawPath(crown, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CrownPainter oldDelegate) => oldDelegate.color != color;
}
