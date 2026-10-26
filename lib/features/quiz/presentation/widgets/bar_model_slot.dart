import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';

/// What a place of the bar model holds.
enum BarSlotState {
  /// Waiting for a number of the story.
  empty,

  /// Holds a number of the story.
  filled,

  /// The number to find, still hidden.
  unknown,

  /// The number to find, shown.
  answer,
}

/// One place of the bar model: its name small, its number big.
///
/// A place that was touched wrongly shows a cross and shakes once, and a
/// screen reader says so: a mistake never relies on color alone.
class BarModelSlot extends StatelessWidget {
  /// Creates the place [role] showing [text].
  const BarModelSlot({
    required this.role,
    required this.text,
    required this.state,
    required this.isWrong,
    required this.wrongCount,
    required this.isDashed,
    required this.onTap,
    super.key,
  });

  /// Smallest height of a place, a bar of the model.
  static const double height = 64;

  static const double _shakeReach = 8;
  static const double _shakeWaves = 4;
  static const Duration _shakeTime = Duration(milliseconds: 400);

  /// The place.
  final BarRole role;

  /// The number written, or "?" or nothing.
  final String text;

  /// What the place holds.
  final BarSlotState state;

  /// Whether the child just put a wrong number here.
  final bool isWrong;

  /// Mistakes made so far: a new one shakes the place again.
  final int wrongCount;

  /// Whether the border is dashed, for a part that is taken away or a gap.
  final bool isDashed;

  /// Called when the child touches the place; `null` for a plain drawing.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppFeedbackPalette feedback = context.feedbackPalette;
    final String name = context.l10n.quizBarRoleName(role.name);
    final (Color, Color) faces = switch (state) {
      BarSlotState.empty => (colors.surface, context.palette.primaryText),
      BarSlotState.filled => (
        context.palette.tint,
        context.palette.primaryText,
      ),
      BarSlotState.unknown => (colors.secondary, colors.onSecondary),
      BarSlotState.answer => (feedback.right, colors.onPrimary),
    };
    final Color border = isWrong
        ? feedback.wrong
        : isDashed || state == BarSlotState.empty
        ? context.palette.border
        : Colors.transparent;
    final String spoken = isWrong
        ? context.l10n.quizBarSlotWrong(name)
        : switch (state) {
            BarSlotState.empty => context.l10n.quizBarSlotEmpty(name),
            BarSlotState.unknown => context.l10n.quizBarSlotUnknown(name),
            _ => context.l10n.quizBarSlotValue(name, text),
          };
    final Widget slot = Semantics(
      button: onTap != null,
      label: spoken,
      excludeSemantics: true,
      onTap: onTap,
      child: CustomPaint(
        foregroundPainter: isDashed && !isWrong
            ? _DashedBorderPainter(color: border)
            : null,
        child: Material(
          color: faces.$1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            side: isDashed && !isWrong
                ? BorderSide.none
                : BorderSide(color: border, width: AppSizes.borderWidth),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: height),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.space8,
                      vertical: AppSizes.space4,
                    ),
                    child: _Labels(name: name, text: text, color: faces.$2),
                  ),
                  if (isWrong)
                    PositionedDirectional(
                      top: AppSizes.space4,
                      end: AppSizes.space4,
                      child: Icon(
                        Icons.close_rounded,
                        color: feedback.wrong,
                        size: AppSizes.space24,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (!isWrong) return slot;
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(wrongCount),
      tween: Tween<double>(begin: 0, end: 1),
      duration: _shakeTime,
      builder: (BuildContext context, double progress, Widget? child) {
        final double offset =
            math.sin(progress * math.pi * _shakeWaves) *
            (1 - progress) *
            _shakeReach;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: slot,
    );
  }
}

class _Labels extends StatelessWidget {
  const _Labels({required this.name, required this.text, required this.color});

  final String name;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          name,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(color: color),
        ),
        Text(
          text.isEmpty ? ' ' : text,
          style: textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// The dashed outline of a part taken away or of a gap.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSizes.borderWidth;
    final Path outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppSizes.radiusSmall),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _BarDash.length),
          paint,
        );
        distance += _BarDash.length + _BarDash.gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

abstract final class _BarDash {
  static const double length = 6;
  static const double gap = 4;
}
