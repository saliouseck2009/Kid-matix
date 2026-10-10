import 'package:kid_matix/core/error/data_state.dart';

/// The level, the streak and the badges of a player, as the mascot and
/// the profile see them.
///
/// Implemented by the reward feature, which owns them.
abstract interface class RewardService {
  /// Returns the level of [profileId].
  Future<DataState<int>> readLevel({required String profileId});

  /// Returns the days in a row [profileId] has played, as shown today.
  Future<DataState<int>> readStreak({required String profileId});

  /// Returns the keys of the badges [profileId] has unlocked.
  Future<DataState<Set<String>>> readBadgeKeys({required String profileId});

  /// Emits an event each time the rewards may have changed.
  Stream<void> watchChanges();
}
