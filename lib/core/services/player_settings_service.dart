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

  /// Returns whether the player [profileId] asked for every new question
  /// to be read aloud by itself ("Lire les questions à voix haute"). Off by
  /// default; a reading can always be asked for with the listen button.
  Future<DataState<bool>> readReadAloudEnabled({required String profileId});

  /// Returns the language of the recorded help the player [profileId]
  /// chose for the math words ("Aide audio"): the code of an audio pack,
  /// or `HelpAudio.none`.
  Future<DataState<String>> readHelpAudioLanguage({required String profileId});
}
