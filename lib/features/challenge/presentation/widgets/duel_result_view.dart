import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_outcome.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar_builder.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_player_name.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_side_style.dart';

/// The end of a duel: the winner, each player's score and XP, "Rejouer"
/// and "Quitter".
class DuelResultView extends StatelessWidget {
  /// Creates the view of [game], ended with [outcome].
  const DuelResultView({
    required this.game,
    required this.outcome,
    required this.avatarOf,
    required this.onReplay,
    required this.onQuit,
    super.key,
  });

  static const double _trophySize = 72;

  /// The duel as it ended.
  final DuelGameEntity game;

  /// The winner and the XP.
  final DuelOutcome outcome;

  /// Draws the avatar of a profile.
  final DuelAvatarBuilder avatarOf;

  /// Starts a new duel between the same players.
  final VoidCallback onReplay;

  /// Leaves the duel.
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final DuelSide winner = outcome.winner;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.space24),
      children: <Widget>[
        const ExcludeSemantics(
          child: Icon(
            Icons.emoji_events_rounded,
            size: _trophySize,
            color: AppColors.yellow,
          ),
        ),
        const SizedBox(height: AppSizes.space12),
        Semantics(
          header: true,
          child: Text(
            context.l10n.duelWinner(
              game.of(winner).player.nameIn(context.l10n),
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSizes.space24),
        for (final DuelSide side in <DuelSide>[winner, winner.opponent]) ...[
          _PlayerResult(
            game: game,
            side: side,
            xp: outcome.xpOf(side),
            avatarOf: avatarOf,
          ),
          const SizedBox(height: AppSizes.space12),
        ],
        if (!outcome.isXpSaved)
          Text(
            context.l10n.duelXpNotSaved,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.feedbackPalette.wrong),
          ),
        const SizedBox(height: AppSizes.space24),
        DepthButton(label: context.l10n.duelReplay, onPressed: onReplay),
        const SizedBox(height: AppSizes.space12),
        DepthButton(
          label: context.l10n.duelQuit,
          variant: DepthButtonVariant.secondary,
          onPressed: onQuit,
        ),
      ],
    );
  }
}

class _PlayerResult extends StatelessWidget {
  const _PlayerResult({
    required this.game,
    required this.side,
    required this.xp,
    required this.avatarOf,
  });

  static const double _avatarSize = 48;

  final DuelGameEntity game;
  final DuelSide side;
  final int xp;
  final DuelAvatarBuilder avatarOf;

  @override
  Widget build(BuildContext context) {
    final DuelPlayer player = game.of(side).player;
    final DuelSideStyle style = DuelSideStyle.of(side);
    final TextTheme text = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        spacing: AppSizes.space12,
        children: <Widget>[
          DuelAvatar(
            player: player,
            avatarOf: avatarOf,
            guestColor: style.accent,
            size: _avatarSize,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(player.nameIn(context.l10n), style: text.titleMedium),
                Text(
                  player is GuestDuelPlayer
                      ? context.l10n.duelGuestNoXp
                      : context.l10n.duelXpEarned(xp),
                  style: text.bodyLarge,
                ),
              ],
            ),
          ),
          Semantics(
            label: context.l10n.duelScoreSpoken(
              player.nameIn(context.l10n),
              game.of(side).score,
              game.winningScore,
            ),
            excludeSemantics: true,
            child: Text(
              context.l10n.duelScore(game.of(side).score, game.winningScore),
              style: text.titleLarge?.copyWith(color: style.scoreText),
            ),
          ),
        ],
      ),
    );
  }
}
