import 'package:kid_matix/features/classroom/domain/usecases/close_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_assessments_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pending_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_assessment_changes_use_case.dart';
import 'package:meta/meta.dart';

/// The use cases of the assessments of a class: the teacher opens and
/// closes them, the pupils find the one they still have to take.
@immutable
final class ClassAssessmentUseCases {
  /// Groups the use cases.
  const ClassAssessmentUseCases({
    required this.getAssessments,
    required this.open,
    required this.close,
    required this.getPending,
    required this.watchChanges,
  });

  /// Reads the assessments of a class.
  final GetClassAssessmentsUseCase getAssessments;

  /// Opens an assessment.
  final OpenAssessmentUseCase open;

  /// Closes an assessment.
  final CloseAssessmentUseCase close;

  /// Reads the assessment a pupil still has to take.
  final GetPendingAssessmentUseCase getPending;

  /// Follows the changes.
  final WatchAssessmentChangesUseCase watchChanges;
}
