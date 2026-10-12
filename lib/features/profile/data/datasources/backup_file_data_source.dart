/// The files of the system: the share sheet and the file picker.
abstract interface class BackupFileDataSource {
  /// Opens the share sheet with a file named [fileName] holding
  /// [content]; returns whether the player shared it.
  Future<bool> shareFile({required String fileName, required String content});

  /// Opens the file picker and returns the text of the file chosen, or
  /// `null` when none was chosen.
  ///
  /// Throws an `InvalidFileException` when the file is too big or is not
  /// text.
  Future<String?> pickFile();
}
