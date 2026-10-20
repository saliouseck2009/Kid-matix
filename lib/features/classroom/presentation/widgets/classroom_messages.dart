import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_form_state.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/teacher_access_state.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Texts of the problems of the class mode, resolved for the screen.
extension ClassroomMessages on AppLocalizations {
  /// The text of [problem]; [unusable] names the nicknames to fix.
  String classroomFormProblem(
    ClassroomFormProblem problem, {
    List<String> unusable = const <String>[],
  }) {
    return switch (problem) {
      ClassroomFormProblem.name => classroomErrorName,
      ClassroomFormProblem.noPupil => classroomErrorNoPupil,
      ClassroomFormProblem.tooMany => classroomErrorTooMany(
        ClassroomRules.maxPupils,
      ),
      ClassroomFormProblem.unusable => classroomPupilsUnusable(
        unusable.join(', '),
      ),
      ClassroomFormProblem.taken => classroomErrorTaken,
      ClassroomFormProblem.failure => classroomErrorGeneric,
    };
  }

  /// The text of a refused teacher code.
  String teacherCodeError(TeacherCodeError error) {
    return switch (error) {
      TeacherCodeError.invalid => classroomCodeInvalid,
      TeacherCodeError.wrong => classroomCodeWrong,
      TeacherCodeError.mismatch => classroomCodeMismatch,
    };
  }

  /// What the door of the teacher area asks at [step].
  String teacherCodeHint(TeacherCodeStep step) {
    return switch (step) {
      TeacherCodeStep.enter => classroomCodeEnterHint,
      TeacherCodeStep.choose => classroomCodeChooseHint,
      TeacherCodeStep.confirm => classroomCodeConfirmHint,
    };
  }
}
