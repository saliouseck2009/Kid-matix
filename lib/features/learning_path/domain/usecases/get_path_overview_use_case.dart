import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';

/// Returns « Mes parcours » of a player: the progress in every domain of
/// the app, read from the same path as the map, and the domain their
/// latest placement test recommended while it is not finished.
///
/// Fails when the path of a domain cannot be read; a placement history
/// that cannot be read only leaves the recommendation out.
class GetPathOverviewUseCase
    implements UseCase<DataState<PathOverviewEntity>, String> {
  /// Creates the use case.
  const GetPathOverviewUseCase({
    required this._getLearningPath,
    required this._placements,
    required this._domains,
  });

  final GetLearningPathUseCase _getLearningPath;
  final PlacementResultRepository _placements;
  final DomainRegistry _domains;

  /// Returns the overview of the player [params].
  @override
  Future<DataState<PathOverviewEntity>> call({required String params}) async {
    final List<DomainProgressEntity> domains = <DomainProgressEntity>[];
    for (final LearningDomain domain in _domains.domains) {
      final DataState<LearningPathEntity> path = await _getLearningPath(
        params: LearningPathParams(profileId: params, domainId: domain.id),
      );
      switch (path) {
        case DataSuccess<LearningPathEntity>(:final data):
          domains.add(DomainProgressEntity.fromPath(data));
        case DataFailed<LearningPathEntity>(:final exception):
          return DataFailed<PathOverviewEntity>(exception);
      }
    }
    final String? recommended = await _recommendedDomainId(params);
    final bool isOpen = domains.any(
      (DomainProgressEntity domain) =>
          domain.domainId == recommended && !domain.isFinished,
    );
    return DataSuccess<PathOverviewEntity>(
      PathOverviewEntity(
        domains: domains,
        recommendedDomainId: isOpen ? recommended : null,
      ),
    );
  }

  Future<String?> _recommendedDomainId(String profileId) async {
    final DataState<List<PlacementResultEntity>> history = await _placements
        .getHistory(profileId: profileId);
    if (history is! DataSuccess<List<PlacementResultEntity>> ||
        history.data.isEmpty) {
      return null;
    }
    return history.data.first.recommended?.domainId;
  }
}
