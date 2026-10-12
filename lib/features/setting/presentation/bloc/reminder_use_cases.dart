import 'package:kid_matix/features/setting/domain/usecases/get_reminder_settings_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_reminder_enabled_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_reminder_time_use_case.dart';

/// The use cases of the reminder rows of the settings screen.
final class ReminderUseCases {
  /// Groups the use cases.
  const ReminderUseCases({
    required this.getSettings,
    required this.setEnabled,
    required this.setTime,
  });

  /// Reads the settings.
  final GetReminderSettingsUseCase getSettings;

  /// Switches the reminder on or off.
  final SetReminderEnabledUseCase setEnabled;

  /// Changes its time.
  final SetReminderTimeUseCase setTime;
}
