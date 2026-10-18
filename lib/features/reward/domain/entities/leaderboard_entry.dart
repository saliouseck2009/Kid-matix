import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:meta/meta.dart';

/// A player of a leaderboard with the XP they earned this week.
@immutable
final class LeaderboardEntry {
  /// Creates the entry of [player].
  const LeaderboardEntry({required this.player, required this.weeklyXp});

  /// Who the player is.
  final PlayerIdentity player;

  /// XP earned since Monday 00:00.
  final int weeklyXp;

  /// Returns a copy with the given fields replaced.
  LeaderboardEntry copyWith({PlayerIdentity? player, int? weeklyXp}) {
    return LeaderboardEntry(
      player: player ?? this.player,
      weeklyXp: weeklyXp ?? this.weeklyXp,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LeaderboardEntry &&
            other.player == player &&
            other.weeklyXp == weeklyXp;
  }

  @override
  int get hashCode => Object.hash(player, weeklyXp);

  @override
  String toString() => 'LeaderboardEntry(${player.nickname}, $weeklyXp)';
}
