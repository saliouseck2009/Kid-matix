import 'package:json_annotation/json_annotation.dart';

part 'profile_backup_file_model.g.dart';

/// Content of a backup file (`.kidmatix`): a JSON object naming its
/// format and version, then one section per feature.
///
/// The [version] goes up whenever an older app would lose or misread
/// the content; a newer app reads every older version, missing sections
/// counting as empty. Keys a reader does not know are ignored.
@JsonSerializable()
final class ProfileBackupFileModel {
  /// Creates the content of a file.
  const ProfileBackupFileModel({
    required this.format,
    required this.version,
    required this.exportedAt,
    required this.appVersion,
    required this.sections,
  });

  /// Reads the content of a file.
  factory ProfileBackupFileModel.fromJson(Map<String, Object?> json) =>
      _$ProfileBackupFileModelFromJson(json);

  /// Value of [format] in every backup of a player.
  static const String formatName = 'kidmatix-profile';

  /// Version of the format this app writes, and the newest it reads.
  static const int currentVersion = 2;

  /// Kind of file, [formatName].
  final String format;

  /// Version of the format.
  final int version;

  /// When the file was written, in ISO 8601 with its time zone.
  final String exportedAt;

  /// Version of the app that wrote it, for information.
  final String appVersion;

  /// One entry per feature, by section name.
  final Map<String, Object?> sections;

  /// Returns the JSON object of the file.
  Map<String, Object?> toJson() => _$ProfileBackupFileModelToJson(this);
}
