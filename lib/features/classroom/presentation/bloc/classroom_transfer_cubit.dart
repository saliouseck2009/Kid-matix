import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/usecases/export_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/import_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/classroom_transfer_state.dart';

/// Sends a class to the share sheet, or receives a class file and merges
/// it, with no network.
final class ClassroomTransferCubit extends Cubit<ClassroomTransferState> {
  /// Creates the Cubit.
  ClassroomTransferCubit({required this._export, required this._import})
    : super(const ClassroomTransferIdle());

  final ExportClassroomUseCase _export;
  final ImportClassroomUseCase _import;

  /// Writes the file of the class [classroomId] and opens the share
  /// sheet: the results since the last file, or all of them when
  /// [isFull].
  Future<void> export(String classroomId, {bool isFull = false}) async {
    if (state is ClassroomTransferBusy) return;
    emit(const ClassroomTransferBusy());
    final DataState<bool> shared = await _export(
      params: (classroomId: classroomId, isFull: isFull),
    );
    if (isClosed) return;
    emit(switch (shared) {
      DataSuccess<bool>(data: true) => const ClassroomTransferShared(),
      DataSuccess<bool>() => const ClassroomTransferIdle(),
      DataFailed<bool>(:final exception) => ClassroomTransferFailed(
        errorCode: exception.code,
      ),
    });
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
