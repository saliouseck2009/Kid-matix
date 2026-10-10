import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_stats_entity.dart';

/// The streak, crowns and badges of a player, read from the rewards and
/// the learning path; takes the profile id.
class GetProfileStatsUseCase
    implements UseCase<DataState<ProfileStatsEntity>, String> {
  /// Creates the use case.
  const GetProfileStatsUseCase({
    required this._rewards,
    required this._crowns,
  });

  final RewardService _rewards;
  final CrownService _crowns;

  @override
  Future<DataState<ProfileStatsEntity>> call({required String params}) async {
    final DataState<int> streak = await _rewards.readStreak(profileId: params);
    final DataState<int> crowns = await _crowns.readCrownCount(
      profileId: params,
    );
    final DataState<Set<String>> badges = await _rewards.readBadgeKeys(
      profileId: params,
    );
    return switch ((streak, crowns, badges)) {
      (
        DataSuccess<int>(data: final int days),
        DataSuccess<int>(data: final int crownCount),
        DataSuccess<Set<String>>(data: final Set<String> keys),
      ) =>
        DataSuccess<ProfileStatsEntity>(
          ProfileStatsEntity(
            streak: days,
            crownCount: crownCount,
            badgeCount: keys.length,
          ),
        ),
      (DataFailed<int>(:final exception), _, _) ||
      (_, DataFailed<int>(:final exception), _) ||
      (
        _,
        _,
        DataFailed<Set<String>>(:final exception),
      ) => DataFailed<ProfileStatsEntity>(exception),
    };
  }
}
