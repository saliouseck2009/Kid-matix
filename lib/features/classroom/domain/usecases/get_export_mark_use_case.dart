import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/export_mark.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';

/// Returns where the last file of a class sent from this tablet stopped,
/// or `null` before its first file.
///
/// Takes the identifier of the class.
class GetExportMarkUseCase implements UseCase<DataState<ExportMark?>, String> {
  /// Creates the use case.
  const GetExportMarkUseCase({required this._transfers});

  final ClassroomTransferRepository _transfers;

  @override
  Future<DataState<ExportMark?>> call({required String params}) {
    return _transfers.readExportMark(classroomId: params);
  }
}
