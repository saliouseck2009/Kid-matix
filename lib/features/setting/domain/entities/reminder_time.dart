import 'package:meta/meta.dart';

/// Time of the day the reminder shows, in the phone's local time.
@immutable
final class ReminderTime {
  /// Creates the time [hour]:[minute], 24-hour clock.
  const ReminderTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < hoursPerDay, 'hour out of range'),
      assert(minute >= 0 && minute < minutesPerHour, 'minute out of range');

  /// Hours in a day.
  static const int hoursPerDay = 24;

  /// Minutes in an hour.
  static const int minutesPerHour = 60;

  /// Time of a reminder never changed: 17:00 (mockup 13).
  static const ReminderTime initial = ReminderTime(hour: 17, minute: 0);

  /// Hour, from 0 to 23.
  final int hour;

  /// Minute, from 0 to 59.
  final int minute;

  /// Returns this time on the day of [day], local time.
  DateTime onDay(DateTime day) {
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  /// Returns a copy with the given fields replaced.
  ReminderTime copyWith({int? hour, int? minute}) {
    return ReminderTime(hour: hour ?? this.hour, minute: minute ?? this.minute);
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'ReminderTime($hour:$minute)';
}
