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
///
/// The recordings that are machine-made stand-ins are listed by file name
/// in `"provisional": ["wo_il_reste.m4a", ...]` (absent or empty means none
/// is); while the list is not empty the pack is provisional: the teacher
/// area and the « Aide audio » setting say so, and a child who never chose
/// a help language does not get it by default.
@immutable
final class AudioPackManifest {
  /// Creates the manifest of [language] holding [files].
  AudioPackManifest({
    required this.language,
    required Map<String, Map<WordAudioKind, String>> files,
    Set<String> provisionalFiles = const <String>{},
  }) : provisionalFiles = Set<String>.unmodifiable(provisionalFiles),
       _files = <String, Map<WordAudioKind, String>>{
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
    final Object? provisional = json['provisional'];
    if (provisional != null &&
        (provisional is! List ||
            provisional.any((Object? f) => f is! String))) {
      throw const FormatException('Bad provisional list in the manifest');
    }
    return AudioPackManifest(
      language: language,
      files: files,
      provisionalFiles: <String>{
        if (provisional is List) ...provisional.cast<String>(),
      },
    );
  }

  /// Code of the help language, such as `wo`.
  final String language;

  /// Names of the recordings that are machine-made stand-ins, to be
  /// replaced by real ones before any release.
  final Set<String> provisionalFiles;

  /// Whether the pack holds at least one stand-in.
  bool get isProvisional => provisionalFiles.isNotEmpty;

  final Map<String, Map<WordAudioKind, String>> _files;

  /// Keys of the words that have at least one recording.
  Iterable<String> get wordKeys => _files.keys;

  /// Name of the file of the recording [kind] of [wordKey], or `null` when
  /// the pack has none.
  String? fileOf(String wordKey, WordAudioKind kind) => _files[wordKey]?[kind];

  /// Format of the recordings of every pack.
  static const String format = 'm4a';

  /// The name of the recording [kind] of [wordKey] in a pack of
  /// [language], as `tool/process_audio.py` names it: `wo_il_reste.m4a`,
  /// `wo_il_reste_exemple.m4a`.
  static String fileNameOf(
    String language,
    String wordKey,
    WordAudioKind kind,
  ) {
    final String end = kind == WordAudioKind.example ? '_exemple' : '';
    return '${language}_$wordKey$end.$format';
  }

  /// The manifest with [file] as the recording [kind] of [wordKey].
  AudioPackManifest withFile(String wordKey, WordAudioKind kind, String file) {
    return AudioPackManifest(
      language: language,
      provisionalFiles: provisionalFiles,
      files: <String, Map<WordAudioKind, String>>{
        ..._files,
        wordKey: <WordAudioKind, String>{...?_files[wordKey], kind: file},
      },
    );
  }

  /// The manifest without the recording [kind] of [wordKey].
  AudioPackManifest withoutFile(String wordKey, WordAudioKind kind) {
    return AudioPackManifest(
      language: language,
      provisionalFiles: provisionalFiles,
      files: <String, Map<WordAudioKind, String>>{
        for (final MapEntry<String, Map<WordAudioKind, String>> entry
            in _files.entries)
          entry.key: <WordAudioKind, String>{
            for (final MapEntry<WordAudioKind, String> file
                in entry.value.entries)
              if (entry.key != wordKey || file.key != kind)
                file.key: file.value,
          },
      },
    );
  }

  /// The manifest as `manifest.json` holds it.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'language': language,
      'format': format,
      if (isProvisional) 'provisional': provisionalFiles.toList()..sort(),
      'words': <String, Object?>{
        for (final MapEntry<String, Map<WordAudioKind, String>> entry
            in _files.entries)
          if (entry.value.isNotEmpty)
            entry.key: <String, String>{
              for (final MapEntry<WordAudioKind, String> file
                  in entry.value.entries)
                file.key.name: file.value,
            },
      },
    };
  }

  /// Every file the manifest names.
  Iterable<String> get fileNames => _files.values.expand(
    (Map<WordAudioKind, String> kinds) => kinds.values,
  );
}
