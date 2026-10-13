import 'package:json_annotation/json_annotation.dart';

part 'backup_header_model.g.dart';

/// The two keys of a file read before anything else: what it is and
/// which version of the format wrote it, so a newer file is refused
/// before its content is read.
@JsonSerializable()
final class BackupHeaderModel {
  /// Creates the header.
  const BackupHeaderModel({this.format, this.version});

  /// Reads the header of a file.
  factory BackupHeaderModel.fromJson(Map<String, Object?> json) =>
      _$BackupHeaderModelFromJson(json);

  /// Kind of file, or `null` when missing.
  final String? format;

  /// Version of the format, or `null` when missing.
  final int? version;

  /// Returns the JSON object of the header.
  Map<String, Object?> toJson() => _$BackupHeaderModelToJson(this);
}
