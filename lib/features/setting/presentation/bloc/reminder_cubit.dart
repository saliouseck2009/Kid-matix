import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_state.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_use_cases.dart';

/// The daily reminder of the settings screen: on or off, and its time.
final class ReminderCubit extends Cubit<ReminderState> {
  /// Creates the Cubit.
  ReminderCubit({required this._useCases}) : super(const ReminderLoading());

  final ReminderUseCases _useCases;

  /// Reads the settings.
  Future<void> load() async {
    emit(const ReminderLoading());
    final DataState<ReminderSettings> read = await _useCases.getSettings();
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<ReminderSettings>(:final data) => ReminderLoaded(
        settings: data,
      ),
      DataFailed<ReminderSettings>(:final exception) => ReminderFailure(
        errorCode: exception.code,
      ),
    });
  }

  /// Switches the reminder on when [isEnabled], asking for the
  /// notifications first, or off; a refusal leaves it off.
  Future<void> setEnabled({required bool isEnabled}) {
    return _change(() => _useCases.setEnabled(params: isEnabled));
  }

  /// Moves the reminder to [time].
  Future<void> setTime({required ReminderTime time}) {
    return _change(() => _useCases.setTime(params: time));
  }

  Future<void> _change(
    Future<DataState<ReminderSettings>> Function() change,
  ) async {
    final ReminderState current = state;
    if (current is! ReminderLoaded || current.isSaving) return;
    emit(ReminderLoaded(settings: current.settings, isSaving: true));
    final DataState<ReminderSettings> changed = await change();
    if (isClosed) return;
    emit(switch (changed) {
      DataSuccess<ReminderSettings>(:final data) => ReminderLoaded(
        settings: data,
      ),
      DataFailed<ReminderSettings>(:final exception) => ReminderLoaded(
        settings: current.settings,
        errorCode: exception.code,
      ),
    });
  }
}
