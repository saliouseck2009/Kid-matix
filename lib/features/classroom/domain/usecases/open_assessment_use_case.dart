import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';

/// Opens an assessment for a class, dated now: from then on, each pupil
/// of the class finds it at the top of their home until they took it or
/// the teacher closed it.
///
/// Fails with a `ValidationException` when the label of the period is
/// empty or too long.
class OpenAssessmentUseCase
    implements
        UseCase<
          DataState<ClassAssessment>,
          ({String classroomId, String periodLabel})
        > {
  /// Creates the use case.
  const OpenAssessmentUseCase({
    required this._repository,
    required this._ids,
    required this._clock,
  });

  final AssessmentRepository _repository;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Future<DataState<ClassAssessment>> call({
    required ({String classroomId, String periodLabel}) params,
  }) async {
    final String? label = AssessmentRules.cleanLabel(params.periodLabel);
    if (label == null) {
      return const DataFailed<ClassAssessment>(
        ValidationException(message: 'Invalid period label.'),
      );
    }
    final DateTime now = _clock.now();
    final ClassAssessment assessment = ClassAssessment(
      id: _ids.generateId(),
      classroomId: params.classroomId,
      periodLabel: label,
      openedAt: now,
      updatedAt: now,
    );
    final DataState<void> saved = await _repository.saveAssessment(
      assessment: assessment,
    );
    return switch (saved) {
      DataSuccess<void>() => DataSuccess<ClassAssessment>(assessment),
      DataFailed<void>(:final exception) => DataFailed<ClassAssessment>(
        exception,
      ),
    };
  }
}
