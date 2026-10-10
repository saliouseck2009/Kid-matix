import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/mascot_painter.dart';

/// The mascot, [size] wide; decorative. Provisional until lot F8.
class MascotIllustration extends StatelessWidget {
  /// Creates the mascot drawing.
  const MascotIllustration({required this.size, super.key});

  /// Width and height of the drawing.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: MascotPainter(
          bodyColor: colors.secondary,
          feetColor: context.palette.secondaryDepth,
          eyeColor: colors.surface,
          inkColor: colors.onSurface,
          badgeColor: colors.primary,
        ),
      ),
    );
  }
}
