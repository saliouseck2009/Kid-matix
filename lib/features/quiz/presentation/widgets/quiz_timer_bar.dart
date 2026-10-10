import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Bar that empties as the time to answer runs out, with no anxious
/// figures; it turns red in the last seconds.
class QuizTimerBar extends StatelessWidget {
  /// Creates the bar filled to [remainingFraction].
  const QuizTimerBar({
    required this.remainingFraction,
    required this.isRunningOut,
    this.semanticLabel,
    super.key,
  });

  static const double _height = 10;
  static const double _iconSize = 22;

  /// Fraction of the time left, from 1 to 0.
  final double remainingFraction;

  /// Whether the timer is in its last seconds.
  final bool isRunningOut;

  /// What a screen reader says of the bar; "Temps restant" by default.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusPill);
    final Color fill = isRunningOut
        ? context.feedbackPalette.wrong
        : Theme.of(context).colorScheme.secondary;
    return Semantics(
      label: semanticLabel ?? context.l10n.quizTimeLeftLabel,
      excludeSemantics: true,
      child: Row(
        spacing: AppSizes.space8,
        children: <Widget>[
          Icon(
            Icons.schedule_rounded,
            size: _iconSize,
            color: context.palette.mutedText,
          ),
          Expanded(
            child: Container(
              height: _height,
              alignment: AlignmentDirectional.centerStart,
              decoration: BoxDecoration(
                color: context.palette.tint,
                borderRadius: radius,
              ),
              child: FractionallySizedBox(
                widthFactor: remainingFraction,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: fill, borderRadius: radius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
