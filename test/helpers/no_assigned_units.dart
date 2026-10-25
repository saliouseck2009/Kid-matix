import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/assigned_units_service.dart';

/// [AssignedUnitsService] of a player with no class homework.
final class NoAssignedUnits implements AssignedUnitsService {
  /// Creates the service.
  const NoAssignedUnits();

  @override
  Future<DataState<Set<String>>> readAssignedUnitKeys({
    required String profileId,
  }) async {
    return const DataSuccess<Set<String>>(<String>{});
  }
}
