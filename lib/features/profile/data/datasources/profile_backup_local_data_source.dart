import 'package:kid_matix/features/profile/domain/entities/backup_import_target.dart';

/// Reads and writes everything the app keeps of one player, section by
/// section, for a backup file.
abstract interface class ProfileBackupLocalDataSource {
  /// Returns the sections of the player [profileId], read in one
  /// transaction. Throws a `NotFoundException` when there is no such
  /// player.
  Future<Map<String, Object?>> readSections({required String profileId});

  /// Writes [sections] as the player [target] in one transaction, erasing
  /// the player first when [BackupImportTarget.replacesProfile], and
  /// returns the tables written.
  ///
  /// Throws a [FormatException] when a section is malformed.
  Future<Set<String>> writeSections({
    required Map<String, Object?> sections,
    required BackupImportTarget target,
  });
}
