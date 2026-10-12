import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_lineup.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_state.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar_builder.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_player_name.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_side_style.dart';

/// The choice of the two players before a duel: a profile or the guest
/// for each half, never the same profile twice. No mockup: derived from
/// the challenges screen.
class DuelPlayerPicker extends StatelessWidget {
  /// Creates the choice shown by [state].
  const DuelPlayerPicker({
    required this.state,
    required this.avatarOf,
    required this.onPick,
    required this.onStart,
    required this.onBack,
    super.key,
  });

  /// Players of the phone and the current picks.
  final DuelChoosingPlayers state;

  /// Draws the avatar of a profile.
  final DuelAvatarBuilder avatarOf;

  /// Called when a player is picked for a half.
  final void Function(DuelSide side, DuelPlayer player) onPick;

  /// Starts the duel.
  final ValueChanged<DuelLineup> onStart;

  /// Leaves the duel.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final DuelLineup? lineup = state.lineup;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.space24),
      children: <Widget>[
        Row(
          spacing: AppSizes.space12,
          children: <Widget>[
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: context.l10n.commonBack,
              onPressed: onBack,
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  context.l10n.duelTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.space12),
        Text(context.l10n.duelPickIntro),
        for (final DuelSide side in DuelSide.values)
          _SideChoice(
            side: side,
            state: state,
            avatarOf: avatarOf,
            onPick: onPick,
          ),
        const SizedBox(height: AppSizes.space24),
        if (lineup == null) ...<Widget>[
          Text(context.l10n.duelPickHint, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.space12),
        ],
        DepthButton(
          label: context.l10n.duelStart,
          onPressed: lineup == null ? null : () => onStart(lineup),
        ),
      ],
    );
  }
}

class _SideChoice extends StatelessWidget {
  const _SideChoice({
    required this.side,
    required this.state,
    required this.avatarOf,
    required this.onPick,
  });

  static const double _gap = 10;

  final DuelSide side;
  final DuelChoosingPlayers state;
  final DuelAvatarBuilder avatarOf;
  final void Function(DuelSide side, DuelPlayer player) onPick;

  @override
  Widget build(BuildContext context) {
    final DuelPlayer? picked = state.playerOf(side);
    final DuelPlayer? taken = state.playerOf(side.opponent);
    final List<DuelPlayer> choices = <DuelPlayer>[
      for (final PlayerIdentity player in state.players)
        ProfileDuelPlayer(player),
      const GuestDuelPlayer(),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.space12,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              side == DuelSide.top
                  ? context.l10n.duelSideTop
                  : context.l10n.duelSideBottom,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: <Widget>[
              for (final DuelPlayer choice in choices)
                _PlayerOption(
                  player: choice,
                  style: DuelSideStyle.of(side),
                  avatarOf: avatarOf,
                  isPicked: choice == picked,
                  isTaken: choice == taken,
                  onTap: () => onPick(side, choice),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerOption extends StatelessWidget {
  const _PlayerOption({
    required this.player,
    required this.style,
    required this.avatarOf,
    required this.isPicked,
    required this.isTaken,
    required this.onTap,
  });

  static const double _avatarSize = 36;
  static const double _radius = 18;
  static const double _pickedBorder = 3;
  static const double _disabledOpacity = 0.4;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(8, 8, 14, 8);

  final DuelPlayer player;
  final DuelSideStyle style;
  final DuelAvatarBuilder avatarOf;
  final bool isPicked;
  final bool isTaken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(_radius);
    final Color borderColor = isPicked ? style.accent : context.palette.border;
    return Semantics(
      button: true,
      selected: isPicked,
      enabled: !isTaken,
      hint: isTaken ? context.l10n.duelPlayerTaken : null,
      child: Material(
        color: isTaken
            ? colors.surface.withValues(alpha: _disabledOpacity)
            : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: borderColor,
            width: isPicked ? _pickedBorder : AppSizes.borderWidth,
          ),
        ),
        child: InkWell(
          onTap: isTaken ? null : onTap,
          customBorder: RoundedRectangleBorder(borderRadius: radius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Padding(
              padding: _padding,
              child: _OptionContent(
                player: player,
                style: style,
                avatarOf: avatarOf,
                isPicked: isPicked,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionContent extends StatelessWidget {
  const _OptionContent({
    required this.player,
    required this.style,
    required this.avatarOf,
    required this.isPicked,
  });

  final DuelPlayer player;
  final DuelSideStyle style;
  final DuelAvatarBuilder avatarOf;
  final bool isPicked;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: <Widget>[
        DuelAvatar(
          player: player,
          avatarOf: avatarOf,
          guestColor: context.palette.mutedText,
          size: _PlayerOption._avatarSize,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(player.nameIn(context.l10n), style: text.titleMedium),
              if (player is GuestDuelPlayer)
                Text(
                  context.l10n.duelGuestRule,
                  style: text.bodySmall?.copyWith(
                    color: context.palette.mutedText,
                  ),
                ),
            ],
          ),
        ),
        if (isPicked) Icon(Icons.check_circle_rounded, color: style.accent),
      ],
    );
  }
}
