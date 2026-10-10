import 'package:kid_matix/features/reward/domain/usecases/get_badges_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_daily_goal_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_session_rewards_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_streak_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';

/// Use cases of the reward widgets.
final class RewardUseCases {
  /// Groups the use cases.
  const RewardUseCases({
    required this.getStreak,
    required this.getDailyGoal,
    required this.getSessionRewards,
    required this.getBadges,
    required this.watchChanges,
  });

  /// Reads the streak of a player.
  final GetStreakUseCase getStreak;

  /// Reads the daily goal of a player.
  final GetDailyGoalUseCase getDailyGoal;

  /// Reads the rewards of a quiz.
  final GetSessionRewardsUseCase getSessionRewards;

  /// Reads the badges of a player.
  final GetBadgesUseCase getBadges;

  /// Tells when the rewards change.
  final WatchRewardChangesUseCase watchChanges;
}
