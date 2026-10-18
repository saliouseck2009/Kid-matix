import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';

/// A number line: a line with one tick per number, the numbers under the
/// ticks, the hidden one in a yellow box and the highlighted one in a
/// tinted circle. Decorative: [MathPictureView] gives its label.
class NumberLineView extends StatelessWidget {
  /// Creates the view of [line]; [blankText] fills its hidden number.
  const NumberLineView({
    required this.line,
    this.blankText,
    this.blankColor,
    super.key,
  });

  static const double _lineHeight = 28;
  static const double _fontSize = 30;

  /// Ticks to draw.
  final NumberLinePicture line;

  /// What the player typed for the hidden number, or `null`.
  final String? blankText;

  /// Color of [blankText]; the text color when `null`.
  final Color? blankColor;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(
      context,
    ).textTheme.displaySmall?.copyWith(fontSize: _fontSize);
    final Color ink = Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.space8,
      children: <Widget>[
        SizedBox(
          height: _lineHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: _LinePainter(tickCount: line.values.length, color: ink),
          ),
        ),
        Row(
          children: <Widget>[
            for (int index = 0; index < line.values.length; index++)
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _TickLabel(
                      text: index == line.blankIndex
                          ? blankText ?? '?'
                          : '${line.values[index]}',
                      isBlank: index == line.blankIndex,
                      isHighlighted: index == line.highlightIndex,
                      style: index == line.blankIndex && blankText != null
                          ? style?.copyWith(color: blankColor)
                          : style,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TickLabel extends StatelessWidget {
  const _TickLabel({
    required this.text,
    required this.isBlank,
    required this.isHighlighted,
    required this.style,
  });

  static const double _boxBorder = 3;
  static const double _minSize = 56;
  static const double _highlightAlpha = 0.25;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space8,
    vertical: AppSizes.space4,
  );

  final String text;
  final bool isBlank;
  final bool isHighlighted;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Decoration? decoration = isBlank
        ? BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: scheme.secondary, width: _boxBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          )
        : isHighlighted
        ? BoxDecoration(
            color: scheme.primary.withValues(alpha: _highlightAlpha),
            shape: BoxShape.circle,
          )
        : null;
    return Container(
      constraints: const BoxConstraints(
        minWidth: _minSize,
        minHeight: _minSize,
      ),
      padding: _padding,
      alignment: Alignment.center,
      decoration: decoration,
      child: Text(text, style: style),
    );
  }
}

/// The line, an arrow on its right and one tick in the middle of each
/// slot of the row of numbers.
class _LinePainter extends CustomPainter {
  _LinePainter({required this.tickCount, required this.color});

  static const double _stroke = 4;
  static const double _tickHeight = 22;
  static const double _arrow = 10;

  final int tickCount;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    final double slot = size.width / tickCount;
    final double middle = size.height / 2;
    canvas.drawLine(
      Offset(slot / 4, middle),
      Offset(size.width - _stroke, middle),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - _stroke, middle),
      Offset(size.width - _stroke - _arrow, middle - _arrow),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - _stroke, middle),
      Offset(size.width - _stroke - _arrow, middle + _arrow),
      paint,
    );
    for (int tick = 0; tick < tickCount; tick++) {
      final double x = slot * (tick + 0.5);
      canvas.drawLine(
        Offset(x, middle - _tickHeight / 2),
        Offset(x, middle + _tickHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter oldDelegate) {
    return oldDelegate.tickCount != tickCount || oldDelegate.color != color;
  }
}
