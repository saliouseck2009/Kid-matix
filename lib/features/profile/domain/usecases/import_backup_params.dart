import 'package:kid_matix/features/profile/domain/entities/backup_import_choice.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';
import 'package:meta/meta.dart';

/// What `ImportBackupUseCase` needs: the file read and the choice made.
@immutable
final class ImportBackupParams {
  /// Creates the parameters.
  const ImportBackupParams({required this.backup, required this.choice});

  /// The file read.
  final ProfileBackupEntity backup;

  /// New player, replaced player or new nickname.
  final BackupImportChoice choice;

  @override
  bool operator ==(Object other) {
    return other is ImportBackupParams &&
        other.backup == backup &&
        other.choice == choice;
  }

  @override
  int get hashCode => Object.hash(backup, choice);
}
