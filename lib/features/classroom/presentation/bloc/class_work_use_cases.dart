import 'package:kid_matix/features/classroom/domain/usecases/get_pupil_class_view_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_overview_use_cases.dart';
import 'package:meta/meta.dart';

/// The use cases of the work of a class: its page, its assignment and
/// what its pupils see on the home.
@immutable
final class ClassWorkUseCases {
  /// Groups the use cases.
  const ClassWorkUseCases({
    required this.overview,
    required this.giveAssignment,
    required this.getPupilView,
  });

  /// The page of a class.
  final ClassOverviewUseCases overview;

  /// Gives a unit to a class.
  final GiveAssignmentUseCase giveAssignment;

  /// What a pupil sees of their class.
  final GetPupilClassViewUseCase getPupilView;
}
