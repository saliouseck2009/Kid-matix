import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/path_domain_repository.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:meta/meta.dart';

/// A finished placement test to keep.
@immutable
final class SavePlacementResultParams {
  /// Creates the parameters.
  const SavePlacementResultParams({
    required this.profileId,
    required this.outcome,
  });

  /// Player who took the test.
  final String profileId;

  /// What the test found.
  final PlacementOutcome outcome;
}

/// Keeps the result of a finished placement test with its date, opens the
/// unit it recommends starting with (the path would keep it locked behind
/// units without stars) and shows the domain it recommends on the home:
/// the map opens on it.
///
/// A test left midway is not kept; the units it opened already stay open.
/// When the domain cannot be chosen, the result is kept all the same.
class SavePlacementResultUseCase
    implements UseCase<DataState<void>, SavePlacementResultParams> {
  /// Creates the use case.
  const SavePlacementResultUseCase({
    required this._results,
    required this._stages,
    required this._domains,
  });

  final PlacementResultRepository _results;
  final StageProgressRepository _stages;
  final PathDomainRepository _domains;

  @override
  Future<DataState<void>> call({
    required SavePlacementResultParams params,
  }) async {
    final String? startDomainId = params.outcome.recommendedDomainId;
    final String? startUnitKey = params.outcome.recommendedUnitKey;
    if (startDomainId != null && startUnitKey != null) {
      final DataState<void> opened = await _stages.openUnit(
        profileId: params.profileId,
        domainId: startDomainId,
        unitKey: startUnitKey,
      );
      if (opened is DataFailed<void>) return opened;
    }
    final DataState<void> saved = await _results.save(
      profileId: params.profileId,
      outcome: params.outcome,
    );
    if (saved is DataFailed<void>) return saved;
    if (startDomainId != null) {
      await _domains.saveDomain(
        profileId: params.profileId,
        domainId: startDomainId,
      );
    }
    return saved;
  }
}
