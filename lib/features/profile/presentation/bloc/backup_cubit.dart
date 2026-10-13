import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_choice.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_preview_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_params.dart';
import 'package:kid_matix/features/profile/presentation/bloc/backup_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/backup_use_cases.dart';

/// Exports the backup of the player [_profileId] and imports backup
/// files, asking how to settle a nickname already used on the phone.
///
/// The screen asks an adult before calling [exportProfile] or
/// [pickBackup].
final class BackupCubit extends Cubit<BackupState> {
  /// Creates the Cubit of the player [profileId].
  BackupCubit({required this._profileId, required this._useCases})
    : super(const BackupIdle());

  final String _profileId;
  final BackupUseCases _useCases;

  /// Writes the backup file of the player and opens the share sheet.
  Future<void> exportProfile() async {
    if (state is BackupWorking) return;
    emit(const BackupWorking());
    final DataState<bool> shared = await _useCases.exportProfile(
      params: _profileId,
    );
    if (isClosed) return;
    emit(switch (shared) {
      DataSuccess<bool>(data: true) => const BackupExported(),
      DataSuccess<bool>(data: false) => const BackupIdle(),
      DataFailed<bool>(:final exception) => BackupFailed(
        errorCode: exception.code,
      ),
    });
  }

  /// Opens the file picker, then imports the file at once when its
  /// nickname is free, or asks how to settle it.
  Future<void> pickBackup() async {
    if (state is BackupWorking) return;
    emit(const BackupWorking());
    final DataState<BackupPreviewEntity?> picked = await _useCases.pickBackup();
    if (isClosed) return;
    switch (picked) {
      case DataFailed<BackupPreviewEntity?>(:final exception):
        emit(BackupFailed(errorCode: exception.code));
      case DataSuccess<BackupPreviewEntity?>(data: null):
        emit(const BackupIdle());
      case DataSuccess<BackupPreviewEntity?>(
            :final BackupPreviewEntity data,
          )
          when data.hasConflict:
        emit(BackupConflict(preview: data));
      case DataSuccess<BackupPreviewEntity?>(:final BackupPreviewEntity data):
        await _import(data, const ImportAsNewPlayer());
    }
  }

  /// Replaces the player of the phone with the same nickname by the file.
  Future<void> replacePlayer() async {
    final BackupPreviewEntity? preview = _pendingPreview();
    final ProfileEntity? replaced = preview?.conflictingProfile;
    if (preview == null || replaced == null) return;
    await _import(preview, ReplacePlayer(profileId: replaced.id));
  }

  /// Imports the file as a new player named [nickname].
  Future<void> renamePlayer(String nickname) async {
    final BackupPreviewEntity? preview = _pendingPreview();
    if (preview == null) return;
    await _import(preview, RenamePlayer(nickname: nickname));
  }

  /// Gives up the file picked.
  void cancel() => emit(const BackupIdle());

  BackupPreviewEntity? _pendingPreview() {
    return switch (state) {
      BackupConflict(:final BackupPreviewEntity preview) ||
      BackupRenameRefused(:final BackupPreviewEntity preview) => preview,
      _ => null,
    };
  }

  Future<void> _import(
    BackupPreviewEntity preview,
    BackupImportChoice choice,
  ) async {
    emit(const BackupWorking());
    final DataState<String> imported = await _useCases.importBackup(
      params: ImportBackupParams(backup: preview.backup, choice: choice),
    );
    if (isClosed) return;
    emit(switch ((imported, choice)) {
      (DataSuccess<String>(:final String data), _) => BackupImported(
        nickname: data,
        wasReplaced: choice is ReplacePlayer,
      ),
      (
        DataFailed<String>(:final exception),
        RenamePlayer(:final String nickname),
      )
          when exception.code == AppErrorCode.conflict ||
              exception.code == AppErrorCode.validation =>
        BackupRenameRefused(
          preview: preview,
          nickname: nickname,
          errorCode: exception.code,
        ),
      (DataFailed<String>(:final exception), _) => BackupFailed(
        errorCode: exception.code,
      ),
    });
  }
}
