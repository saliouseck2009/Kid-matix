import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/setting/domain/entities/app_language.dart';
import 'package:kid_matix/features/setting/domain/repositories/language_repository.dart';
import 'package:kid_matix/features/setting/domain/services/reminder_scheduler.dart';

/// Keeps the language of the interface for the whole phone, then
/// schedules the daily reminder again so its notification speaks it too.
///
/// Only the language decides the outcome: a reminder that cannot be
/// scheduled again is logged by the repository and caught up at the next
/// launch, which schedules again.
class SetAppLanguageUseCase implements UseCase<DataState<void>, AppLanguage> {
  /// Creates the use case.
  const SetAppLanguageUseCase({
    required this._repository,
    required this._scheduler,
  });

  final LanguageRepository _repository;
  final ReminderScheduler _scheduler;

  @override
  Future<DataState<void>> call({required AppLanguage params}) async {
    final DataState<void> saved = await _repository.saveLanguage(
      language: params,
    );
    if (saved is DataFailed<void>) return saved;
    await _scheduler.applySaved();
    return saved;
  }
}
