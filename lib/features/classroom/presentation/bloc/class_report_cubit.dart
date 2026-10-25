import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_progress_report.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_report_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/share_files_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_report_state.dart';

/// Turns a report into the files to share, in the language of the
/// screen.
typedef ReportRenderer = Future<List<SharedFile>> Function(
  ClassProgressReport report,
);

/// The report card of the class [classroomId]: the two periods compared,
/// then the report computed, made into files and shared.
final class ClassReportCubit extends Cubit<ClassReportState> {
  /// Creates the Cubit over the [periods] of the class (at least one),
  /// comparing the first and the last by default.
  ClassReportCubit({
    required this._classroomId,
    required List<AssessmentPeriod> periods,
    required this._getReport,
    required this._share,
  }) : super(
         ClassReportState(
           fromKey: periods.length > 1 ? periods.first.key : null,
           toKey: periods.last.key,
         ),
       );

  final String _classroomId;
  final GetClassReportUseCase _getReport;
  final ShareFilesUseCase _share;

  /// Compares the period [fromKey], or none, with [toKey].
  void choose({required String? fromKey, required String toKey}) {
    emit(
      state.withPeriods(
        fromKey: fromKey == toKey ? null : fromKey,
        toKey: toKey,
      ),
    );
  }

  /// Computes the report, makes its files with [render] and opens the
  /// share sheet.
  Future<void> export(ReportRenderer render) async {
    if (state.isBusy) return;
    emit(state.busy);
    final DataState<ClassProgressReport> report = await _getReport(
      params: (
        classroomId: _classroomId,
        fromKey: state.fromKey,
        toKey: state.toKey,
      ),
    );
    if (report case DataFailed<ClassProgressReport>(:final exception)) {
      if (!isClosed) {
        emit(state.done(ReportExportOutcome.failed, code: exception.code));
      }
      return;
    }
    final List<SharedFile>? files = await _render(
      render,
      (report as DataSuccess<ClassProgressReport>).data,
    );
    if (files == null) {
      if (!isClosed) emit(state.done(ReportExportOutcome.failed));
      return;
    }
    final DataState<bool> shared = await _share(params: files);
    if (isClosed) return;
    emit(switch (shared) {
      DataSuccess<bool>(data: true) => state.done(ReportExportOutcome.shared),
      DataSuccess<bool>() => state.withPeriods(
        fromKey: state.fromKey,
        toKey: state.toKey,
      ),
      DataFailed<bool>(:final exception) => state.done(
        ReportExportOutcome.failed,
        code: exception.code,
      ),
    });
  }

  /// The files [render] makes of [report], or `null` when it fails.
  static Future<List<SharedFile>?> _render(
    ReportRenderer render,
    ClassProgressReport report,
  ) async {
    try {
      return await render(report);
    } on Exception catch (error, stackTrace) {
      log(
        'Report files not made',
        name: 'classroom',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
