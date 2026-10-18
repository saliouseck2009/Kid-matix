import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/repositories/reminder_repository.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_planner.dart';

/// Puts the notifications of the phone in line with reminder settings:
/// none when off, otherwise the days planned by [ReminderPlanner].
class ReminderScheduler {
  /// Creates the scheduler.
  const ReminderScheduler({
    required this._repository,
    required this._clock,
    this._planner = const ReminderPlanner(),
  });

  final ReminderRepository _repository;
  final Clock _clock;
  final ReminderPlanner _planner;

  /// Changes the settings kept with [change], then schedules for them;
  /// the settings stay as they were when the notifications cannot be
  /// scheduled. Returns the new settings.
  Future<DataState<ReminderSettings>> update({
    required ReminderSettings Function(ReminderSettings current) change,
  }) async {
    final DataState<ReminderSettings> current = await _repository.getSettings();
    if (current is DataFailed<ReminderSettings>) return current;
    final ReminderSettings updated = change(
      (current as DataSuccess<ReminderSettings>).data,
    );
    final DataState<void> applied = await apply(settings: updated);
    if (applied is DataFailed<void>) {
      return DataFailed<ReminderSettings>(applied.exception);
    }
    final DataState<void> saved = await _repository.saveSettings(
      settings: updated,
    );
    return switch (saved) {
      DataFailed<void>(:final exception) => DataFailed<ReminderSettings>(
        exception,
      ),
      DataSuccess<void>() => DataSuccess<ReminderSettings>(updated),
    };
  }

  /// Schedules or cancels the reminders for the settings kept.
  Future<DataState<void>> applySaved() async {
    final DataState<ReminderSettings> settings = await _repository
        .getSettings();
    return switch (settings) {
      DataFailed<ReminderSettings>(:final exception) => DataFailed<void>(
        exception,
      ),
      DataSuccess<ReminderSettings>(:final data) => apply(settings: data),
    };
  }

  /// Schedules or cancels the reminders for [settings].
  Future<DataState<void>> apply({required ReminderSettings settings}) async {
    if (!settings.isEnabled) return _repository.cancelReminders();
    final DataState<DateTime?> lastDay = await _repository.getLastSessionDay();
    return switch (lastDay) {
      DataFailed<DateTime?>(:final exception) => DataFailed<void>(exception),
      DataSuccess<DateTime?>(:final data) => _repository.scheduleReminders(
        times: _planner.planReminders(
          now: _clock.now(),
          time: settings.time,
          lastSessionDay: data,
        ),
      ),
    };
  }
}
