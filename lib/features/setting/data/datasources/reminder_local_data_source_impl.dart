import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_local_data_source.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';

/// [ReminderLocalDataSource] over the device preferences.
final class ReminderLocalDataSourceImpl implements ReminderLocalDataSource {
  /// Creates the data source over [storage].
  const ReminderLocalDataSourceImpl({required this._storage});

  /// Preference key of the switch.
  static const String enabledKey = 'reminder_enabled';

  /// Preference key of the time, `HH:mm` (`rappelHeure` in the
  /// specifications).
  static const String timeKey = 'reminder_time';

  /// Preference key of the last day a session was finished, `yyyy-MM-dd`.
  static const String lastSessionDayKey = 'reminder_last_session_day';

  static const String _on = 'true';
  static const String _off = 'false';
  static const String _timeSeparator = ':';
  static const String _dateSeparator = '-';
  static const int _twoDigits = 2;
  static const int _fourDigits = 4;

  final LocalStorage _storage;

  @override
  Future<bool?> readEnabled() async {
    return switch (await _storage.readString(key: enabledKey)) {
      _on => true,
      _off => false,
      _ => null,
    };
  }

  @override
  Future<void> writeEnabled({required bool isEnabled}) {
    return _storage.writeString(key: enabledKey, value: isEnabled ? _on : _off);
  }

  @override
  Future<ReminderTime?> readTime() async {
    final List<int>? parts = _numbersOf(
      await _storage.readString(key: timeKey),
      separator: _timeSeparator,
      count: 2,
    );
    if (parts == null) return null;
    final [int hour, int minute] = parts;
    final bool isValid =
        hour < ReminderTime.hoursPerDay && minute < ReminderTime.minutesPerHour;
    return isValid ? ReminderTime(hour: hour, minute: minute) : null;
  }

  @override
  Future<void> writeTime({required ReminderTime time}) {
    return _storage.writeString(
      key: timeKey,
      value:
          '${_pad(time.hour, _twoDigits)}$_timeSeparator'
          '${_pad(time.minute, _twoDigits)}',
    );
  }

  @override
  Future<DateTime?> readLastSessionDay() async {
    final List<int>? parts = _numbersOf(
      await _storage.readString(key: lastSessionDayKey),
      separator: _dateSeparator,
      count: 3,
    );
    if (parts == null) return null;
    final [int year, int month, int day] = parts;
    return DateTime(year, month, day);
  }

  @override
  Future<void> writeLastSessionDay({required DateTime day}) {
    return _storage.writeString(
      key: lastSessionDayKey,
      value:
          '${_pad(day.year, _fourDigits)}$_dateSeparator'
          '${_pad(day.month, _twoDigits)}$_dateSeparator'
          '${_pad(day.day, _twoDigits)}',
    );
  }

  static String _pad(int value, int width) {
    return value.toString().padLeft(width, '0');
  }

  /// The [count] non-negative numbers of [text] split by [separator], or
  /// `null` when [text] has another shape.
  static List<int>? _numbersOf(
    String? text, {
    required String separator,
    required int count,
  }) {
    final List<int?> numbers = (text?.split(separator) ?? const <String>[])
        .map(int.tryParse)
        .toList();
    final bool isValid =
        numbers.length == count &&
        numbers.every((int? number) => number != null && number >= 0);
    return isValid ? numbers.cast<int>() : null;
  }
}
