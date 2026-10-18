import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/features/profile/data/models/profile_local_model.dart';
import 'package:kid_matix/features/profile/data/models/profile_settings_local_model.dart';

/// The section of a backup file holding the player and their settings.
abstract final class ProfileBackupSection {
  /// Name of the section.
  static const String name = 'profile';

  /// Key of the `profile` row.
  static const String profileKey = 'profile';

  /// Key of the `profile_settings` row.
  static const String settingsKey = 'settings';

  /// Returns the content of the section among [sections].
  ///
  /// Throws a [FormatException] when it is missing or malformed.
  static Map<String, Object?> contentOf(Map<String, Object?> sections) {
    final Object? content = sections[name];
    if (content is Map<String, Object?>) return content;
    throw const FormatException('No profile section.');
  }

  /// Reads the player of [sections]; throws a [FormatException] when it
  /// is missing or malformed.
  static ProfileLocalModel readProfile(Map<String, Object?> sections) {
    final ProfileLocalModel? profile = BackupSectionReader.readRow(
      contentOf(sections),
      key: profileKey,
      fromJson: ProfileLocalModel.fromJson,
    );
    if (profile == null) throw const FormatException('No profile row.');
    return profile;
  }

  /// Reads the settings of the player of [sections], or `null` when the
  /// file has none.
  static ProfileSettingsLocalModel? readSettings(
    Map<String, Object?> sections,
  ) {
    return BackupSectionReader.readRow(
      contentOf(sections),
      key: settingsKey,
      fromJson: ProfileSettingsLocalModel.fromJson,
    );
  }
}
