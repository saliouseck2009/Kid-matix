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

  /// Reads [text] aloud in [languageCode].
  ///
  /// A reading in progress is stopped first. The future completes when the
  /// reading ends, is stopped, or could not start; it never throws, so a
  /// caller can wait for it to hold something back until the voice is
  /// done, such as a timer.
  Future<void> speak({required String text, required String languageCode});

  /// Stops the reading in progress, if any.
  Future<void> stop();
}
