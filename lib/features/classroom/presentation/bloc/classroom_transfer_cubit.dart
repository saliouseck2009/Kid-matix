import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/export_mark.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_export_mark_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/export_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/import_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_transfer_state.dart';

/// Sends a class to the share sheet, or receives a class file and merges
/// it, with no network.
final class ClassroomTransferCubit extends Cubit<ClassroomTransferState> {
  /// Creates the Cubit.
  ClassroomTransferCubit({
    required this._export,
    required this._import,
    required this._getMark,
  }) : super(const ClassroomTransferIdle());

  final ExportClassroomUseCase _export;
  final ImportClassroomUseCase _import;
  final GetExportMarkUseCase _getMark;

  /// Reads when the class [classroomId] was last sent, for « depuis le
  /// … ».
  Future<void> loadMark(String classroomId) async {
    final DataState<ExportMark?> mark = await _getMark(params: classroomId);
    if (isClosed || state is! ClassroomTransferIdle) return;
    if (mark case DataSuccess<ExportMark?>(:final ExportMark data)) {
      emit(ClassroomTransferIdle(lastExportAt: data.exportedAt));
    }
  }

  /// Writes the file of the class [classroomId] and opens the share
  /// sheet: the results since the last file, or all of them when
  /// [isFull].
  Future<void> export(String classroomId, {bool isFull = false}) async {
    final ClassroomTransferState before = state;
    if (before is ClassroomTransferBusy) return;
    emit(const ClassroomTransferBusy());
    final DataState<bool> shared = await _export(
      params: (classroomId: classroomId, isFull: isFull),
    );
    if (isClosed) return;
    emit(switch (shared) {
      DataSuccess<bool>(data: true) => const ClassroomTransferShared(),
      DataSuccess<bool>() => ClassroomTransferIdle(
        lastExportAt: before is ClassroomTransferIdle
            ? before.lastExportAt
            : null,
      ),
      DataFailed<bool>(:final exception) => ClassroomTransferFailed(
        errorCode: exception.code,
      ),
    });
    if (shared case DataSuccess<bool>(data: true)) {
      emit(const ClassroomTransferIdle());
      await loadMark(classroomId);
    }
  }

  /// Opens the file picker and merges the class file chosen.
  Future<void> receive() async {
    if (state is ClassroomTransferBusy) return;
    emit(const ClassroomTransferBusy());
    final DataState<ClassroomMergeReport?> merged = await _import();
    if (isClosed) return;
    emit(switch (merged) {
      DataSuccess<ClassroomMergeReport?>(data: null) =>
        const ClassroomTransferIdle(),
      DataSuccess<ClassroomMergeReport?>(:final ClassroomMergeReport data) =>
        ClassroomTransferMerged(report: data),
      DataFailed<ClassroomMergeReport?>(:final exception) =>
        ClassroomTransferFailed(errorCode: exception.code),
    });
  }
}
