import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';

/// The daily reminder: its settings and the last day a session was
/// finished, kept on the phone, and its notifications.
abstract interface class ReminderRepository {
  /// Returns the settings, [ReminderSettings.initial] when never changed.
  Future<DataState<ReminderSettings>> getSettings();

  /// Keeps [settings].
  Future<DataState<void>> saveSettings({required ReminderSettings settings});

  /// Returns the last day a player of the phone finished a session, or
  /// `null`.
  Future<DataState<DateTime?>> getLastSessionDay();

  /// Keeps [day] as the last day a session was finished.
  Future<DataState<void>> saveLastSessionDay({required DateTime day});

  /// Asks for the right to show notifications; returns whether granted.
  Future<DataState<bool>> requestPermission();

  /// Schedules the reminder at [times], replacing the previous ones.
  Future<DataState<void>> scheduleReminders({required List<DateTime> times});

  /// Removes every reminder scheduled.
  Future<DataState<void>> cancelReminders();
}
