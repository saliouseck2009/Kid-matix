import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_merge_report.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/classroom_merger.dart';

/// Opens the file picker and merges the class file chosen into this
/// tablet, without duplicates; resolves to `null` when no file was
/// chosen.
class ImportClassroomUseCase
    implements NoParamUseCase<DataState<ClassroomMergeReport?>> {
  /// Creates the use case.
  const ImportClassroomUseCase({
    required this._transfers,
    required this._merger,
  });

  final ClassroomTransferRepository _transfers;
  final ClassroomMerger _merger;

  @override
  Future<DataState<ClassroomMergeReport?>> call() async {
    final DataState<ClassroomTransfer?> picked = await _transfers.pick();
    return switch (picked) {
      DataFailed<ClassroomTransfer?>(:final exception) =>
        DataFailed<ClassroomMergeReport?>(exception),
      DataSuccess<ClassroomTransfer?>(data: null) =>
        const DataSuccess<ClassroomMergeReport?>(null),
      DataSuccess<ClassroomTransfer?>(:final ClassroomTransfer data) =>
        switch (await _merger.merge(data)) {
          DataSuccess<ClassroomMergeReport>(:final data) =>
            DataSuccess<ClassroomMergeReport?>(data),
          DataFailed<ClassroomMergeReport>(:final exception) =>
            DataFailed<ClassroomMergeReport?>(exception),
        },
    };
  }
}
