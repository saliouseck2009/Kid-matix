import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_learning_path_changes_use_case.dart';

/// [CrownService] over the learning path of [domainId].
final class CrownServiceImpl implements CrownService {
  /// Creates the service.
  const CrownServiceImpl({
    required this._getPath,
    required this._watchChanges,
    required this._domainId,
  });

  final GetLearningPathUseCase _getPath;
  final WatchLearningPathChangesUseCase _watchChanges;
  final String _domainId;

  @override
  Future<DataState<int>> readCrownCount({required String profileId}) async {
    final DataState<LearningPathEntity> path = await _getPath(
      params: LearningPathParams(profileId: profileId, domainId: _domainId),
    );
    return switch (path) {
      DataSuccess<LearningPathEntity>(:final data) => DataSuccess<int>(
        data.defeatedBosses.length,
      ),
      DataFailed<LearningPathEntity>(:final exception) => DataFailed<int>(
        exception,
      ),
    };
  }

  @override
  Stream<void> watchChanges() => _watchChanges();
}
