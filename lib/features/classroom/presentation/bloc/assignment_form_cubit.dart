import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_params.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/assignment_form_state.dart';

/// Lets the teacher pick a domain, a due day and a unit, then gives it
/// to the class [classroomId].
final class AssignmentFormCubit extends Cubit<AssignmentFormState> {
  /// Creates the Cubit, on the first [domainId].
  AssignmentFormCubit({
    required this.classroomId,
    required String domainId,
    required this._give,
  }) : super(AssignmentFormState(domainId: domainId));

  /// Class that receives the assignment.
  final String classroomId;

  final GiveAssignmentUseCase _give;

  /// Lists the units of [domainId].
  void selectDomain(String domainId) {
    emit(state.copyWith(domainId: domainId));
  }

  /// Sets when the assignment is due.
  void selectDue(AssignmentDue due) => emit(state.copyWith(due: due));

  /// Gives [unitKey] to the class.
  Future<void> give(String unitKey) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));
    final DataState<AssignmentEntity> given = await _give(
      params: GiveAssignmentParams(
        classroomId: classroomId,
        domainId: state.domainId,
        unitKey: unitKey,
        dueInDays: switch (state.due) {
          AssignmentDue.none => null,
          AssignmentDue.tomorrow => 1,
          AssignmentDue.nextWeek => 7,
        },
      ),
    );
    if (isClosed) return;
    emit(switch (given) {
      DataSuccess<AssignmentEntity>() => state.copyWith(isGiven: true),
      DataFailed<AssignmentEntity>(:final exception) => state.copyWith(
        errorCode: exception.code,
      ),
    });
  }
}
