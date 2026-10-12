import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';

/// Chooses when the reminder shows: once a day at its time, for the
/// [dayCount] next days, never on a day a session was already finished.
///
/// Each day is its own notification rather than one repeating daily
/// notification, so the reminder of a day can be left out once a player
/// of the phone has finished a session. The app plans again at every
/// launch, after every session and on every change of the settings, so
/// the days ahead stay covered while the app is used.
class ReminderPlanner {
  /// Creates the planner.
  const ReminderPlanner();

  /// Days covered at once: a month without opening the app. iOS keeps at
  /// most 64 pending notifications.
  static const int dayCount = 30;

  /// Returns the next [dayCount] times, after [now], at which [time]
  /// falls; today is left out when [lastSessionDay] is today.
  List<DateTime> planReminders({
    required DateTime now,
    required ReminderTime time,
    DateTime? lastSessionDay,
  }) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    final bool isTodayDone =
        lastSessionDay != null && _isSameDay(lastSessionDay, today);
    return <DateTime>[
          for (int offset = 0; offset <= dayCount; offset++)
            time.onDay(DateTime(today.year, today.month, today.day + offset)),
        ]
        .where((DateTime at) => at.isAfter(now))
        .where((DateTime at) => !isTodayDone || !_isSameDay(at, today))
        .take(dayCount)
        .toList();
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
