import 'package:flutter/material.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_theme_colors.dart';

/// A small picture of a screen in the colors of [theme]: its ground, a
/// card and a button.
///
/// Decorative: the name of the theme under it carries the meaning.
class ThemeSwatch extends StatelessWidget {
  /// Creates the picture of [theme], [height] high.
  const ThemeSwatch({required this.theme, this.height = 76, super.key});

  static const double _aspectRatio = 1.3;

  /// Theme shown.
  final AppColorTheme theme;

  /// Height of the picture.
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(height * _aspectRatio, height),
        painter: ThemeSwatchPainter(colors: AppThemeColors.of(theme)),
      ),
    );
  }
}

/// Draws the picture of a theme in a 100 x 76 box scaled to the canvas.
final class ThemeSwatchPainter extends CustomPainter {
  /// Creates the painter of [colors].
  const ThemeSwatchPainter({required this.colors});

  static const double _width = 100;

  /// Colors of the theme.
  final AppThemeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _width);
    _paintRounded(canvas, const Rect.fromLTWH(1, 1, 98, 74), 16, colors.border);
    _paintRounded(canvas, const Rect.fromLTWH(3, 3, 94, 70), 14, colors.ground);
    _paintRounded(
      canvas,
      const Rect.fromLTWH(12, 12, 76, 26),
      9,
      colors.surface,
    );
    canvas.drawCircle(
      const Offset(25, 25),
      7,
      Paint()..color = AppColors.yellow,
    );
    _paintRounded(canvas, const Rect.fromLTWH(38, 21, 40, 8), 4, colors.ink);
    _paintRounded(
      canvas,
      const Rect.fromLTWH(12, 48, 76, 16),
      8,
      colors.primaryDepth,
    );
    _paintRounded(
      canvas,
      const Rect.fromLTWH(12, 46, 76, 15),
      8,
      colors.primary,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ThemeSwatchPainter oldDelegate) {
    return oldDelegate.colors != colors;
  }

  static void _paintRounded(
    Canvas canvas,
    Rect rect,
    double radius,
    Color color,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = color,
    );
  }
}
