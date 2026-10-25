import 'package:kid_matix/core/entities/placement_level.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/placement_result_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';

/// [PlacementResultService] over the dated placement results (F27): the
/// latest test that checked the domain gives the level; a domain the
/// test stopped before (`level` NULL) counts as not placed.
final class PlacementResultServiceImpl implements PlacementResultService {
  /// Creates the service over [results].
  const PlacementResultServiceImpl({required this._results});

  final PlacementResultRepository _results;

  @override
  Future<DataState<PlacementLevel?>> readLatestLevel({
    required String profileId,
    required String domainId,
  }) async {
    return switch (await _results.getHistory(profileId: profileId)) {
      DataFailed<List<PlacementResultEntity>>(:final exception) =>
        DataFailed<PlacementLevel?>(exception),
      DataSuccess<List<PlacementResultEntity>>(:final data) =>
        DataSuccess<PlacementLevel?>(_latestOf(data, domainId)),
    };
  }

  /// The level of the first test of [history] (latest first) that
  /// checked [domainId].
  static PlacementLevel? _latestOf(
    List<PlacementResultEntity> history,
    String domainId,
  ) {
    for (final PlacementResultEntity test in history) {
      final DomainResultEntity? result = test.domainOf(domainId);
      if (result == null) continue;
      final int? level = result.level;
      if (level == null) return null;
      return PlacementLevel(
        level: level,
        skillCount: result.skillCount,
        takenAt: test.takenAt,
      );
    }
    return null;
  }
}
