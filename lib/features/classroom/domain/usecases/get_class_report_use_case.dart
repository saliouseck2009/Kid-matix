import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_roster.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/pupil_number_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/assessment_periods.dart';
import 'package:kid_matix/features/classroom/domain/services/class_progress_calculator.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';

/// The class and the two periods of a report: [fromKey] may be `null` for
/// a report of the period [toKey] alone.
typedef ClassReportParams = ({
  String classroomId,
  String? fromKey,
  String toKey,
});

/// Computes the progress report of a class between two of its periods,
/// from its assessments and the class results of its pupils, never from
/// the quiz journal; the earlier period is always the first. Pupils
/// without a class number (F31-04) get the next numbers of the class
/// first, so it writes `class_pupil_number` when needed.
///
/// Fails with a `NotFoundException` when a period does not exist.
class GetClassReportUseCase
    implements UseCase<DataState<ClassProgressReport>, ClassReportParams> {
  /// Creates the use case.
  const GetClassReportUseCase({
    required this._getRoster,
    required this._assessments,
    required this._journal,
    required this._numbers,
    required this._clock,
  });

  final GetClassroomRosterUseCase _getRoster;
  final AssessmentRepository _assessments;
  final ClassJournalRepository _journal;
  final PupilNumberRepository _numbers;
  final Clock _clock;

  @override
  Future<DataState<ClassProgressReport>> call({
    required ClassReportParams params,
  }) async {
    final String id = params.classroomId;
    final DataState<ClassroomRoster> roster = await _getRoster(params: id);
    final DataState<List<ClassAssessment>> assessments = await _assessments
        .getAssessments(classroomId: id);
    final DataState<List<AssessmentResult>> results = await _assessments
        .getResults(classroomId: id);
    final DataState<List<PracticeSession>> sessions = await _journal
        .getSessions(classroomId: id);
    return switch ((roster, assessments, results, sessions)) {
      (
        DataSuccess<ClassroomRoster>(data: final ClassroomRoster r),
        DataSuccess<List<ClassAssessment>>(data: final List<ClassAssessment> a),
        DataSuccess<List<AssessmentResult>>(
          data: final List<AssessmentResult> s,
        ),
        DataSuccess<List<PracticeSession>>(data: final List<PracticeSession> p),
      ) =>
        await _numbered(params, r, a, s, p),
      (DataFailed<ClassroomRoster>(:final exception), _, _, _) ||
      (_, DataFailed<List<ClassAssessment>>(:final exception), _, _) ||
      (_, _, DataFailed<List<AssessmentResult>>(:final exception), _) ||
      (
        _,
        _,
        _,
        DataFailed<List<PracticeSession>>(:final exception),
      ) => DataFailed<ClassProgressReport>(exception),
    };
  }

  /// The report with the stored number of each pupil (any pupil without
  /// one gets the next numbers of the class first).
  Future<DataState<ClassProgressReport>> _numbered(
    ClassReportParams params,
    ClassroomRoster roster,
    List<ClassAssessment> assessments,
    List<AssessmentResult> results,
    List<PracticeSession> sessions,
  ) async {
    final DataState<Map<String, int>> numbers = await _numbers.assign(
      classroomId: roster.classroom.id,
      pupilIds: roster.pupils.map((PupilEntity pupil) => pupil.id).toList(),
    );
    return switch (numbers) {
      DataFailed<Map<String, int>>(:final exception) =>
        DataFailed<ClassProgressReport>(exception),
      DataSuccess<Map<String, int>>(:final data) => _reportOf(
        params,
        (roster: roster, numbers: data),
        assessments,
        results,
        sessions,
      ),
    };
  }

  DataState<ClassProgressReport> _reportOf(
    ClassReportParams params,
    ({ClassroomRoster roster, Map<String, int> numbers}) pupils,
    List<ClassAssessment> assessments,
    List<AssessmentResult> results,
    List<PracticeSession> sessions,
  ) {
    final ClassroomRoster roster = pupils.roster;
    final List<AssessmentPeriod> periods = AssessmentPeriods.of(assessments);
    final AssessmentPeriod? first = AssessmentPeriods.find(
      periods,
      params.fromKey,
    );
    final AssessmentPeriod? second = AssessmentPeriods.find(
      periods,
      params.toKey,
    );
    if (second == null || (params.fromKey != null && first == null)) {
      return const DataFailed<ClassProgressReport>(
        NotFoundException(message: 'No such period.'),
      );
    }
    final bool isInOrder =
        first == null || !first.startedAt.isAfter(second.startedAt);
    return DataSuccess<ClassProgressReport>(
      ClassProgressCalculator.compute((
        classroom: roster.classroom,
        pupils: roster.pupils,
        from: isInOrder ? first : second,
        to: isInOrder ? second : first,
        results: results,
        sessions: sessions,
        generatedAt: _clock.now(),
        numbers: pupils.numbers,
      )),
    );
  }
}
