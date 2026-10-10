import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_badges_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_daily_goal_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_session_rewards_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_streak_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_use_cases.dart';
import 'package:kid_matix/features/reward/presentation/reward_pages.dart';

import '../features/quiz/helpers/quiz_fixtures.dart';
import 'test_quiz_pages.dart';

/// [RewardRepository] holding the values the test sets.
final class InMemoryRewardRepository implements RewardRepository {
  /// Creates the repository.
  InMemoryRewardRepository({
    this.streak = const StreakEntity.empty(),
    this.xpEarned = 0,
    this.sessionXp,
    List<BadgeUnlockEntity> badges = const <BadgeUnlockEntity>[],
  }) : badges = List<BadgeUnlockEntity>.of(badges);

  /// Streak returned.
  StreakEntity streak;

  /// XP returned for any range.
  int xpEarned;

  /// XP of any session, or `null`.
  SessionXp? sessionXp;

  /// Badges returned.
  final List<BadgeUnlockEntity> badges;

  @override
  Future<DataState<StreakEntity>> getStreak({
    required String profileId,
  }) async => DataSuccess<StreakEntity>(streak);

  @override
  Future<DataState<List<BadgeUnlockEntity>>> getBadges({
    required String profileId,
  }) async => DataSuccess<List<BadgeUnlockEntity>>(badges);

  @override
  Future<DataState<int>> getXpEarned({
    required String profileId,
    DateTime? from,
    DateTime? to,
  }) async => DataSuccess<int>(xpEarned);

  @override
  Future<DataState<SessionXp?>> getSessionXp({
    required String sessionId,
  }) async => DataSuccess<SessionXp?>(sessionXp);

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

/// Reward pages over [repository], an empty one by default.
RewardPages buildTestRewardPages({
  RewardRepository? repository,
  Clock? clock,
}) {
  final RewardRepository rewards = repository ?? InMemoryRewardRepository();
  final Clock now = clock ?? FakeClock(quizStart);
  return RewardPages(
    useCases: RewardUseCases(
      getStreak: GetStreakUseCase(repository: rewards, clock: now),
      getDailyGoal: GetDailyGoalUseCase(
        repository: rewards,
        settings: const FixedPlayerSettings(),
        clock: now,
      ),
      getSessionRewards: GetSessionRewardsUseCase(repository: rewards),
      getBadges: GetBadgesUseCase(repository: rewards),
      watchChanges: WatchRewardChangesUseCase(repository: rewards),
    ),
    domains: buildDomainRegistry(),
  );
}
