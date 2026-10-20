import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_overview.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_state.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_use_cases.dart';

/// Reads a class with its assignment, dashboard, level groups and
/// challenge, follows their changes, and sets the weekly goal.
final class ClassOverviewCubit extends Cubit<ClassOverviewState> {
  /// Creates the Cubit of the class [classroomId].
  ClassOverviewCubit({required this._classroomId, required this._useCases})
    : super(const ClassOverviewLoading());

  final String _classroomId;
  final ClassOverviewUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the class and follows its changes.
  Future<void> load() async {
    _changes ??= _useCases.watchChanges().listen((_) => unawaited(_read()));
    emit(const ClassOverviewLoading());
    await _read();
  }

  /// Sets the right answers the class aims at each week.
  Future<void> setWeeklyGoal(int goal) async {
    final ClassOverviewState current = state;
    if (current is! ClassOverviewLoaded) return;
    final DataState<void> saved = await _useCases.setWeeklyGoal(
      params: (classroomId: _classroomId, goal: goal),
    );
    if (isClosed) return;
    switch (saved) {
      case DataSuccess<void>():
        await _read();
      case DataFailed<void>(:final exception):
        emit(
          ClassOverviewLoaded(
            overview: current.overview,
            errorCode: exception.code,
          ),
        );
    }
  }

  Future<void> _read() async {
    final DataState<ClassOverview> read = await _useCases.getOverview(
      params: _classroomId,
    );
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<ClassOverview>(:final data) => ClassOverviewLoaded(
        overview: data,
      ),
      DataFailed<ClassOverview>(:final exception) => ClassOverviewFailure(
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
