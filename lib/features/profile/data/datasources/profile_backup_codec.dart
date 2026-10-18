import 'dart:convert';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/profile/data/models/backup_header_model.dart';
import 'package:kid_matix/features/profile/data/models/profile_backup_file_model.dart';

/// Turns the content of a backup file into text and back, refusing a
/// file that is no backup, is damaged, or comes from a newer app.
final class ProfileBackupCodec {
  /// Creates the codec.
  const ProfileBackupCodec();

  /// Returns the text of [file].
  String encode(ProfileBackupFileModel file) => jsonEncode(file.toJson());

  /// Reads [text], the content of a file.
  ///
  /// Throws an [InvalidFileException] when it is no backup or is damaged,
  /// and an [UnsupportedVersionException] when its version is newer than
  /// [ProfileBackupFileModel.currentVersion].
  ProfileBackupFileModel decode(String text) {
    final Map<String, Object?> json = _objectOf(text);
    final BackupHeaderModel header = _read(BackupHeaderModel.fromJson, json);
    final int? version = header.version;
    if (header.format != ProfileBackupFileModel.formatName ||
        version == null ||
        version < 1) {
      throw const InvalidFileException(message: 'Not a backup file.');
    }
    if (version > ProfileBackupFileModel.currentVersion) {
      throw UnsupportedVersionException(message: 'Backup version $version.');
    }
    final ProfileBackupFileModel file = _read(
      ProfileBackupFileModel.fromJson,
      json,
    );
    if (DateTime.tryParse(file.exportedAt) == null) {
      throw const InvalidFileException(message: 'Bad export date.');
    }
    return file;
  }

  Map<String, Object?> _objectOf(String text) {
    try {
      final Object? json = jsonDecode(text);
      if (json is Map<String, Object?>) return json;
    } on FormatException catch (error) {
      throw InvalidFileException(message: error.message);
    }
    throw const InvalidFileException(message: 'Not a JSON object.');
  }

  T _read<T>(
    T Function(Map<String, Object?> json) fromJson,
    Map<String, Object?> json,
  ) {
    try {
      return fromJson(json);
    } on TypeError catch (error) {
      throw InvalidFileException(message: error.toString());
    }
  }
}
