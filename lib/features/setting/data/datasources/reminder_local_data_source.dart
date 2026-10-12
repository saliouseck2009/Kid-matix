import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';

/// The daily reminder kept in the device preferences, shared by every
/// player of the phone.
///
/// Methods throw the storage errors as they come; the repository turns
/// them into typed failures.
abstract interface class ReminderLocalDataSource {
  /// Whether the reminder is on, or `null` when never set.
  Future<bool?> readEnabled();

  /// Keeps whether the reminder is on.
  Future<void> writeEnabled({required bool isEnabled});

  /// Time of the reminder, or `null` when never set or unreadable.
  Future<ReminderTime?> readTime();

  /// Keeps the time of the reminder.
  Future<void> writeTime({required ReminderTime time});

  /// Last day a session was finished, or `null`.
  Future<DateTime?> readLastSessionDay();

  /// Keeps the last day a session was finished.
  Future<void> writeLastSessionDay({required DateTime day});
}
