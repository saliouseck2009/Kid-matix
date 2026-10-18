import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';

/// Reads the audio packs bundled with the app.
///
/// `assets/audio/packs.json` lists the languages (`{"languages": ["wo"]}`);
/// each one has its manifest in `assets/audio/<language>/manifest.json`.
/// Nothing here names a language. A missing index or a broken manifest
/// gives no pack, never an error: the buttons that depend on it simply do
/// not show.
final class AudioPackLoader {
  /// Creates the loader over [bundle].
  const AudioPackLoader({required this._bundle});

  /// Path of the list of languages.
  static const String indexAsset = 'assets/audio/packs.json';

  static const String _logName = 'math_word';

  final AssetBundle _bundle;

  /// Returns the manifest of every pack that can be read, in the order of
  /// the index.
  Future<List<AudioPackManifest>> load() async {
    final List<String> languages = await _readLanguages();
    final List<AudioPackManifest> packs = <AudioPackManifest>[];
    for (final String language in languages) {
      try {
        final Object? json = jsonDecode(
          await _bundle.loadString('assets/audio/$language/manifest.json'),
        );
        if (json is! Map<String, Object?>) {
          throw const FormatException('Not an object');
        }
        packs.add(AudioPackManifest.fromJson(json));
      } on Object catch (error, stackTrace) {
        log(
          'Audio pack skipped: $language',
          name: _logName,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return packs;
  }

  Future<List<String>> _readLanguages() async {
    try {
      final Object? json = jsonDecode(await _bundle.loadString(indexAsset));
      if (json is Map<String, Object?> && json['languages'] is List) {
        return (json['languages']! as List<Object?>)
            .whereType<String>()
            .toList();
      }
    } on Object catch (error, stackTrace) {
      log(
        'No audio pack index',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
    return const <String>[];
  }
}
