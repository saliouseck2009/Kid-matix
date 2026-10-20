import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/usecases/remove_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/reset_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/pupil_actions_state.dart';

/// The actions of the teacher on one pupil: reset their progress or
/// remove them from the class. Pupils never see these actions.
final class PupilActionsCubit extends Cubit<PupilActionsState> {
  /// Creates the Cubit.
  PupilActionsCubit({required this._reset, required this._remove})
    : super(const PupilActionsIdle());

  final ResetPupilUseCase _reset;
  final RemovePupilUseCase _remove;

  /// Erases the progress of the pupil [nickname] ([profileId]).
  Future<void> reset(String profileId, String nickname) async {
    await _run(
      await _reset(params: profileId),
      PupilActionDone(kind: PupilActionKind.reset, nickname: nickname),
    );
  }

  /// Removes the pupil [nickname] ([profileId]) from the class.
  Future<void> remove(String profileId, String nickname) async {
    await _run(
      await _remove(params: profileId),
      PupilActionDone(kind: PupilActionKind.remove, nickname: nickname),
    );
  }

  Future<void> _run(DataState<void> result, PupilActionDone done) async {
    if (isClosed) return;
    emit(switch (result) {
      DataSuccess<void>() => done,
      DataFailed<void>(:final exception) => PupilActionFailed(
        errorCode: exception.code,
      ),
    });
  }
}
