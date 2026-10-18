/// Local notifications of the phone: the daily reminder.
///
/// Implemented over the notification plugin by the setting feature; tests
/// use a fake. Nothing here goes through the network.
abstract interface class NotificationScheduler {
  /// Asks the person for the right to show notifications; returns whether
  /// it is granted. Never called before the reminder is switched on.
  Future<bool> requestPermission();

  /// Shows the reminder at each of [times], local time, replacing every
  /// reminder scheduled before.
  Future<void> scheduleReminders({required List<DateTime> times});

  /// Removes every reminder scheduled.
  Future<void> cancelReminders();
}
