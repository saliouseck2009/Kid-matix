import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/repositories/reminder_repository.dart';

/// Reads the daily reminder settings of the phone.
class GetReminderSettingsUseCase
    implements NoParamUseCase<DataState<ReminderSettings>> {
  /// Creates the use case over [repository].
  const GetReminderSettingsUseCase({required this._repository});

  final ReminderRepository _repository;

  @override
  Future<DataState<ReminderSettings>> call() => _repository.getSettings();
}
