import 'package:kid_matix/features/classroom/domain/usecases/export_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pupil_class_view_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/import_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_use_cases.dart';
import 'package:meta/meta.dart';

/// The use cases of the work of a class: its page, its assignment, what
/// its pupils see on the home and its files.
@immutable
final class ClassWorkUseCases {
  /// Groups the use cases.
  const ClassWorkUseCases({
    required this.overview,
    required this.giveAssignment,
    required this.getPupilView,
    required this.exportClassroom,
    required this.importClassroom,
  });

  /// The page of a class.
  final ClassOverviewUseCases overview;

  /// Gives a unit to a class.
  final GiveAssignmentUseCase giveAssignment;

  /// What a pupil sees of their class.
  final GetPupilClassViewUseCase getPupilView;

  /// Sends a class file.
  final ExportClassroomUseCase exportClassroom;

  /// Receives and merges a class file.
  final ImportClassroomUseCase importClassroom;
}
