import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';
import 'package:meta/meta.dart';

/// The daily reminder of the phone, shared by every player.
@immutable
final class ReminderSettings {
  /// Creates the settings.
  const ReminderSettings({required this.isEnabled, required this.time});

  /// Settings of a phone where the reminder was never touched: off, at
  /// 17:00.
  static const ReminderSettings initial = ReminderSettings(
    isEnabled: false,
    time: ReminderTime.initial,
  );

  /// Whether the reminder is on.
  final bool isEnabled;

  /// Time of the day it shows.
  final ReminderTime time;

  /// Returns a copy with the given fields replaced.
  ReminderSettings copyWith({bool? isEnabled, ReminderTime? time}) {
    return ReminderSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderSettings &&
        other.isEnabled == isEnabled &&
        other.time == time;
  }

  @override
  int get hashCode => Object.hash(isEnabled, time);

  @override
  String toString() => 'ReminderSettings($isEnabled, $time)';
}
