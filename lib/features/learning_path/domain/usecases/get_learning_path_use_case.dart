import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/services/assigned_units_service.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';

/// Returns the tables, stages, stars, crowns and locks of a player, with
/// the "Tout débloquer" setting, the tables opened by the placement test
/// and the unit of the class's homework applied.
///
/// Fails with a `ValidationException` when the domain is unknown.
class GetLearningPathUseCase
    implements UseCase<DataState<LearningPathEntity>, LearningPathParams> {
  /// Creates the use case.
  const GetLearningPathUseCase({
    required this._repository,
    required this._domains,
    required this._settings,
    required this._mastery,
    this._assigned,
    this._builder = const LearningPathBuilder(),
  });

  final StageProgressRepository _repository;
  final DomainRegistry _domains;
  final PlayerSettingsService _settings;
  final MasteryService _mastery;
  final AssignedUnitsService? _assigned;
  final LearningPathBuilder _builder;

  @override
  Future<DataState<LearningPathEntity>> call({
    required LearningPathParams params,
  }) async {
    final LearningDomain? domain = _domains.find(params.domainId);
    if (domain == null) {
      return const DataFailed<LearningPathEntity>(
        ValidationException(message: 'Unknown domain.'),
      );
    }
    final DataState<bool> unlocked = await _settings.readEverythingUnlocked(
      profileId: params.profileId,
    );
    if (unlocked case DataFailed<bool>(:final exception)) {
      return DataFailed<LearningPathEntity>(exception);
    }
    final DataState<Set<String>> mastered = await _mastery.readMasteredItems(
      profileId: params.profileId,
      domainId: domain.id,
    );
    if (mastered case DataFailed<Set<String>>(:final exception)) {
      return DataFailed<LearningPathEntity>(exception);
    }
    final DataState<Set<String>> placed = await _repository.getPlacedUnitKeys(
      profileId: params.profileId,
      domainId: domain.id,
    );
    if (placed case DataFailed<Set<String>>(:final exception)) {
      return DataFailed<LearningPathEntity>(exception);
    }
    final DataState<Set<String>> assigned = await _readAssigned(params);
    if (assigned case DataFailed<Set<String>>(:final exception)) {
      return DataFailed<LearningPathEntity>(exception);
    }
    final DataState<List<StageProgressEntity>> progress = await _repository
        .getProgress(profileId: params.profileId, domainId: domain.id);
    return switch (progress) {
      DataSuccess<List<StageProgressEntity>>(:final data) =>
        DataSuccess<LearningPathEntity>(
          _builder.build(
            domainId: domain.id,
            units: domain.path,
            progress: data,
            isEverythingUnlocked: (unlocked as DataSuccess<bool>).data,
            masteredItemKeys: (mastered as DataSuccess<Set<String>>).data,
            // A homework opens its unit like the placement test does.
            placedUnitKeys: <String>{
              ...(placed as DataSuccess<Set<String>>).data,
              ...(assigned as DataSuccess<Set<String>>).data,
            },
          ),
        ),
      DataFailed<List<StageProgressEntity>>(:final exception) =>
        DataFailed<LearningPathEntity>(exception),
    };
  }

  Future<DataState<Set<String>>> _readAssigned(LearningPathParams params) {
    final AssignedUnitsService? assigned = _assigned;
    if (assigned == null) {
      return Future<DataState<Set<String>>>.value(
        const DataSuccess<Set<String>>(<String>{}),
      );
    }
    return assigned.readAssignedUnitKeys(profileId: params.profileId);
  }
}
