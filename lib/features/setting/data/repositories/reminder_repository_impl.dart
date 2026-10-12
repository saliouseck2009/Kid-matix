import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/notification_scheduler.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_local_data_source.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/repositories/reminder_repository.dart';

/// [ReminderRepository] over the device preferences and the local
/// notifications of the phone.
final class ReminderRepositoryImpl implements ReminderRepository {
  /// Creates the repository.
  const ReminderRepositoryImpl({
    required this._local,
    required this._notifications,
  });

  static const String _logName = 'reminder';

  final ReminderLocalDataSource _local;
  final NotificationScheduler _notifications;

  @override
  Future<DataState<ReminderSettings>> getSettings() {
    return _guardStorage(() async {
      const ReminderSettings initial = ReminderSettings.initial;
      return ReminderSettings(
        isEnabled: await _local.readEnabled() ?? initial.isEnabled,
        time: await _local.readTime() ?? initial.time,
      );
    }, failure: 'Reminder settings not read');
  }

  @override
  Future<DataState<void>> saveSettings({required ReminderSettings settings}) {
    return _guardStorage(() async {
      await _local.writeEnabled(isEnabled: settings.isEnabled);
      await _local.writeTime(time: settings.time);
    }, failure: 'Reminder settings not saved');
  }

  @override
  Future<DataState<DateTime?>> getLastSessionDay() {
    return _guardStorage(
      _local.readLastSessionDay,
      failure: 'Last session day not read',
    );
  }

  @override
  Future<DataState<void>> saveLastSessionDay({required DateTime day}) {
    return _guardStorage(
      () => _local.writeLastSessionDay(day: day),
      failure: 'Last session day not saved',
    );
  }

  @override
  Future<DataState<bool>> requestPermission() {
    return _guardNotifications(
      _notifications.requestPermission,
      failure: 'Notification permission not asked',
    );
  }

  @override
  Future<DataState<void>> scheduleReminders({required List<DateTime> times}) {
    return _guardNotifications(
      () => _notifications.scheduleReminders(times: times),
      failure: 'Reminders not scheduled',
    );
  }

  @override
  Future<DataState<void>> cancelReminders() {
    return _guardNotifications(
      _notifications.cancelReminders,
      failure: 'Reminders not cancelled',
    );
  }

  Future<DataState<T>> _guardStorage<T>(
    Future<T> Function() action, {
    required String failure,
  }) async {
    try {
      return DataSuccess<T>(await action());
    } on Object catch (error, stackTrace) {
      // The preferences plugin throws platform errors of no common type.
      log(failure, name: _logName, error: error, stackTrace: stackTrace);
      return DataFailed<T>(CacheException(message: error.toString()));
    }
  }

  Future<DataState<T>> _guardNotifications<T>(
    Future<T> Function() action, {
    required String failure,
  }) async {
    try {
      return DataSuccess<T>(await action());
    } on Object catch (error, stackTrace) {
      // The notification plugin throws platform errors of no common type.
      log(failure, name: _logName, error: error, stackTrace: stackTrace);
      return DataFailed<T>(UnknownException(message: error.toString()));
    }
  }
}
