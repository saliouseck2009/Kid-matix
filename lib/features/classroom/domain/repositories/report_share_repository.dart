import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/error/data_state.dart';

/// The files of the teacher area: reports, sheets and audio packs sent
/// to the share sheet, packs read from the file picker; no network.
abstract interface class ReportShareRepository {
  /// Opens the share sheet with [files] together; resolves to whether
  /// the teacher shared them.
  Future<DataState<bool>> share({required List<SharedFile> files});

  /// Opens the file picker; resolves to the bytes of the file chosen, or
  /// `null` when none was. Fails with a `FileTooBigException`.
  Future<DataState<List<int>?>> pick();
}
