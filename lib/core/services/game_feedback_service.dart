import 'package:kid_matix/core/entities/game_feedback.dart';

/// Plays the sounds and vibrations of the game, as the active player
/// chose in their settings.
///
/// Implemented by the setting feature; a failure is never shown, the game
/// simply goes on silently.
abstract interface class GameFeedbackService {
  /// Marks [feedback] with its sound and vibration, each only when the
  /// active player left it on.
  Future<void> play(GameFeedback feedback);
}
