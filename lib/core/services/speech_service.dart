import 'package:kid_matix/core/services/speech_reading.dart';

/// Reads texts aloud with a voice installed on the phone.
///
/// Implemented by the speech feature over the system's speech synthesis,
/// so the questions the app draws at random (they change on every game)
/// can be read without any recording. A failure is never shown: the
/// reading simply does not happen, and a phone without a voice plays
/// silently.
abstract interface class SpeechService {
  /// Returns whether a voice that works without a network is installed for
  /// [languageCode] (`fr`, `en` or `es`).
  ///
  /// The screens hide their listen button when it is `false`.
  Future<bool> isAvailable({required String languageCode});

  /// Forgets that a language had no voice, so the next [isAvailable] asks
  /// the phone again: a parent who installs the voice in the settings and
  /// comes back to the app needs no restart.
  void forgetMissingVoices();

  /// Reads [text] aloud in [languageCode].
  ///
  /// A reading in progress is stopped first. The future completes when the
  /// reading ends, is stopped, or could not start; it never throws, so a
  /// caller can wait for it to hold something back until the voice is
  /// done, such as a timer. The returned [SpeechReading] completes with the
  /// reading and identifies it: give it to [stop] to stop this reading and
  /// no other. A blank text stops the reading in progress and says nothing.
  SpeechReading speak({required String text, required String languageCode});

  /// Stops the reading in progress, if any.
  ///
  /// With the [SpeechReading] [speak] returned for a reading, stops only if
  /// that reading is still the newest: a screen that goes away, or a reading
  /// that outlived its question, cannot cut the reading that replaced it.
  Future<void> stop({SpeechReading? reading});
}
