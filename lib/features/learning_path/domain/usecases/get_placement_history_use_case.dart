import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';

/// Returns the placement tests of a player, the latest first.
class GetPlacementHistoryUseCase
    implements UseCase<DataState<List<PlacementResultEntity>>, String> {
  /// Creates the use case.
  const GetPlacementHistoryUseCase({required this._repository});

  final PlacementResultRepository _repository;

  /// Returns the tests of the player [params].
  @override
  Future<DataState<List<PlacementResultEntity>>> call({
    required String params,
  }) {
    return _repository.getHistory(profileId: params);
  }
}
