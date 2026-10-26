import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/services/speech_reading.dart';

/// Plays the recorded help of the math words in a help language, such as
/// the explanation of "il reste" in Wolof.
///
/// Implemented by the math word feature over the audio packs bundled with
/// the app (`assets/audio/<language>/`). The code depends on no language in
/// particular: a language is the code of a pack. A word without recording
/// has no audio, and the screens then show no button for it.
abstract interface class WordAudioService {
  /// Codes of the help languages whose pack holds at least one recording;
  /// a pack with none yet is not offered.
  List<String> get languages;

  /// The language of a player who never chose: the first pack of the
  /// index, or `null` when the app ships none.
  String? get defaultLanguage;

  /// Whether the pack of [languageCode] holds machine-made stand-ins
  /// (`"provisional": true` in its manifest) instead of real recordings.
  /// Screens for the teacher and the « Aide audio » setting then say so.
  bool isProvisional(String languageCode);

  /// Whether the pack of [languageCode] holds the recording [kind] of the
  /// word [wordKey].
  bool hasAudio({
    required String languageCode,
    required String wordKey,
    WordAudioKind kind = WordAudioKind.explanation,
  });

  /// Plays the recording [kind] of [wordKey] in [languageCode]; a playing
  /// one is stopped first. The reading completes when the sound ends, is
  /// stopped or could not play; it never throws. A recording that does not
  /// exist plays nothing and is over at once.
  SpeechReading play({
    required String languageCode,
    required String wordKey,
    WordAudioKind kind = WordAudioKind.explanation,
  });

  /// Stops the sound in progress; with [reading], only if it is still the
  /// newest one.
  Future<void> stop({SpeechReading? reading});
}
