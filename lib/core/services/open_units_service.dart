import 'package:kid_matix/core/error/data_state.dart';

/// The units a player has opened on the learning path, as the challenges
/// see them.
///
/// Implemented by the learning path feature, which owns the unlocking.
abstract interface class OpenUnitsService {
  /// Returns the keys of the units [profileId] can play, in path order;
  /// the first unit is always open.
  Future<DataState<List<String>>> readOpenUnitKeys({required String profileId});
}
