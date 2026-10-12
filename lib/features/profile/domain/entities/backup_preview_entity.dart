import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:meta/meta.dart';

/// A backup file picked by the player, and the player of the phone who
/// already uses its nickname, if any.
@immutable
final class BackupPreviewEntity {
  /// Creates the preview of [backup].
  const BackupPreviewEntity({required this.backup, this.conflictingProfile});

  /// The file read.
  final ProfileBackupEntity backup;

  /// Player of the phone with the same nickname, or `null`.
  final ProfileEntity? conflictingProfile;

  /// Whether the nickname of the file is already used on the phone.
  bool get hasConflict => conflictingProfile != null;

  /// Returns a copy with the given fields replaced.
  BackupPreviewEntity copyWith({
    ProfileBackupEntity? backup,
    ProfileEntity? conflictingProfile,
  }) {
    return BackupPreviewEntity(
      backup: backup ?? this.backup,
      conflictingProfile: conflictingProfile ?? this.conflictingProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BackupPreviewEntity &&
        other.backup == backup &&
        other.conflictingProfile == conflictingProfile;
  }

  @override
  int get hashCode => Object.hash(backup, conflictingProfile);
}
