import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_preview_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_backup_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_backup_repository.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Lets the player pick a backup file, checks it, and finds the player of
/// the phone who already uses its nickname.
///
/// Resolves to `null` when no file was picked. Fails with an
/// `InvalidFileException` when the file is damaged or its nickname breaks
/// the rules, and an `UnsupportedVersionException` when a newer version
/// of the app wrote it.
class PickBackupUseCase
    implements NoParamUseCase<DataState<BackupPreviewEntity?>> {
  /// Creates the use case.
  const PickBackupUseCase({
    required this._backups,
    required this._profiles,
  });

  final ProfileBackupRepository _backups;
  final ProfileRepository _profiles;

  @override
  Future<DataState<BackupPreviewEntity?>> call() async {
    final DataState<ProfileBackupEntity?> picked = await _backups.pickBackup();
    return switch (picked) {
      DataFailed<ProfileBackupEntity?>(:final exception) =>
        DataFailed<BackupPreviewEntity?>(exception),
      DataSuccess<ProfileBackupEntity?>(data: null) =>
        const DataSuccess<BackupPreviewEntity?>(null),
      DataSuccess<ProfileBackupEntity?>(:final ProfileBackupEntity data) =>
        _preview(data),
    };
  }

  Future<DataState<BackupPreviewEntity?>> _preview(
    ProfileBackupEntity backup,
  ) async {
    if (NicknameRules.validate(backup.nickname) != null) {
      return const DataFailed<BackupPreviewEntity?>(
        InvalidFileException(message: 'Invalid nickname in the file.'),
      );
    }
    final DataState<List<ProfileEntity>> profiles = await _profiles
        .getProfiles();
    return switch (profiles) {
      DataFailed<List<ProfileEntity>>(:final exception) =>
        DataFailed<BackupPreviewEntity?>(exception),
      DataSuccess<List<ProfileEntity>>(:final List<ProfileEntity> data) =>
        DataSuccess<BackupPreviewEntity?>(
          BackupPreviewEntity(
            backup: backup,
            conflictingProfile: _sameNickname(data, backup.nickname),
          ),
        ),
    };
  }

  ProfileEntity? _sameNickname(List<ProfileEntity> profiles, String nickname) {
    final String normalized = NicknameRules.normalize(nickname);
    return profiles
        .where(
          (ProfileEntity profile) =>
              NicknameRules.normalize(profile.nickname) == normalized,
        )
        .firstOrNull;
  }
}
