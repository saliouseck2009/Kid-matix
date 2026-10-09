import 'package:json_annotation/json_annotation.dart';

/// Stores a `bool` as the 0 or 1 SQLite uses.
final class SqliteBoolConverter implements JsonConverter<bool, int> {
  /// Creates the converter.
  const SqliteBoolConverter();

  @override
  bool fromJson(int json) => json != 0;

  @override
  int toJson(bool object) => object ? 1 : 0;
}
