import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';

/// Returns every XP a player has earned, in quizzes and duels; takes the
/// profile id.
class GetTotalXpUseCase implements UseCase<DataState<int>, String> {
  /// Creates the use case.
  const GetTotalXpUseCase({required this._repository});

  final RewardRepository _repository;

  @override
  Future<DataState<int>> call({required String params}) {
    return _repository.getXpEarned(profileId: params);
  }
}
