import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/storage/shared_file_data_source.dart';
import 'package:share_plus/share_plus.dart';

/// [SharedFileDataSource] over `share_plus` and `file_selector`.
///
/// The picker accepts any file: messaging apps and file managers do not
/// keep a custom type, so the content is checked instead.
final class SharedFileDataSourceImpl implements SharedFileDataSource {
  /// Creates the data source.
  const SharedFileDataSourceImpl();

  /// Media type of a backup file: JSON text.
  static const String mimeType = 'application/json';

  // Far above the backup of years of play (a few hundred kilobytes).
  static const int _maxFileBytes = 20 * 1024 * 1024;

  @override
  Future<bool> shareFile({
    required String fileName,
    required String content,
  }) async {
    final ShareResult result = await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile.fromData(
            utf8.encode(content),
            name: fileName,
            mimeType: mimeType,
          ),
        ],
        fileNameOverrides: <String>[fileName],
      ),
    );
    return result.status == ShareResultStatus.success;
  }

  @override
  Future<String?> pickFile() async {
    final XFile? file = await openFile();
    if (file == null) return null;
    if (await file.length() > _maxFileBytes) {
      throw const FileTooBigException(message: 'File too big.');
    }
    try {
      return utf8.decode(await file.readAsBytes());
    } on FormatException catch (error) {
      throw InvalidFileException(message: error.message);
    }
  }
}
