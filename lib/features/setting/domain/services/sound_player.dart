import 'package:kid_matix/core/entities/game_feedback.dart';

/// Plays the sound of a moment of the game.
abstract interface class SoundPlayer {
  /// Plays the sound of [feedback].
  Future<void> play(GameFeedback feedback);
}
