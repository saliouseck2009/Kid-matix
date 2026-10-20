import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/teacher_access.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_state.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_use_cases.dart';

/// Drives the door of the teacher area: the first visit chooses a code
/// and confirms it, later visits type it.
///
/// Once the area opens, the router leaves the door by itself.
final class TeacherAccessCubit extends Cubit<TeacherAccessState> {
  /// Creates the Cubit.
  TeacherAccessCubit({required this._useCases})
    : super(const TeacherAccessLoading());

  final TeacherAccessUseCases _useCases;

  /// Reads whether a code exists.
  Future<void> load() async {
    emit(const TeacherAccessLoading());
    final DataState<TeacherAccess> access = await _useCases.getAccess();
    if (isClosed) return;
    emit(switch (access) {
      DataSuccess<TeacherAccess>(data: TeacherAccess.noCode) =>
        const TeacherAccessReady(step: TeacherCodeStep.choose),
      DataSuccess<TeacherAccess>() => const TeacherAccessReady(
        step: TeacherCodeStep.enter,
      ),
      DataFailed<TeacherAccess>(:final exception) => TeacherAccessFailure(
        errorCode: exception.code,
      ),
    });
  }

  /// Checks or records the [code] typed at the current step.
  Future<void> submit(String code) async {
    final TeacherAccessState current = state;
    if (current is! TeacherAccessReady || current.isBusy) return;
    if (!ClassroomRules.isTeacherCode(code)) {
      emit(_refused(current, TeacherCodeError.invalid));
      return;
    }
    switch (current.step) {
      case TeacherCodeStep.choose:
        emit(
          TeacherAccessReady(step: TeacherCodeStep.confirm, chosenCode: code),
        );
      case TeacherCodeStep.confirm when code != current.chosenCode:
        emit(
          const TeacherAccessReady(
            step: TeacherCodeStep.choose,
            error: TeacherCodeError.mismatch,
          ),
        );
      case TeacherCodeStep.confirm:
        await _finish(
          current,
          await _run(current, _useCases.chooseCode.call, code),
        );
      case TeacherCodeStep.enter:
        await _finish(
          current,
          await _run(current, _useCases.openArea.call, code),
        );
    }
  }

  Future<DataState<void>> _run(
    TeacherAccessReady current,
    Future<DataState<void>> Function({required String params}) action,
    String code,
  ) {
    emit(
      TeacherAccessReady(
        step: current.step,
        chosenCode: current.chosenCode,
        isBusy: true,
      ),
    );
    return action(params: code);
  }

  Future<void> _finish(
    TeacherAccessReady current,
    DataState<void> result,
  ) async {
    if (isClosed) return;
    switch (result) {
      case DataSuccess<void>():
        emit(TeacherAccessReady(step: current.step));
      case DataFailed<void>(:final exception)
          when exception.code == AppErrorCode.validation:
        emit(_refused(current, TeacherCodeError.wrong));
      case DataFailed<void>(:final exception):
        emit(TeacherAccessFailure(errorCode: exception.code));
    }
  }

  static TeacherAccessReady _refused(
    TeacherAccessReady current,
    TeacherCodeError error,
  ) {
    return TeacherAccessReady(
      step: current.step,
      chosenCode: current.chosenCode,
      error: error,
    );
  }
}
