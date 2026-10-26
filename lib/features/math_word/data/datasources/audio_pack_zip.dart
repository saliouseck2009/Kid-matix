import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';

/// One language of a pack file: its manifest and the bytes of each file
/// it names.
typedef AudioPackContent = ({
  AudioPackManifest manifest,
  Map<String, List<int>> files,
});

/// Writes and reads the pack files of the teacher's recordings (F31-06):
/// a zip laid out as `assets/audio/`, `<language>/manifest.json` (F28
/// format) and the `.m4a` files it names.
///
/// [decode] checks the whole file before anything is written: every
/// entry is a manifest or a file its manifest names, every name and
/// language code is safe, no file is over [maxFileBytes] and all of them
/// together over [maxPackBytes].
abstract final class AudioPackZip {
  /// Most bytes of one recording (one lasts 30 s at most).
  static const int maxFileBytes = 2 * 1024 * 1024;

  /// Most bytes of all the recordings of one pack file.
  static const int maxPackBytes = 50 * 1024 * 1024;

  /// Name of the manifest of a language.
  static const String manifestName = 'manifest.json';

  /// A language code: `wo`, `ff`, `bm-ML`...; any one is accepted, so a
  /// new language arrives by file (F32-01).
  static final RegExp language = RegExp(r'^[a-z]{2,3}(-[A-Za-z0-9]{2,8})?$');

  static final RegExp _fileName = RegExp(r'^[A-Za-z0-9_-]+\.m4a$');

  /// The zip of [content].
  static List<int> encode(AudioPackContent content) {
    final String code = content.manifest.language;
    final Archive archive = Archive()
      ..add(
        ArchiveFile.bytes(
          '$code/$manifestName',
          utf8.encode(jsonEncode(content.manifest.toJson())),
        ),
      );
    for (final MapEntry<String, List<int>> file in content.files.entries) {
      archive.add(ArchiveFile.bytes('$code/${file.key}', file.value));
    }
    return ZipEncoder().encodeBytes(archive);
  }

  /// Every language of the zip [bytes], checked; throws an
  /// [InvalidFileException] on anything else than a sound pack file.
  static List<AudioPackContent> decode(List<int> bytes) {
    final Archive archive = _archiveOf(bytes);
    final Map<String, AudioPackManifest> manifests =
        <String, AudioPackManifest>{
          for (final ArchiveFile entry in archive.files)
            if (_isManifest(entry.name))
              entry.name.split('/').first: _manifestOf(entry),
        };
    final Set<String> named = <String>{
      for (final AudioPackManifest manifest in manifests.values)
        for (final String file in manifest.fileNames)
          '${manifest.language}/$file',
    };
    int total = 0;
    for (final ArchiveFile entry in archive.files) {
      if (!entry.isFile || _isManifest(entry.name)) continue;
      if (!named.contains(entry.name) || entry.size > maxFileBytes) {
        _refuse('Unexpected or too big entry: ${entry.name}');
      }
      total += entry.size;
    }
    if (named.isEmpty || total > maxPackBytes) _refuse('Empty or too big.');
    return <AudioPackContent>[
      for (final AudioPackManifest manifest in manifests.values)
        (manifest: manifest, files: _filesOf(archive, manifest)),
    ];
  }

  static Map<String, List<int>> _filesOf(
    Archive archive,
    AudioPackManifest manifest,
  ) {
    final Map<String, List<int>> files = <String, List<int>>{};
    for (final String name in manifest.fileNames) {
      final ArchiveFile? entry = archive.findFile('${manifest.language}/$name');
      if (entry == null) _refuse('Missing file: $name');
      final List<int> content = entry.content;
      if (content.length > maxFileBytes) _refuse('Too big: $name');
      files[name] = content;
    }
    return files;
  }

  static bool _isManifest(String name) {
    final List<String> parts = name.split('/');
    return parts.length == 2 && parts.last == manifestName;
  }

  static AudioPackManifest _manifestOf(ArchiveFile entry) {
    final String code = entry.name.split('/').first;
    if (!language.hasMatch(code) || entry.size > maxFileBytes) {
      _refuse('Bad language code.');
    }
    final AudioPackManifest manifest;
    try {
      manifest = AudioPackManifest.fromJson(
        jsonDecode(utf8.decode(entry.content)) as Map<String, Object?>,
      );
    } on Object catch (error) {
      throw InvalidFileException(message: error.toString());
    }
    if (manifest.language != code ||
        !manifest.fileNames.every(_fileName.hasMatch)) {
      _refuse('Bad manifest.');
    }
    return manifest;
  }

  static Archive _archiveOf(List<int> bytes) {
    try {
      return ZipDecoder().decodeBytes(bytes);
    } on Object catch (error) {
      throw InvalidFileException(message: error.toString());
    }
  }

  static Never _refuse(String message) {
    throw InvalidFileException(message: message);
  }
}
