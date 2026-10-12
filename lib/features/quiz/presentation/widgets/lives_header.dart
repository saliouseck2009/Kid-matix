import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';

/// Top of a quiz with lives: the quit cross, a heart per life, emptied
/// once lost, and the live score.
class LivesHeader extends StatelessWidget {
  /// Creates the header with [livesLeft] hearts full out of [lives] and
  /// [score] right answers.
  const LivesHeader({
    required this.livesLeft,
    required this.lives,
    required this.score,
    required this.onQuit,
    super.key,
  });

  static const double _heartSize = 30;
  static const double _heartGap = 4;

  /// Lives not lost yet.
  final int livesLeft;

  /// Lives at the start of the quiz.
  final int lives;

  /// Right answers so far.
  final int score;

  /// Called by the quit cross.
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final Color heartColor = context.feedbackPalette.wrong;
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        AppIconButton(
          icon: Icons.close_rounded,
          tooltip: context.l10n.quizQuitTooltip,
          onPressed: onQuit,
        ),
        Expanded(
          child: Semantics(
            label: context.l10n.quizLivesSpoken(livesLeft, lives),
            liveRegion: true,
            excludeSemantics: true,
            child: Row(
              spacing: _heartGap,
              children: <Widget>[
                for (int index = 0; index < lives; index++)
                  Icon(
                    index < livesLeft
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: _heartSize,
                    color: heartColor,
                  ),
              ],
            ),
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
