import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_chase.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entity.dart';
import 'package:meta/meta.dart';

/// The weekly leaderboard screen.
@immutable
sealed class LeaderboardState {
  const LeaderboardState();
}

/// The ranking is being read.
final class LeaderboardLoading extends LeaderboardState {
  /// Creates the state.
  const LeaderboardLoading();
}

/// The ranking read, seen by the active player.
final class LeaderboardLoaded extends LeaderboardState {
  /// Creates the state.
  const LeaderboardLoaded({
    required this.leaderboard,
    required this.activeProfileId,
    required this.chase,
  });

  /// Players ranked by their XP of the week.
  final LeaderboardEntity leaderboard;

  /// The player looking at the screen, highlighted.
  final String activeProfileId;

  /// Where the active player stands against the one above, or `null`.
  final LeaderboardChase? chase;
}

/// The ranking could not be read.
final class LeaderboardFailure extends LeaderboardState {
  /// Creates the state.
  const LeaderboardFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
