import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_state.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_roster_use_cases.dart';

/// Reads a class and its pupils, filters them by name and opens the
/// pupil who chose theirs: « Qui es-tu ? » and the list of the class
/// page.
///
/// Once a pupil is opened, the router leaves the screen by itself.
final class ClassroomRosterCubit extends Cubit<ClassroomRosterState> {
  /// Creates the Cubit of the class [classroomId].
  ClassroomRosterCubit({required this._classroomId, required this._useCases})
    : super(const ClassroomRosterLoading());

  final String _classroomId;
  final ClassroomRosterUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the class and follows its changes.
  Future<void> load() async {
    _changes ??= _useCases.watchChanges().listen((_) => unawaited(_read()));
    emit(const ClassroomRosterLoading());
    await _read();
  }

  /// Shows the pupils whose nickname contains [query].
  void search(String query) {
    if (state case final ClassroomRosterLoaded loaded) {
      emit(ClassroomRosterLoaded(roster: loaded.roster, query: query));
    }
  }

  /// Opens the pupil [profileId]: they start playing.
  Future<void> selectPupil(String profileId) async {
    emit(const ClassroomRosterLoading());
    final DataState<void> selected = await _useCases.selectPupil(
      params: profileId,
    );
    if (isClosed) return;
    if (selected case DataFailed<void>(:final exception)) {
      emit(ClassroomRosterFailure(errorCode: exception.code));
    }
  }

  Future<void> _read() async {
    final DataState<ClassroomRoster> read = await _useCases.getRoster(
      params: _classroomId,
    );
    if (isClosed) return;
    final ClassroomRosterState current = state;
    emit(switch (read) {
      DataSuccess<ClassroomRoster>(:final data) => ClassroomRosterLoaded(
        roster: data,
        query: current is ClassroomRosterLoaded ? current.query : '',
      ),
      DataFailed<ClassroomRoster>(:final exception) => ClassroomRosterFailure(
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
