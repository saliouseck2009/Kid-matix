import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:meta/meta.dart';

/// A recording a teacher makes: one kind of one word in one language.
typedef RecordingTarget = ({
  String languageCode,
  String wordKey,
  WordAudioKind kind,
});

/// One math word on the page of the teacher's recordings.
@immutable
final class RecordingWord {
  /// Creates the line of [itemKey].
  const RecordingWord({
    required this.itemKey,
    required this.wordKey,
    required this.hasPackAudio,
    required this.hasTeacherAudio,
  });

  /// Item of the math words, such as `word:il_reste`.
  final String itemKey;

  /// Key of its recordings, such as `il_reste`.
  final String wordKey;

  /// Whether the bundled pack holds its recording.
  final bool hasPackAudio;

  /// Whether the teacher recorded it on this device.
  final bool hasTeacherAudio;
}

/// The page of the teacher's recordings (F31-06): the help languages, the
/// one chosen, the kind of recording, and each word with what exists.
@immutable
final class TeacherRecordings {
  /// Creates the page in [languageCode].
  TeacherRecordings({
    required List<String> languages,
    required this.languageCode,
    required this.kind,
    required List<RecordingWord> words,
    this.isProvisional = false,
  }) : languages = List<String>.unmodifiable(languages),
       words = List<RecordingWord>.unmodifiable(words);

  /// The help languages of the app.
  final List<String> languages;

  /// The language recorded, or `null` when the app has no pack.
  final String? languageCode;

  /// The explanation or the example.
  final WordAudioKind kind;

  /// Each math word, in the order of the families.
  final List<RecordingWord> words;

  /// Whether the pack of [languageCode] is made of machine-made stand-ins,
  /// to be replaced by real recordings.
  final bool isProvisional;
}
