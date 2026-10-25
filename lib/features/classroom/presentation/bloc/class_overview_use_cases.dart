import 'package:kid_matix/features/classroom/domain/usecases/get_class_overview_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/set_weekly_goal_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_classroom_changes_use_case.dart';
import 'package:meta/meta.dart';

/// The use cases of the page of a class.
@immutable
final class ClassOverviewUseCases {
  /// Groups the use cases.
  const ClassOverviewUseCases({
    required this.getOverview,
    required this.setWeeklyGoal,
    required this.watchChanges,
  });

  /// Reads the class and its figures.
  final GetClassOverviewUseCase getOverview;

  /// Sets the goal of the class challenge.
  final SetWeeklyGoalUseCase setWeeklyGoal;

  /// Follows the changes of the class.
  final WatchClassroomChangesUseCase watchChanges;
}
