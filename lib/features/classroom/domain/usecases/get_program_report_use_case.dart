import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_summary.dart';
import 'package:kid_matix/features/classroom/domain/entities/program_report.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/assessment_periods.dart';
import 'package:kid_matix/features/classroom/domain/services/program_report_calculator.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_report_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classrooms_use_case.dart';

/// The two periods of a school or program report, by their key: [fromKey]
/// may be `null` for one period.
typedef ProgramReportParams = ({String? fromKey, String toKey});

/// Reads the periods of every class of the device, and consolidates their
/// reports into the report of a school or a program: a coordinator's
/// device merges the class files of several teachers (F29-10), then
/// compares two periods over all of them, anonymous only.
class GetProgramReportUseCase
    implements UseCase<DataState<ProgramReport>, ProgramReportParams> {
  /// Creates the use case.
  const GetProgramReportUseCase({
    required this._getClassrooms,
    required this._assessments,
    required this._getClassReport,
    required this._clock,
  });

  final GetClassroomsUseCase _getClassrooms;
  final AssessmentRepository _assessments;
  final GetClassReportUseCase _getClassReport;
  final Clock _clock;

  @override
  Future<DataState<ProgramReport>> call({
    required ProgramReportParams params,
  }) async {
    final DataState<List<AssessmentPeriod>> periods = await readPeriods();
    if (periods case DataFailed<List<AssessmentPeriod>>(:final exception)) {
      return DataFailed<ProgramReport>(exception);
    }
    final List<AssessmentPeriod> known =
        (periods as DataSuccess<List<AssessmentPeriod>>).data;
    final AssessmentPeriod? from = AssessmentPeriods.find(
      known,
      params.fromKey,
    );
    final AssessmentPeriod? to = AssessmentPeriods.find(known, params.toKey);
    if (to == null) {
      return const DataFailed<ProgramReport>(
        NotFoundException(message: 'No such period.'),
      );
    }
    final DataState<List<ClassProgressReport>> reports = await _classReports(
      from?.key,
      to.key,
    );
    return switch (reports) {
      DataFailed<List<ClassProgressReport>>(:final exception) =>
        DataFailed<ProgramReport>(exception),
      DataSuccess<List<ClassProgressReport>>(:final data) =>
        DataSuccess<ProgramReport>(
          ProgramReportCalculator.compute(
            classes: data,
            fromLabel: from?.label,
            toLabel: to.label,
            generatedAt: _clock.now(),
          ),
        ),
    };
  }

  /// The periods of every class of the device, one per key, the earliest
  /// first.
  Future<DataState<List<AssessmentPeriod>>> readPeriods() async {
    final DataState<List<ClassroomSummary>> classes = await _getClassrooms();
    if (classes case DataFailed<List<ClassroomSummary>>(:final exception)) {
      return DataFailed<List<AssessmentPeriod>>(exception);
    }
    final List<ClassAssessment> every = <ClassAssessment>[];
    for (final ClassroomSummary summary
        in (classes as DataSuccess<List<ClassroomSummary>>).data) {
      final DataState<List<ClassAssessment>> read = await _assessments
          .getAssessments(classroomId: summary.classroom.id);
      if (read case DataFailed<List<ClassAssessment>>(:final exception)) {
        return DataFailed<List<AssessmentPeriod>>(exception);
      }
      every.addAll((read as DataSuccess<List<ClassAssessment>>).data);
    }
    return DataSuccess<List<AssessmentPeriod>>(AssessmentPeriods.of(every));
  }

  /// The report of each class that has the period [toKey]; a class
  /// without [fromKey] is reported on [toKey] alone.
  Future<DataState<List<ClassProgressReport>>> _classReports(
    String? fromKey,
    String toKey,
  ) async {
    final DataState<List<ClassroomSummary>> classes = await _getClassrooms();
    if (classes case DataFailed<List<ClassroomSummary>>(:final exception)) {
      return DataFailed<List<ClassProgressReport>>(exception);
    }
    final List<ClassProgressReport> reports = <ClassProgressReport>[];
    for (final ClassroomSummary summary
        in (classes as DataSuccess<List<ClassroomSummary>>).data) {
      final DataState<ClassProgressReport> report = await _reportOf(
        summary.classroom.id,
        fromKey,
        toKey,
      );
      switch (report) {
        case DataSuccess<ClassProgressReport>(:final data):
          reports.add(data);
        case DataFailed<ClassProgressReport>(:final exception)
            when exception is NotFoundException:
          continue;
        case DataFailed<ClassProgressReport>(:final exception):
          return DataFailed<List<ClassProgressReport>>(exception);
      }
    }
    return DataSuccess<List<ClassProgressReport>>(reports);
  }

  Future<DataState<ClassProgressReport>> _reportOf(
    String classroomId,
    String? fromKey,
    String toKey,
  ) async {
    final DataState<ClassProgressReport> both = await _getClassReport(
      params: (classroomId: classroomId, fromKey: fromKey, toKey: toKey),
    );
    if (fromKey == null || both is! DataFailed<ClassProgressReport>) {
      return both;
    }
    return _getClassReport(
      params: (classroomId: classroomId, fromKey: null, toKey: toKey),
    );
  }
}
