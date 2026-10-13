/// Reads the content of a backup section, refusing a malformed one with
/// a [FormatException].
///
/// Rows are decoded by the local models of the owning feature, which
/// check every column's type; unknown columns are ignored.
abstract final class BackupSectionReader {
  /// Decodes the list of rows under [key] with [fromJson]; no rows when
  /// the key is missing.
  static List<T> readRows<T>(
    Map<String, Object?> content, {
    required String key,
    required T Function(Map<String, Object?> row) fromJson,
  }) {
    final Object? value = content[key];
    if (value == null) return <T>[];
    if (value is! List<Object?>) {
      throw FormatException('Section key $key is not a list.');
    }
    return value
        .map((Object? row) => _decode(_rowOf(row, key), fromJson))
        .toList();
  }

  /// Decodes the single row under [key] with [fromJson], or returns
  /// `null` when there is none.
  static T? readRow<T>(
    Map<String, Object?> content, {
    required String key,
    required T Function(Map<String, Object?> row) fromJson,
  }) {
    final Object? value = content[key];
    if (value == null) return null;
    return _decode(_rowOf(value, key), fromJson);
  }

  /// Returns the text under [key], or `null` when there is none.
  static String? readText(Map<String, Object?> content, {required String key}) {
    final Object? value = content[key];
    if (value == null || value is String) return value as String?;
    throw FormatException('Section key $key is not a text.');
  }

  static Map<String, Object?> _rowOf(Object? value, String key) {
    if (value is Map<String, Object?>) return value;
    throw FormatException('A row of $key is not an object.');
  }

  static T _decode<T>(
    Map<String, Object?> row,
    T Function(Map<String, Object?> row) fromJson,
  ) {
    try {
      return fromJson(row);
    } on TypeError catch (error) {
      throw FormatException('Malformed row: $error');
    } on ArgumentError catch (error) {
      throw FormatException('Malformed row: $error');
    }
  }
}
