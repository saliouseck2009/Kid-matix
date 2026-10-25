/// Plays one recorded file at a time.
///
/// Implemented over the audio player of the app; faked in tests.
abstract interface class WordAudioPlayer {
  /// Plays the bundled file [assetPath] (relative to `assets/`, such as
  /// `audio/wo/wo_il_reste.m4a`). Completes when the sound ends, is stopped
  /// or could not play; never throws.
  Future<void> play(String assetPath);

  /// Plays the device file [path], such as a teacher's recording. Same
  /// contract as [play].
  Future<void> playFile(String path);

  /// Stops the sound in progress, if any.
  Future<void> stop();
}
