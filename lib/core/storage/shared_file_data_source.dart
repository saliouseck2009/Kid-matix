import 'package:kid_matix/core/entities/shared_file.dart';

/// The files of the system: the share sheet and the file picker, shared
/// by the profile backups (F20), the class files (F29) and the reports
/// (F31).
abstract interface class SharedFileDataSource {
  /// Opens the share sheet with a file named [fileName] holding
  /// [content]; returns whether the player shared it.
  Future<bool> shareFile({required String fileName, required String content});

  /// Opens the share sheet with [files] together, such as a report and
  /// its anonymous version; returns whether they were shared.
  Future<bool> shareFiles({required List<SharedFile> files});

  /// Opens the file picker and returns the text of the file chosen, or
  /// `null` when none was chosen.
  ///
  /// Throws a `FileTooBigException` when the file is too big and an
  /// `InvalidFileException` when it is not text.
  Future<String?> pickFile();

  /// Opens the file picker and returns the bytes of the file chosen, such
  /// as an audio pack, or `null` when none was chosen.
  ///
  /// Throws a `FileTooBigException` when the file is too big.
  Future<List<int>?> pickBytes();
}
