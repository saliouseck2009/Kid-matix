import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar_builder.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_half.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_side_style.dart';

/// The duel screen: two halves head to tail, the top one turned upside
/// down for the player across the table, and the pause button between
/// them (mockup 15).
class DuelArena extends StatelessWidget {
  /// Creates the screen of [game].
  const DuelArena({
    required this.game,
    required this.avatarOf,
    required this.onAnswer,
    required this.onPause,
    super.key,
  });

  static const double _dividerHeight = 4;
  static const int _upsideDown = 2;

  /// The duel as it stands.
  final DuelGameEntity game;

  /// Draws the avatar of a profile.
  final DuelAvatarBuilder avatarOf;

  /// Called with the side and the answer of a tap.
  final void Function(DuelSide side, Answer answer) onAnswer;

  /// Opens the pause.
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.onSurface,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: RotatedBox(
                  quarterTurns: _upsideDown,
                  child: _HalfOf(
                    game: game,
                    side: DuelSide.top,
                    avatarOf: avatarOf,
                    onAnswer: onAnswer,
                  ),
                ),
              ),
              const SizedBox(height: _dividerHeight),
              Expanded(
                child: _HalfOf(
                  game: game,
                  side: DuelSide.bottom,
                  avatarOf: avatarOf,
                  onAnswer: onAnswer,
                ),
              ),
            ],
          ),
          _PauseButton(onPressed: onPause),
        ],
      ),
    );
  }
}

class _HalfOf extends StatelessWidget {
  const _HalfOf({
    required this.game,
    required this.side,
    required this.avatarOf,
    required this.onAnswer,
  });

  final DuelGameEntity game;
  final DuelSide side;
  final DuelAvatarBuilder avatarOf;
  final void Function(DuelSide side, Answer answer) onAnswer;

  @override
  Widget build(BuildContext context) {
    return DuelHalf(
      contender: game.of(side),
      winningScore: game.winningScore,
      style: DuelSideStyle.of(side),
      avatarOf: avatarOf,
      onAnswer: (Answer answer) => onAnswer(side, answer),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onPressed});

  static const double _size = 56;
  static const double _ringWidth = 4;
  static const double _iconSize = 28;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: context.l10n.duelPause,
      child: Semantics(
        button: true,
        label: context.l10n.duelPause,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: _size,
          child: Material(
            color: colors.onSurface,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.yellow, width: _ringWidth),
            ),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Icon(
                Icons.pause_rounded,
                color: colors.surface,
                size: _iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
