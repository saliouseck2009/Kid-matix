import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/notification_scheduler.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_local_data_source_impl.dart';
import 'package:kid_matix/features/setting/data/repositories/reminder_repository_impl.dart';
import 'package:kid_matix/features/setting/domain/repositories/reminder_repository.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_scheduler.dart';
import 'package:kid_matix/features/setting/domain/usecases/get_reminder_settings_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/record_finished_session_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/reschedule_reminders_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_reminder_enabled_use_case.dart';
import 'package:kid_matix/features/setting/domain/usecases/set_reminder_time_use_case.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_use_cases.dart';

import '../../../helpers/in_memory_local_storage.dart';

/// Monday 12 October 2026, 10:00: the reminder of 17:00 is still ahead.
final DateTime reminderMorning = DateTime(2026, 10, 12, 10);

/// [NotificationScheduler] that keeps the reminders in memory.
final class FakeNotificationScheduler implements NotificationScheduler {
  /// Creates the fake; [isGranted] is the answer to the permission.
  FakeNotificationScheduler({this.isGranted = true});

  /// Answer given when the permission is asked.
  bool isGranted;

  /// Whether every call fails, like a broken plugin.
  bool isBroken = false;

  /// Times the permission was asked.
  int permissionRequests = 0;

  /// Reminders scheduled now, in order.
  List<DateTime> scheduled = <DateTime>[];

  /// Times the reminders were cancelled.
  int cancellations = 0;

  @override
  Future<bool> requestPermission() async {
    _failWhenBroken();
    permissionRequests++;
    return isGranted;
  }

  @override
  Future<void> scheduleReminders({required List<DateTime> times}) async {
    _failWhenBroken();
    scheduled = List<DateTime>.of(times);
  }

  @override
  Future<void> cancelReminders() async {
    _failWhenBroken();
    cancellations++;
    scheduled = <DateTime>[];
  }

  void _failWhenBroken() {
    if (isBroken) throw StateError('notification plugin failed');
  }
}

/// [LocalStorage] whose every call fails.
final class BrokenLocalStorage implements LocalStorage {
  @override
  Future<String?> readString({required String key}) async =>
      throw StateError('storage failed');

  @override
  Future<void> writeString({required String key, required String value}) =>
      throw StateError('storage failed');

  @override
  Future<void> remove({required String key}) =>
      throw StateError('storage failed');
}

/// [Clock] stopped at a time the test moves.
final class MovableClock implements Clock {
  /// Creates the clock at [current].
  MovableClock(this.current);

  /// Current time.
  DateTime current;

  @override
  DateTime now() => current;
}

/// Everything of the reminder over fakes: the real repository on an
/// in-memory storage and a fake notification scheduler.
final class ReminderTestBed {
  /// Builds the bed at [now], [reminderMorning] by default.
  ReminderTestBed({
    DateTime? now,
    LocalStorage? storage,
    FakeNotificationScheduler? notifications,
  }) : clock = MovableClock(now ?? reminderMorning),
       storage = storage ?? InMemoryLocalStorage(),
       notifications = notifications ?? FakeNotificationScheduler() {
    repository = ReminderRepositoryImpl(
      local: ReminderLocalDataSourceImpl(storage: this.storage),
      notifications: this.notifications,
    );
    scheduler = ReminderScheduler(repository: repository, clock: clock);
  }

  /// Clock of the bed.
  final MovableClock clock;

  /// Preferences of the phone.
  final LocalStorage storage;

  /// Notifications of the phone.
  final FakeNotificationScheduler notifications;

  /// Repository over [storage] and [notifications].
  late final ReminderRepository repository;

  /// Scheduler over [repository].
  late final ReminderScheduler scheduler;

  /// Reads the settings.
  GetReminderSettingsUseCase get getSettings =>
      GetReminderSettingsUseCase(repository: repository);

  /// Switches the reminder.
  SetReminderEnabledUseCase get setEnabled =>
      SetReminderEnabledUseCase(repository: repository, scheduler: scheduler);

  /// Moves the reminder.
  SetReminderTimeUseCase get setTime =>
      SetReminderTimeUseCase(scheduler: scheduler);

  /// Plans again at launch.
  RescheduleRemindersUseCase get reschedule =>
      RescheduleRemindersUseCase(scheduler: scheduler);

  /// Notes a finished session.
  RecordFinishedSessionUseCase get recordFinishedSession =>
      RecordFinishedSessionUseCase(
        repository: repository,
        scheduler: scheduler,
      );

  /// The use cases of the settings rows.
  ReminderUseCases get useCases => ReminderUseCases(
    getSettings: getSettings,
    setEnabled: setEnabled,
    setTime: setTime,
  );
}
