import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:meta/meta.dart';

/// Someone who plays a duel: a player of the phone or a guest.
@immutable
sealed class DuelPlayer {
  /// Creates a player.
  const DuelPlayer();

  /// Identifier of the profile, or `null` for a guest.
  String? get profileId;
}

/// A player of the phone: plays their open tables and earns XP.
final class ProfileDuelPlayer extends DuelPlayer {
  /// Creates the duel player of [identity].
  const ProfileDuelPlayer(this.identity);

  /// Who the player is.
  final PlayerIdentity identity;

  @override
  String get profileId => identity.id;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileDuelPlayer && other.identity == identity;
  }

  @override
  int get hashCode => identity.hashCode;
}

/// Someone without a profile: plays every table and earns nothing.
final class GuestDuelPlayer extends DuelPlayer {
  /// Creates the guest.
  const GuestDuelPlayer();

  @override
  String? get profileId => null;

  @override
  bool operator ==(Object other) => other is GuestDuelPlayer;

  @override
  int get hashCode => (GuestDuelPlayer).hashCode;
}
