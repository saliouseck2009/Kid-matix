import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_timer_bar.dart';

/// Top of a quiz against the clock: the quit cross, the bar of the time
/// left to play and the live score.
class ClockHeader extends StatelessWidget {
  /// Creates the header with [timeLeft] out of [totalTime] and [score]
  /// right answers.
  const ClockHeader({
    required this.timeLeft,
    required this.totalTime,
    required this.score,
    required this.onQuit,
    super.key,
  });

  /// The bar turns red in the last 10 seconds.
  static const Duration warning = Duration(seconds: 10);

  /// Time left to play.
  final Duration timeLeft;

  /// Time to play the whole quiz.
  final Duration totalTime;

  /// Right answers so far.
  final int score;

  /// Called by the quit cross.
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final Duration left = timeLeft.isNegative ? Duration.zero : timeLeft;
    final double fraction = totalTime == Duration.zero
        ? 0
        : left.inMilliseconds / totalTime.inMilliseconds;
    final int secondsLeft =
        (left.inMilliseconds / Duration.millisecondsPerSecond).ceil();
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        AppIconButton(
          icon: Icons.close_rounded,
          tooltip: context.l10n.quizQuitTooltip,
          onPressed: onQuit,
        ),
        Expanded(
          child: QuizTimerBar(
            remainingFraction: fraction.clamp(0, 1),
            isRunningOut: left <= warning,
            semanticLabel: context.l10n.quizClockLeftSpoken(secondsLeft),
          ),
        ),
        Semantics(
          label: context.l10n.quizScoreSpoken(score),
          liveRegion: true,
          excludeSemantics: true,
          child: AppPill(
            label: '$score',
            icon: Icons.check_circle_rounded,
            backgroundColor: context.feedbackPalette.rightTint,
          ),
        ),
      ],
    );
  }
}
