import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The game settings of a player, read by the features that play.
///
/// Implemented by the profile feature, which owns the settings.
abstract interface class PlayerSettingsService {
  /// Returns how the timer behaves for the player [profileId].
  Future<DataState<TimerMode>> readTimerMode({required String profileId});
}
