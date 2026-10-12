import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_visibility_repository.dart';

/// Returns whether the leaderboard is shown on this phone.
class GetLeaderboardVisibilityUseCase
    implements NoParamUseCase<DataState<bool>> {
  /// Creates the use case over [repository].
  const GetLeaderboardVisibilityUseCase({required this._repository});

  final LeaderboardVisibilityRepository _repository;

  @override
  Future<DataState<bool>> call() => _repository.isShown();
}
