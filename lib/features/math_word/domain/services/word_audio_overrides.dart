import 'package:kid_matix/core/entities/word_audio_kind.dart';

/// The recordings a teacher made on this device (F31-06), laid over the
/// bundled packs: a word recorded here plays this file instead of the
/// pack's.
abstract interface class WordAudioOverrides {
  /// Languages with at least one recording on this device.
  Iterable<String> get languages;

  /// Path of the recording [kind] of [wordKey] in [language] on this
  /// device, or `null` when the teacher recorded none.
  String? pathOf(String language, String wordKey, WordAudioKind kind);
}

/// No recording on the device.
final class NoWordAudioOverrides implements WordAudioOverrides {
  /// Creates the empty layer.
  const NoWordAudioOverrides();

  @override
  Iterable<String> get languages => const <String>[];

  @override
  String? pathOf(String language, String wordKey, WordAudioKind kind) => null;
}
