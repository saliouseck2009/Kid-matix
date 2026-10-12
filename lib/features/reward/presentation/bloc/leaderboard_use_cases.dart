import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/set_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';

/// Use cases of the leaderboard, its entry and its setting.
final class LeaderboardUseCases {
  /// Groups the use cases.
  const LeaderboardUseCases({
    required this.getLeaderboard,
    required this.watchRewardChanges,
    required this.getVisibility,
    required this.setVisibility,
    required this.watchVisibility,
  });

  /// Reads the weekly ranking.
  final GetLeaderboardUseCase getLeaderboard;

  /// Tells when XP or players change.
  final WatchRewardChangesUseCase watchRewardChanges;

  /// Reads whether the leaderboard is shown.
  final GetLeaderboardVisibilityUseCase getVisibility;

  /// Shows or hides the leaderboard.
  final SetLeaderboardVisibilityUseCase setVisibility;

  /// Tells when the setting changes.
  final WatchLeaderboardVisibilityUseCase watchVisibility;
}
