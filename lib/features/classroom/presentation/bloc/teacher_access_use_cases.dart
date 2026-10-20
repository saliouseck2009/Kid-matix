import 'package:kid_matix/features/classroom/domain/usecases/choose_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_access_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_teacher_area_use_case.dart';
import 'package:meta/meta.dart';

/// The use cases of the door of the teacher area.
@immutable
final class TeacherAccessUseCases {
  /// Groups the use cases.
  const TeacherAccessUseCases({
    required this.getAccess,
    required this.chooseCode,
    required this.openArea,
    required this.closeArea,
  });

  /// Tells whether a code exists.
  final GetTeacherAccessUseCase getAccess;

  /// Records the code of the first visit.
  final ChooseTeacherCodeUseCase chooseCode;

  /// Opens the area with the code.
  final OpenTeacherAreaUseCase openArea;

  /// Closes the area.
  final CloseTeacherAreaUseCase closeArea;
}
