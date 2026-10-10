import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/services/level_policy.dart';

/// Returns what a quiz brought: its XP, the level before and after it,
/// and the badges it unlocked; takes the session id. A quiz without
/// reward, abandoned, brings nothing.
class GetSessionRewardsUseCase
    implements UseCase<DataState<SessionRewardsEntity?>, String> {
  /// Creates the use case.
  const GetSessionRewardsUseCase({
    required this._repository,
    this._levels = const LevelPolicy(),
  });

  final RewardRepository _repository;
  final LevelPolicy _levels;

  @override
  Future<DataState<SessionRewardsEntity?>> call({
    required String params,
  }) async {
    final DataState<SessionXp?> session = await _repository.getSessionXp(
      sessionId: params,
    );
    if (session is! DataSuccess<SessionXp?>) {
      return DataFailed<SessionRewardsEntity?>(
        (session as DataFailed<SessionXp?>).exception,
      );
    }
    final SessionXp? reward = session.data;
    if (reward == null) return const DataSuccess<SessionRewardsEntity?>(null);
    final DataState<int> totalAfter = await _repository.getXpEarned(
      profileId: reward.profileId,
      to: reward.earnedAt.add(const Duration(milliseconds: 1)),
    );
    final DataState<List<BadgeUnlockEntity>> badges = await _repository
        .getBadges(profileId: reward.profileId);
    if (totalAfter case DataFailed<int>(:final exception)) {
      return DataFailed<SessionRewardsEntity?>(exception);
    }
    if (badges case DataFailed<List<BadgeUnlockEntity>>(:final exception)) {
      return DataFailed<SessionRewardsEntity?>(exception);
    }
    final int after = (totalAfter as DataSuccess<int>).data;
    return DataSuccess<SessionRewardsEntity?>(
      SessionRewardsEntity(
        xpEarned: reward.xp,
        levelBefore: _levels.levelOf(after - reward.xp),
        levelAfter: _levels.levelOf(after),
        newBadges: <String>[
          for (final BadgeUnlockEntity badge
              in (badges as DataSuccess<List<BadgeUnlockEntity>>).data)
            if (badge.sessionId == params) badge.badgeKey,
        ],
      ),
    );
  }
}
