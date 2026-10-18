import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_choice.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_target.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_limits.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_backup_repository.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';

/// Writes a backup file as a player of the phone, all or nothing, and
/// resolves to the nickname of the imported player.
///
/// A replaced player keeps their identifier, so they stay the active
/// player when they were. A new player fails with a
/// `LimitReachedException` when the phone is full; a nickname that breaks
/// the rules fails with a `ValidationException`, one already taken with a
/// `ConflictException`.
class ImportBackupUseCase
    implements UseCase<DataState<String>, ImportBackupParams> {
  /// Creates the use case.
  const ImportBackupUseCase({
    required this._backups,
    required this._profiles,
    required this._nicknameChecker,
    required this._idGenerator,
  });

  final ProfileBackupRepository _backups;
  final ProfileRepository _profiles;
  final NicknameChecker _nicknameChecker;
  final IdGenerator _idGenerator;

  @override
  Future<DataState<String>> call({required ImportBackupParams params}) async {
    final BackupImportTarget target = _targetOf(params);
    final AppException? problem = target.replacesProfile
        ? await _nicknameChecker.findProblem(
            nickname: target.nickname,
            excludedProfileId: target.profileId,
          )
        : await _findLimitProblem() ??
              await _nicknameChecker.findProblem(nickname: target.nickname);
    if (problem != null) return DataFailed<String>(problem);
    final DataState<void> imported = await _backups.importBackup(
      backup: params.backup,
      target: target,
    );
    return switch (imported) {
      DataFailed<void>(:final exception) => DataFailed<String>(exception),
      DataSuccess<void>() => DataSuccess<String>(target.nickname),
    };
  }

  BackupImportTarget _targetOf(ImportBackupParams params) {
    return switch (params.choice) {
      ImportAsNewPlayer() => BackupImportTarget(
        profileId: _idGenerator.generateId(),
        nickname: NicknameRules.clean(params.backup.nickname),
        replacesProfile: false,
      ),
      ReplacePlayer(:final String profileId) => BackupImportTarget(
        profileId: profileId,
        nickname: NicknameRules.clean(params.backup.nickname),
        replacesProfile: true,
      ),
      RenamePlayer(:final String nickname) => BackupImportTarget(
        profileId: _idGenerator.generateId(),
        nickname: NicknameRules.clean(nickname),
        replacesProfile: false,
      ),
    };
  }

  Future<AppException?> _findLimitProblem() async {
    final DataState<int> countState = await _profiles.countProfiles();
    return switch (countState) {
      DataFailed<int>(:final exception) => exception,
      DataSuccess<int>(:final int data)
          when data >= ProfileLimits.maxProfiles =>
        const LimitReachedException(message: 'Too many profiles.'),
      DataSuccess<int>() => null,
    };
  }
}
