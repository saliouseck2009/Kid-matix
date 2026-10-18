/// The speech synthesis of the phone, behind the one call the app needs.
///
/// The data layer implements it over the plugin; the domain tests use a
/// fake one.
abstract interface class TextToSpeechEngine {
  /// Returns whether an installed voice that needs no network speaks
  /// [languageCode] (`fr`, `en` or `es`).
  Future<bool> hasVoice({required String languageCode});

  /// Speaks [text] with a voice of [languageCode], after stopping the
  /// reading in progress. Completes when the voice ends, is stopped or
  /// fails; does nothing without a voice.
  Future<void> speak({required String text, required String languageCode});

  /// Stops the reading in progress and completes once it has stopped.
  Future<void> stop();
}
