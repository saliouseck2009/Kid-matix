import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_transfer.dart';
import 'package:kid_matix/features/classroom/domain/entities/export_mark.dart';

/// The class files: written to the share sheet, read from the file
/// picker; no network.
abstract interface class ClassroomTransferRepository {
  /// Writes [transfer] to a versioned file and opens the share sheet;
  /// resolves to whether the teacher shared it.
  Future<DataState<bool>> share({required ClassroomTransfer transfer});

  /// Opens the file picker and reads the class file chosen, or `null`
  /// when none was chosen.
  ///
  /// Fails with an `InvalidFileException` when the file is no class file
  /// or is damaged, and an `UnsupportedVersionException` when a newer
  /// app wrote it.
  Future<DataState<ClassroomTransfer?>> pick();

  /// Returns the mark of the last file of the class [classroomId] sent
  /// from this tablet, or `null` before its first file.
  Future<DataState<ExportMark?>> readExportMark({
    required String classroomId,
  });

  /// Remembers [mark] for the class [classroomId], once its file was
  /// shared.
  Future<DataState<void>> saveExportMark({
    required String classroomId,
    required ExportMark mark,
  });
}
