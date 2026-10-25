import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/export_mark.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';

/// Remembers that the teacher's tablet read the QR code of a class up to
/// [sequence]: the next code, or the next file, starts after it.
class ConfirmResultsQrUseCase
    implements UseCase<DataState<void>, ({String classroomId, int sequence})> {
  /// Creates the use case.
  const ConfirmResultsQrUseCase({
    required this._transfers,
    required this._clock,
  });

  final ClassroomTransferRepository _transfers;
  final Clock _clock;

  @override
  Future<DataState<void>> call({
    required ({String classroomId, int sequence}) params,
  }) {
    return _transfers.saveExportMark(
      classroomId: params.classroomId,
      mark: ExportMark(sequence: params.sequence, exportedAt: _clock.now()),
    );
  }
}
