import 'package:kid_matix/core/entities/placement_level.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The dated placement results of the players, as the level groups of
/// the class mode read them.
///
/// To be implemented by the placement test by skill (lot F27), which
/// owns the results; until then [NoPlacementResultService] answers that
/// nobody was placed.
abstract interface class PlacementResultService {
  /// Returns the last placement of [profileId] in [domainId], or `null`
  /// when they never took the test there.
  Future<DataState<PlacementLevel?>> readLatestLevel({
    required String profileId,
    required String domainId,
  });
}

/// [PlacementResultService] of an app without dated placement results.
final class NoPlacementResultService implements PlacementResultService {
  /// Creates the service.
  const NoPlacementResultService();

  @override
  Future<DataState<PlacementLevel?>> readLatestLevel({
    required String profileId,
    required String domainId,
  }) async {
    return const DataSuccess<PlacementLevel?>(null);
  }
}
