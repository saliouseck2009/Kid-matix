import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_summary.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_list_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classrooms_state.dart';

/// Reads the classes of the device and follows their changes, for « Mes
/// classes » and the class cards of « Qui joue ? ».
final class ClassroomsCubit extends Cubit<ClassroomsState> {
  /// Creates the Cubit.
  ClassroomsCubit({required this._useCases}) : super(const ClassroomsLoading());

  final ClassroomListUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the classes and follows their changes.
  Future<void> load() async {
    _changes ??= _useCases.watchChanges().listen((_) => unawaited(_read()));
    emit(const ClassroomsLoading());
    await _read();
  }

  /// Closes the teacher area; the router goes back to « Qui joue ? ».
  Future<void> leaveTeacherArea() => _useCases.closeArea();

  Future<void> _read() async {
    final DataState<List<ClassroomSummary>> read = await _useCases
        .getClassrooms();
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<List<ClassroomSummary>>(:final data) => ClassroomsLoaded(
        classrooms: data,
      ),
      DataFailed<List<ClassroomSummary>>(:final exception) => ClassroomsFailure(
        errorCode: exception.code,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
