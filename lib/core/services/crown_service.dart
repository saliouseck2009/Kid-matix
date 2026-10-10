import 'package:kid_matix/core/error/data_state.dart';

/// The crowns of a player, as the mascot sees them.
///
/// Implemented by the learning path feature, which owns the crowns.
abstract interface class CrownService {
  /// Returns how many tables [profileId] has crowned.
  Future<DataState<int>> readCrownCount({required String profileId});

  /// Emits an event each time the crowns may have changed.
  Stream<void> watchChanges();
}
