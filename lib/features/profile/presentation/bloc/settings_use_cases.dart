import 'package:kid_matix/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_settings_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/reset_progress_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_settings_use_case.dart';

/// Use cases of the settings screen, grouped so `SettingsCubit` takes one
/// argument.
final class SettingsUseCases {
  /// Groups the use cases.
  const SettingsUseCases({
    required this.getProfile,
    required this.getSettings,
    required this.updateSettings,
    required this.resetProgress,
    required this.deleteProfile,
  });

  /// Reads the player, for their nickname.
  final GetProfileUseCase getProfile;

  /// Reads the settings.
  final GetSettingsUseCase getSettings;

  /// Saves the settings.
  final UpdateSettingsUseCase updateSettings;

  /// Erases the progress of the player.
  final ResetProgressUseCase resetProgress;

  /// Deletes the player.
  final DeleteProfileUseCase deleteProfile;
}
