import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/math_word/data/datasources/audio_pack_zip.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_overrides.dart';

/// The teacher's recordings on this device (F31-06), laid out like the
/// bundled packs: `<root>/<language>/manifest.json` and its `.m4a` files,
/// in the app's private storage. The bundled assets never change.
///
/// [load] reads the manifests once, in the background at start; until
/// then, and when the storage cannot be read, there is no recording.
final class TeacherAudioStore implements WordAudioOverrides {
  /// Creates the store in the folder [root] gives.
  TeacherAudioStore({required this._root});

  static const String _manifestName = AudioPackZip.manifestName;
  static const String _logName = 'math_word';

  final Future<Directory> Function() _root;
  final Map<String, AudioPackManifest> _manifests =
      <String, AudioPackManifest>{};
  Directory? _folder;

  @override
  Iterable<String> get languages => _manifests.entries
      .where(
        (MapEntry<String, AudioPackManifest> e) => e.value.wordKeys.isNotEmpty,
      )
      .map((MapEntry<String, AudioPackManifest> e) => e.key);

  @override
  String? pathOf(String language, String wordKey, WordAudioKind kind) {
    final String? file = _manifests[language]?.fileOf(wordKey, kind);
    final Directory? folder = _folder;
    if (file == null || folder == null) return null;
    return '${folder.path}/$language/$file';
  }

  /// Reads the manifests of the device; never fails.
  Future<void> load() async {
    try {
      final Directory folder = await _folderOf();
      if (!folder.existsSync()) return;
      for (final FileSystemEntity entry in folder.listSync()) {
        final File manifest = File('${entry.path}/$_manifestName');
        if (entry is! Directory || !manifest.existsSync()) continue;
        final AudioPackManifest read = AudioPackManifest.fromJson(
          jsonDecode(await manifest.readAsString()) as Map<String, Object?>,
        );
        _manifests[read.language] = read;
      }
    } on Object catch (error, stackTrace) {
      log(
        'Teacher recordings not read',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Where a recording in progress is written.
  Future<String> recordingPath() async {
    final Directory folder = await _folderOf();
    folder.createSync(recursive: true);
    return '${folder.path}/recording.m4a';
  }

  /// The words recorded in [language] for [kind].
  Set<String> recordedKeys(String language, WordAudioKind kind) {
    final AudioPackManifest? manifest = _manifests[language];
    if (manifest == null) return const <String>{};
    return <String>{
      for (final String key in manifest.wordKeys)
        if (manifest.fileOf(key, kind) != null) key,
    };
  }

  /// Keeps the file at [source] as the recording [kind] of [wordKey] in
  /// [language]; [source] is moved.
  Future<void> keep({
    required String language,
    required String wordKey,
    required WordAudioKind kind,
    required String source,
  }) async {
    final String name = AudioPackManifest.fileNameOf(language, wordKey, kind);
    final Directory folder = await _languageFolder(language);
    await File(source).rename('${folder.path}/$name');
    await _save(_manifestOf(language).withFile(wordKey, kind, name));
  }

  /// Deletes the recording [kind] of [wordKey] in [language].
  Future<void> remove({
    required String language,
    required String wordKey,
    required WordAudioKind kind,
  }) async {
    final String? path = pathOf(language, wordKey, kind);
    if (path == null) return;
    final File file = File(path);
    if (file.existsSync()) await file.delete();
    await _save(_manifestOf(language).withoutFile(wordKey, kind));
  }

  /// The zip of the recordings of [language], laid out as `assets/audio/`.
  Future<List<int>> zip(String language) async {
    final AudioPackManifest? manifest = _manifests[language];
    if (manifest == null || manifest.wordKeys.isEmpty) {
      throw const NotFoundException(message: 'No recording to export.');
    }
    final Directory folder = await _languageFolder(language);
    return AudioPackZip.encode((
      manifest: manifest,
      files: <String, List<int>>{
        for (final String name in manifest.fileNames)
          name: await File('${folder.path}/$name').readAsBytes(),
      },
    ));
  }

  /// Adds the recordings of the zip [bytes], all or nothing: the whole
  /// file is checked, then written to a temporary folder, then moved in
  /// place. Resolves to how many recordings it held; throws an
  /// [InvalidFileException] on anything else than a pack.
  Future<int> unzip(List<int> bytes) async {
    final List<AudioPackContent> packs = AudioPackZip.decode(bytes);
    final Directory root = await _folderOf();
    final Directory staging = Directory('${root.path}/.import');
    if (staging.existsSync()) await staging.delete(recursive: true);
    await staging.create(recursive: true);
    try {
      for (final AudioPackContent pack in packs) {
        for (final MapEntry<String, List<int>> file in pack.files.entries) {
          await File('${staging.path}/${pack.manifest.language}_${file.key}')
              .writeAsBytes(file.value, flush: true);
        }
      }
      int count = 0;
      for (final AudioPackContent pack in packs) {
        count += await _moveIn(pack.manifest, staging);
      }
      return count;
    } finally {
      if (staging.existsSync()) await staging.delete(recursive: true);
    }
  }

  Future<int> _moveIn(AudioPackManifest pack, Directory staging) async {
    final Directory folder = await _languageFolder(pack.language);
    AudioPackManifest kept = _manifestOf(pack.language);
    int count = 0;
    for (final String wordKey in pack.wordKeys) {
      for (final WordAudioKind kind in WordAudioKind.values) {
        final String? name = pack.fileOf(wordKey, kind);
        if (name == null) continue;
        await File(
          '${staging.path}/${pack.language}_$name',
        ).rename('${folder.path}/$name');
        kept = kept.withFile(wordKey, kind, name);
        count++;
      }
    }
    await _save(kept);
    return count;
  }

  AudioPackManifest _manifestOf(String language) {
    return _manifests[language] ??
        AudioPackManifest(
          language: language,
          files: const <String, Map<WordAudioKind, String>>{},
        );
  }

  Future<void> _save(AudioPackManifest manifest) async {
    final Directory folder = await _languageFolder(manifest.language);
    await File(
      '${folder.path}/$_manifestName',
    ).writeAsString(jsonEncode(manifest.toJson()));
    _manifests[manifest.language] = manifest;
  }

  Future<Directory> _languageFolder(String language) async {
    if (!AudioPackZip.language.hasMatch(language)) {
      throw const InvalidFileException(message: 'Bad language code.');
    }
    final Directory folder = Directory('${(await _folderOf()).path}/$language');
    await folder.create(recursive: true);
    return folder;
  }

  Future<Directory> _folderOf() async => _folder ??= await _root();
}
