import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:meta/meta.dart';

/// What the settings screen shows.
@immutable
sealed class SettingsState {
  const SettingsState();
}

/// The settings are being read, or the player is being deleted.
final class SettingsLoading extends SettingsState {
  /// Creates the state.
  const SettingsLoading();
}

/// The settings of the player.
final class SettingsLoaded extends SettingsState {
  /// Creates the state.
  const SettingsLoaded({
    required this.nickname,
    required this.settings,
    this.wasReset = false,
    this.errorCode,
  });

  /// Nickname of the player, to type again before resetting or deleting.
  final String nickname;

  /// Settings shown.
  final ProfileSettingsEntity settings;

  /// Whether the progress has just been erased.
  final bool wasReset;

  /// Why the last change failed, or `null`.
  final AppErrorCode? errorCode;
}

/// The settings could not be read.
final class SettingsFailure extends SettingsState {
  /// Creates the state.
  const SettingsFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
