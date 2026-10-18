import 'package:meta/meta.dart';

/// Where the active player stands against the player just above them,
/// for the message at the bottom of the leaderboard.
@immutable
sealed class LeaderboardChase {
  const LeaderboardChase();
}

/// The player is first and has XP this week.
final class LeaderboardChaseLeading extends LeaderboardChase {
  /// Creates the state.
  const LeaderboardChaseLeading();
}

/// Nobody has earned XP yet this week.
final class LeaderboardChaseNotStarted extends LeaderboardChase {
  /// Creates the state.
  const LeaderboardChaseNotStarted();
}

/// The player has as many XP as [nickname], ranked above by name.
final class LeaderboardChaseTied extends LeaderboardChase {
  /// Creates the state.
  const LeaderboardChaseTied({required this.nickname});

  /// Nickname of the player just above.
  final String nickname;
}

/// The player needs [missingXp] XP to catch up with [nickname].
final class LeaderboardChaseBehind extends LeaderboardChase {
  /// Creates the state.
  const LeaderboardChaseBehind({
    required this.nickname,
    required this.missingXp,
  });

  /// Nickname of the player just above.
  final String nickname;

  /// XP between the two players, more than zero.
  final int missingXp;
}
