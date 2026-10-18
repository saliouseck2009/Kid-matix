import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_learning_path_changes_use_case.dart';

/// [CrownService] over the learning paths of every domain.
///
/// The crowns are kept per domain, but the mascot and the coins that read
/// them are global to the player, like the XP: they count every crown.
final class CrownServiceImpl implements CrownService {
  /// Creates the service.
  const CrownServiceImpl({
    required this._getPath,
    required this._watchChanges,
    required this._domains,
  });

  final GetLearningPathUseCase _getPath;
  final WatchLearningPathChangesUseCase _watchChanges;
  final DomainRegistry _domains;

  @override
  Future<DataState<int>> readCrownCount({required String profileId}) async {
    int total = 0;
    for (final LearningDomain domain in _domains.domains) {
      final DataState<LearningPathEntity> path = await _getPath(
        params: LearningPathParams(profileId: profileId, domainId: domain.id),
      );
      switch (path) {
        case DataSuccess<LearningPathEntity>(:final data):
          total += data.defeatedBosses.length;
        case DataFailed<LearningPathEntity>(:final exception):
          return DataFailed<int>(exception);
      }
    }
    return DataSuccess<int>(total);
  }

  @override
  Stream<void> watchChanges() => _watchChanges();
}
