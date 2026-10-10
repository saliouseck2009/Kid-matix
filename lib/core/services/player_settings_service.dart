import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The game settings of a player, read by the features that play.
///
/// Implemented by the profile feature, which owns the settings.
abstract interface class PlayerSettingsService {
  /// Returns how the timer behaves for the player [profileId].
  Future<DataState<TimerMode>> readTimerMode({required String profileId});

  /// Returns whether "Tout débloquer" opens every table of the learning
  /// path for the player [profileId].
  Future<DataState<bool>> readEverythingUnlocked({required String profileId});

  /// Returns the XP the player [profileId] aims to earn each day.
  Future<DataState<int>> readDailyGoalXp({required String profileId});

  /// Returns whether the player [profileId] left the sounds and the
  /// vibrations on.
  Future<DataState<({bool isSoundOn, bool isVibrationOn})>> readFeedback({
    required String profileId,
  });
}
