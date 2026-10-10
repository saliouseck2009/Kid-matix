import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';

/// [OpenUnitsService] over the learning path of [domainId].
final class OpenUnitsServiceImpl implements OpenUnitsService {
  /// Creates the service.
  const OpenUnitsServiceImpl({
    required this._getPath,
    required this._domainId,
  });

  final GetLearningPathUseCase _getPath;
  final String _domainId;

  @override
  Future<DataState<List<String>>> readOpenUnitKeys({
    required String profileId,
  }) async {
    final DataState<LearningPathEntity> path = await _getPath(
      params: LearningPathParams(profileId: profileId, domainId: _domainId),
    );
    return switch (path) {
      DataSuccess<LearningPathEntity>(:final data) => DataSuccess<List<String>>(
        <String>[
          for (final TablePathNode table in data.tables)
            if (table.status != TableStatus.locked) table.unitKey,
        ],
      ),
      DataFailed<LearningPathEntity>(:final exception) =>
        DataFailed<List<String>>(exception),
    };
  }
}
