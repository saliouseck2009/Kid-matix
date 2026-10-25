import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The reports and sheets of the teacher area, sent to the share sheet;
/// no network.
abstract interface class ReportShareRepository {
  /// Opens the share sheet with [files] together; resolves to whether
  /// the teacher shared them.
  Future<DataState<bool>> share({required List<SharedFile> files});
}
