import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:meta/meta.dart';

/// What the audio pack of one help language holds: for each word key, the
/// file of its explanation and the file of its example, when they exist.
///
/// Read from `assets/audio/<language>/manifest.json`, written by
/// `tool/process_audio.py`:
///
/// ```json
/// {"language": "wo", "format": "m4a",
///  "words": {"il_reste": {"explanation": "wo_il_reste.m4a",
///                         "example": "wo_il_reste_exemple.m4a"}}}
/// ```
@immutable
final class AudioPackManifest {
  /// Creates the manifest of [language] holding [files].
  AudioPackManifest({
    required this.language,
    required Map<String, Map<WordAudioKind, String>> files,
  }) : _files = <String, Map<WordAudioKind, String>>{
         for (final MapEntry<String, Map<WordAudioKind, String>> entry
             in files.entries)
           entry.key: Map<WordAudioKind, String>.unmodifiable(entry.value),
       };

  /// Reads a decoded manifest; throws a [FormatException] when its shape
  /// is wrong, so a broken pack is skipped instead of crashing the app.
  factory AudioPackManifest.fromJson(Map<String, Object?> json) {
    final Object? language = json['language'];
    final Object? words = json['words'];
    if (language is! String || language.isEmpty || words is! Map) {
      throw const FormatException('Not an audio pack manifest');
    }
    final Map<String, Map<WordAudioKind, String>> files =
        <String, Map<WordAudioKind, String>>{};
    for (final MapEntry<Object?, Object?> word in words.entries) {
      final Object? key = word.key;
      final Object? entry = word.value;
      if (key is! String || entry is! Map) {
        throw const FormatException('Bad word in the audio pack manifest');
      }
      final Map<WordAudioKind, String> kinds = <WordAudioKind, String>{};
      for (final WordAudioKind kind in WordAudioKind.values) {
        final Object? file = entry[kind.name];
        if (file == null) continue;
        if (file is! String || file.isEmpty) {
          throw const FormatException('Bad file in the audio pack manifest');
        }
        kinds[kind] = file;
      }
      if (kinds.isNotEmpty) files[key] = kinds;
    }
    return AudioPackManifest(language: language, files: files);
  }

  /// Code of the help language, such as `wo`.
  final String language;

  final Map<String, Map<WordAudioKind, String>> _files;

  /// Keys of the words that have at least one recording.
  Iterable<String> get wordKeys => _files.keys;

  /// Name of the file of the recording [kind] of [wordKey], or `null` when
  /// the pack has none.
  String? fileOf(String wordKey, WordAudioKind kind) => _files[wordKey]?[kind];
}
