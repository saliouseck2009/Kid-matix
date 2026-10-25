import 'package:kid_matix/core/error/data_state.dart';

/// The units a player must work on as « Le devoir de la classe », as the
/// learning path opens them.
///
/// Implemented by the class mode. Owner (2026-10-20): a homework opens
/// its unit for the pupils of the class even beyond their path; its stars
/// are still to win.
abstract interface class AssignedUnitsService {
  /// Returns the keys of the units ever assigned to the class of
  /// [profileId], none for a free player.
  Future<DataState<Set<String>>> readAssignedUnitKeys({
    required String profileId,
  });
}
