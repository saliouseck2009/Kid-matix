import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_program_report_use_case.dart';

/// Reads the periods of every class of the device for the school or
/// program report: `null` while reading, empty when there is none or
/// they cannot be read.
final class ProgramPeriodsCubit extends Cubit<List<AssessmentPeriod>?> {
  /// Creates the Cubit.
  ProgramPeriodsCubit({required this._getReport}) : super(null);

  final GetProgramReportUseCase _getReport;

  /// Reads the periods.
  Future<void> load() async {
    final DataState<List<AssessmentPeriod>> read = await _getReport
        .readPeriods();
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<List<AssessmentPeriod>>(:final data) => data,
      DataFailed<List<AssessmentPeriod>>() => const <AssessmentPeriod>[],
    });
  }
}
