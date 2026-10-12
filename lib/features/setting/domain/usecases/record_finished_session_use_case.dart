import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/setting/domain/repositories/reminder_repository.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_scheduler.dart';

/// Notes that a player of the phone finished a session at the time given,
/// and schedules the reminder again: no reminder that day.
class RecordFinishedSessionUseCase
    implements UseCase<DataState<void>, DateTime> {
  /// Creates the use case.
  const RecordFinishedSessionUseCase({
    required this._repository,
    required this._scheduler,
  });

  final ReminderRepository _repository;
  final ReminderScheduler _scheduler;

  @override
  Future<DataState<void>> call({required DateTime params}) async {
    final DataState<void> saved = await _repository.saveLastSessionDay(
      day: DateTime(params.year, params.month, params.day),
    );
    if (saved is DataFailed<void>) return saved;
    return _scheduler.applySaved();
  }
}
