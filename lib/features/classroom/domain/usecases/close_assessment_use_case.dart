import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';

/// Closes an assessment: the pupils no longer see it; the results already
/// kept stay.
///
/// Takes the identifier of the assessment; fails with a
/// `NotFoundException` when it does not exist.
class CloseAssessmentUseCase implements UseCase<DataState<void>, String> {
  /// Creates the use case.
  const CloseAssessmentUseCase({
    required this._repository,
    required this._clock,
  });

  final AssessmentRepository _repository;
  final Clock _clock;

  @override
  Future<DataState<void>> call({required String params}) async {
    final DataState<ClassAssessment?> read = await _repository.getAssessment(
      assessmentId: params,
    );
    if (read case DataFailed<ClassAssessment?>(:final exception)) {
      return DataFailed<void>(exception);
    }
    final ClassAssessment? assessment =
        (read as DataSuccess<ClassAssessment?>).data;
    if (assessment == null) {
      return const DataFailed<void>(
        NotFoundException(message: 'No such assessment.'),
      );
    }
    if (!assessment.isOpen) return const DataSuccess<void>(null);
    final DateTime now = _clock.now();
    return _repository.saveAssessment(
      assessment: assessment.copyWith(closedAt: now, updatedAt: now),
    );
  }
}
