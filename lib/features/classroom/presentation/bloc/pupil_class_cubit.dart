import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_class_view.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pupil_class_view_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_classroom_changes_use_case.dart';

/// Reads what the player [profileId] sees of their class on the home,
/// and reads it again after each session: `null` for a free player, a
/// failure included (the home then simply shows no class).
final class PupilClassCubit extends Cubit<PupilClassView?> {
  /// Creates the Cubit.
  PupilClassCubit({
    required this._profileId,
    required this._getView,
    required this._watchChanges,
  }) : super(null);

  final String _profileId;
  final GetPupilClassViewUseCase _getView;
  final WatchClassroomChangesUseCase _watchChanges;
  StreamSubscription<void>? _changes;

  /// Reads the view and follows its changes.
  Future<void> load() async {
    _changes ??= _watchChanges().listen((_) => unawaited(_read()));
    await _read();
  }

  Future<void> _read() async {
    final DataState<PupilClassView?> read = await _getView(params: _profileId);
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<PupilClassView?>(:final data) => data,
      DataFailed<PupilClassView?>() => null,
    });
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
