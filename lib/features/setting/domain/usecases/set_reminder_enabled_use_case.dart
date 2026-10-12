import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/repositories/reminder_repository.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_scheduler.dart';

/// Switches the daily reminder on or off; takes whether it is on and
/// returns the new settings.
///
/// Switching it on first asks for the right to show notifications: this
/// is the only place the app asks, never at the first launch. A refusal
/// fails with [PermissionDeniedException] and keeps the reminder off.
class SetReminderEnabledUseCase
    implements UseCase<DataState<ReminderSettings>, bool> {
  /// Creates the use case.
  const SetReminderEnabledUseCase({
    required this._repository,
    required this._scheduler,
  });

  final ReminderRepository _repository;
  final ReminderScheduler _scheduler;

  @override
  Future<DataState<ReminderSettings>> call({required bool params}) async {
    if (params) {
      final DataState<bool> permission = await _repository.requestPermission();
      switch (permission) {
        case DataFailed<bool>(:final exception):
          return DataFailed<ReminderSettings>(exception);
        case DataSuccess<bool>(data: false):
          return const DataFailed<ReminderSettings>(
            PermissionDeniedException(message: 'Notifications refused'),
          );
        case DataSuccess<bool>(data: true):
          break;
      }
    }
    return _scheduler.update(
      change: (ReminderSettings current) => current.copyWith(isEnabled: params),
    );
  }
}
