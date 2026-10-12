import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_preview_entity.dart';
import 'package:meta/meta.dart';

/// Where the export or the import of a backup stands.
@immutable
sealed class BackupState {
  const BackupState();
}

/// Nothing is going on.
final class BackupIdle extends BackupState {
  /// Creates the state.
  const BackupIdle();
}

/// A file is being written, shared, picked or imported.
final class BackupWorking extends BackupState {
  /// Creates the state.
  const BackupWorking();
}

/// The file picked holds a nickname already used on the phone: replace
/// that player or rename the imported one.
final class BackupConflict extends BackupState {
  /// Creates the state for [preview].
  const BackupConflict({required this.preview});

  /// The file and the player with the same nickname.
  final BackupPreviewEntity preview;
}

/// The nickname typed for the imported player was refused; another one
/// is asked.
final class BackupRenameRefused extends BackupState {
  /// Creates the state.
  const BackupRenameRefused({
    required this.preview,
    required this.nickname,
    required this.errorCode,
  });

  /// The file picked.
  final BackupPreviewEntity preview;

  /// Nickname refused.
  final String nickname;

  /// Why: taken or breaking the rules.
  final AppErrorCode errorCode;
}

/// The backup file of the player was shared.
final class BackupExported extends BackupState {
  /// Creates the state.
  const BackupExported();
}

/// A file was imported as the player [nickname].
final class BackupImported extends BackupState {
  /// Creates the state.
  const BackupImported({required this.nickname, required this.wasReplaced});

  /// Nickname of the imported player.
  final String nickname;

  /// Whether a player of the phone was replaced rather than added.
  final bool wasReplaced;
}

/// The export or the import failed.
final class BackupFailed extends BackupState {
  /// Creates the state.
  const BackupFailed({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
