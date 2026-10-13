import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_target.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';

/// Backup of one player to a file, and back.
///
/// The file holds the player and everything every feature keeps of them;
/// the app sends nothing itself: the player shares the file.
abstract interface class ProfileBackupRepository {
  /// Writes the backup of [profileId] to a file and opens the share sheet
  /// of the system with it; returns whether the file was shared.
  Future<DataState<bool>> exportProfile({required String profileId});

  /// Opens the file picker of the system and reads the backup chosen, or
  /// returns `null` when none was chosen.
  ///
  /// Fails with an `InvalidFileException` when the file is damaged or is
  /// no backup, and an `UnsupportedVersionException` when a newer version
  /// of the app wrote it.
  Future<DataState<ProfileBackupEntity?>> pickBackup();

  /// Writes [backup] as the player [target], all or nothing.
  ///
  /// Fails with an `InvalidFileException` when the content of the file
  /// is malformed.
  Future<DataState<void>> importBackup({
    required ProfileBackupEntity backup,
    required BackupImportTarget target,
  });
}
