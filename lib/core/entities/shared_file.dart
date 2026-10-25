import 'package:meta/meta.dart';

/// A file made by the app to go to the share sheet, such as a report in
/// PDF or CSV.
@immutable
final class SharedFile {
  /// Creates the file [name] holding [bytes] of the type [mimeType].
  const SharedFile({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  /// Media type of a PDF document.
  static const String pdfType = 'application/pdf';

  /// Media type of a CSV table.
  static const String csvType = 'text/csv';

  /// Name of the file, with its extension.
  final String name;

  /// Content of the file.
  final List<int> bytes;

  /// Media type of the content.
  final String mimeType;

  @override
  String toString() => 'SharedFile($name, ${bytes.length} bytes)';
}
