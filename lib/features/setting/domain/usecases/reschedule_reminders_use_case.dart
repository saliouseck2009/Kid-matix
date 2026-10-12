import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_scheduler.dart';

/// Schedules the daily reminder again from the settings kept, at every
/// launch of the app: the days ahead stay covered, and a change of the
/// phone's clock or time zone is taken into account.
class RescheduleRemindersUseCase implements NoParamUseCase<DataState<void>> {
  /// Creates the use case.
  const RescheduleRemindersUseCase({required this._scheduler});

  final ReminderScheduler _scheduler;

  @override
  Future<DataState<void>> call() => _scheduler.applySaved();
}
