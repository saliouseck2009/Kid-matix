import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/core/entities/placement_level.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The dated placement results of the players, as the level groups and
/// the assessments of the class mode read them.
///
/// Implemented by the learning path, which owns the dated results of the
/// placement test by skill (lot F27).
abstract interface class PlacementResultService {
  /// Returns the last placement of [profileId] in [domainId], or `null`
  /// when they never took the test there.
  Future<DataState<PlacementLevel?>> readLatestLevel({
    required String profileId,
    required String domainId,
  });

  /// Returns the levels of the latest test [profileId] finished at or
  /// after [since], one per domain of the test, or `null` when they
  /// finished none since then.
  Future<DataState<List<DomainPlacement>?>> readTestTakenSince({
    required String profileId,
    required DateTime since,
  });
}
