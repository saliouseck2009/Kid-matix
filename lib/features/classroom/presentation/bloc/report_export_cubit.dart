import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_period.dart';
import 'package:kid_matix/features/classroom/domain/usecases/share_files_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/report_export_state.dart';

/// Computes a report of type [R] between the periods [fromKey], or none,
/// and [toKey].
typedef ReportSource<R> = Future<DataState<R>> Function({
  String? fromKey,
  required String toKey,
});

/// Turns a report into the files to share, in the language of the
/// screen.
typedef ReportRenderer<R> = Future<List<SharedFile>> Function(R report);

/// A report card of the teacher area: the two periods compared, then the
/// report of type [R] computed, made into files and shared.
final class ReportExportCubit<R> extends Cubit<ReportExportState> {
  /// Creates the Cubit over [periods] (at least one), comparing the first
  /// and the last by default.
  ReportExportCubit({
    required List<AssessmentPeriod> periods,
    required this._source,
    required this._share,
  }) : super(
         ReportExportState(
           fromKey: periods.length > 1 ? periods.first.key : null,
           toKey: periods.last.key,
         ),
       );

  final ReportSource<R> _source;
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

  /// Exports the named version next time when [isNamed], else the
  /// anonymous one.
  void chooseVersion({required bool isNamed}) {
    emit(state.withVersion(isNamed: isNamed));
  }

  /// Computes the report, makes its files with [render] and opens the
  /// share sheet.
  Future<void> export(ReportRenderer<R> render) async {
    if (state.isBusy) return;
    emit(state.busy);
    final DataState<R> report = await _source(
      fromKey: state.fromKey,
      toKey: state.toKey,
    );
    if (report case DataFailed<R>(:final exception)) {
      if (!isClosed) {
        emit(state.done(ReportExportOutcome.failed, code: exception.code));
      }
      return;
    }
    final List<SharedFile>? files = await _render(
      render,
      (report as DataSuccess<R>).data,
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
  static Future<List<SharedFile>?> _render<R>(
    ReportRenderer<R> render,
    R report,
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
