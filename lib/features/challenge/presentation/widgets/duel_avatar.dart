import 'package:flutter/material.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_avatar_builder.dart';

/// The avatar of a duel player, [size] wide: the profile's own, or a
/// plain silhouette for a guest. Decorative: the name next to it speaks.
class DuelAvatar extends StatelessWidget {
  /// Creates the avatar of [player].
  const DuelAvatar({
    required this.player,
    required this.avatarOf,
    required this.guestColor,
    required this.size,
    super.key,
  });

  static const double _iconRatio = 0.6;

  /// Player drawn.
  final DuelPlayer player;

  /// Draws the avatar of a profile.
  final DuelAvatarBuilder avatarOf;

  /// Background of the guest silhouette.
  final Color guestColor;

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: switch (player) {
        ProfileDuelPlayer(:final identity) => avatarOf(identity, size),
        GuestDuelPlayer() => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: guestColor, shape: BoxShape.circle),
          child: Icon(
            Icons.person_rounded,
            size: size * _iconRatio,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      },
    );
  }
}
