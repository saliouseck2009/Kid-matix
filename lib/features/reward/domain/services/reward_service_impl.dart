import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_badges_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_player_level_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';

/// [RewardService] over the use cases of the reward feature.
final class RewardServiceImpl implements RewardService {
  /// Creates the service.
  const RewardServiceImpl({
    required this._getLevel,
    required this._getBadges,
    required this._watchChanges,
  });

  final GetPlayerLevelUseCase _getLevel;
  final GetBadgesUseCase _getBadges;
  final WatchRewardChangesUseCase _watchChanges;

  @override
  Future<DataState<int>> readLevel({required String profileId}) async {
    return switch (await _getLevel(params: profileId)) {
      DataSuccess<PlayerLevel>(:final data) => DataSuccess<int>(data.level),
      DataFailed<PlayerLevel>(:final exception) => DataFailed<int>(exception),
    };
  }

  @override
  Future<DataState<Set<String>>> readBadgeKeys({
    required String profileId,
  }) async {
    return switch (await _getBadges(params: profileId)) {
      DataSuccess<List<BadgeUnlockEntity>>(:final data) =>
        DataSuccess<Set<String>>(<String>{
          for (final BadgeUnlockEntity badge in data) badge.badgeKey,
        }),
      DataFailed<List<BadgeUnlockEntity>>(:final exception) =>
        DataFailed<Set<String>>(exception),
    };
  }

  @override
  Stream<void> watchChanges() => _watchChanges();
}
