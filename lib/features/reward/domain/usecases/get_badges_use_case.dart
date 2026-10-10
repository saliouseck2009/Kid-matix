import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';

/// Returns the badges of a player, oldest first; takes the profile id.
class GetBadgesUseCase
    implements UseCase<DataState<List<BadgeUnlockEntity>>, String> {
  /// Creates the use case.
  const GetBadgesUseCase({required this._repository});

  final RewardRepository _repository;

  @override
  Future<DataState<List<BadgeUnlockEntity>>> call({required String params}) {
    return _repository.getBadges(profileId: params);
  }
}
