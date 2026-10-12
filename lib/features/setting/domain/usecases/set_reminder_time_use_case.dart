import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_scheduler.dart';

/// Moves the daily reminder to another time of the day and schedules it
/// again; returns the new settings.
class SetReminderTimeUseCase
    implements UseCase<DataState<ReminderSettings>, ReminderTime> {
  /// Creates the use case.
  const SetReminderTimeUseCase({required this._scheduler});

  final ReminderScheduler _scheduler;

  @override
  Future<DataState<ReminderSettings>> call({required ReminderTime params}) {
    return _scheduler.update(
      change: (ReminderSettings current) => current.copyWith(time: params),
    );
  }
}
