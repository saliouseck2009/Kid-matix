import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/services/level_policy.dart';

/// Returns the level of a player from all their XP; takes the profile id.
class GetPlayerLevelUseCase implements UseCase<DataState<PlayerLevel>, String> {
  /// Creates the use case.
  const GetPlayerLevelUseCase({
    required this._repository,
    this._policy = const LevelPolicy(),
  });

  final RewardRepository _repository;
  final LevelPolicy _policy;

  @override
  Future<DataState<PlayerLevel>> call({required String params}) async {
    return switch (await _repository.getXpEarned(profileId: params)) {
      DataSuccess<int>(:final data) => DataSuccess<PlayerLevel>(
        _policy.levelOf(data),
      ),
      DataFailed<int>(:final exception) => DataFailed<PlayerLevel>(exception),
    };
  }
}
