import 'package:kid_matix/features/profile/domain/usecases/export_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/pick_backup_use_case.dart';

/// Use cases of the backup section of the settings, grouped so
/// `BackupCubit` takes one argument.
final class BackupUseCases {
  /// Groups the use cases.
  const BackupUseCases({
    required this.exportProfile,
    required this.pickBackup,
    required this.importBackup,
  });

  /// Shares the backup of the player.
  final ExportProfileUseCase exportProfile;

  /// Picks and reads a backup file.
  final PickBackupUseCase pickBackup;

  /// Writes a backup file as a player.
  final ImportBackupUseCase importBackup;
}
