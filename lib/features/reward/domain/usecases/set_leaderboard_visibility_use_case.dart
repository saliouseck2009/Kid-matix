import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_visibility_repository.dart';

/// Shows or hides the leaderboard for every player of the phone; takes
/// whether it is shown.
class SetLeaderboardVisibilityUseCase
    implements UseCase<DataState<void>, bool> {
  /// Creates the use case over [repository].
  const SetLeaderboardVisibilityUseCase({required this._repository});

  final LeaderboardVisibilityRepository _repository;

  @override
  Future<DataState<void>> call({required bool params}) {
    return _repository.setShown(isShown: params);
  }
}
