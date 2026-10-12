import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:meta/meta.dart';

/// What the reminder rows of the settings screen show.
@immutable
sealed class ReminderState {
  const ReminderState();
}

/// The settings are being read.
final class ReminderLoading extends ReminderState {
  /// Creates the state.
  const ReminderLoading();
}

/// The settings of the reminder.
final class ReminderLoaded extends ReminderState {
  /// Creates the state.
  const ReminderLoaded({
    required this.settings,
    this.isSaving = false,
    this.errorCode,
  });

  /// Settings shown.
  final ReminderSettings settings;

  /// Whether a change is under way (the permission may be asked): the
  /// rows wait for it.
  final bool isSaving;

  /// Why the last change failed, or `null`.
  final AppErrorCode? errorCode;
}

/// The settings could not be read.
final class ReminderFailure extends ReminderState {
  /// Creates the state.
  const ReminderFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
