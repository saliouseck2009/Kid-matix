import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/remove_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/reset_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/select_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_classroom_changes_use_case.dart';
import 'package:meta/meta.dart';

/// The use cases of the lists of the pupils of a class.
@immutable
final class ClassroomRosterUseCases {
  /// Groups the use cases.
  const ClassroomRosterUseCases({
    required this.getRoster,
    required this.selectPupil,
    required this.watchChanges,
    required this.resetPupil,
    required this.removePupil,
  });

  /// Reads a class and its pupils.
  final GetClassroomRosterUseCase getRoster;

  /// Opens a pupil.
  final SelectPupilUseCase selectPupil;

  /// Follows the changes of the classes and their pupils.
  final WatchClassroomChangesUseCase watchChanges;

  /// Erases the progress of a pupil (teacher area).
  final ResetPupilUseCase resetPupil;

  /// Removes a pupil from the class (teacher area).
  final RemovePupilUseCase removePupil;
}
