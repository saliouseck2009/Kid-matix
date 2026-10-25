import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/repositories/report_share_repository.dart';

/// Sends files made in the teacher area, such as a report and its
/// anonymous version, to the share sheet together; resolves to whether
/// they were shared.
class ShareFilesUseCase implements UseCase<DataState<bool>, List<SharedFile>> {
  /// Creates the use case.
  const ShareFilesUseCase({required this._repository});

  final ReportShareRepository _repository;

  @override
  Future<DataState<bool>> call({required List<SharedFile> params}) {
    return _repository.share(files: params);
  }
}
