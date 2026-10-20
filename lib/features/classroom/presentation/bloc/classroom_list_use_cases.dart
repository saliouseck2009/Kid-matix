import 'package:kid_matix/features/classroom/domain/usecases/close_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classrooms_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_classroom_changes_use_case.dart';
import 'package:meta/meta.dart';

/// The use cases of the lists of classes.
@immutable
final class ClassroomListUseCases {
  /// Groups the use cases.
  const ClassroomListUseCases({
    required this.getClassrooms,
    required this.watchChanges,
    required this.closeArea,
  });

  /// Lists the classes.
  final GetClassroomsUseCase getClassrooms;

  /// Follows the changes of the classes and their pupils.
  final WatchClassroomChangesUseCase watchChanges;

  /// Closes the teacher area.
  final CloseTeacherAreaUseCase closeArea;
}
