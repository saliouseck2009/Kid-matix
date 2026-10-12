// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_backup_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileBackupFileModel _$ProfileBackupFileModelFromJson(
  Map<String, dynamic> json,
) => ProfileBackupFileModel(
  format: json['format'] as String,
  version: (json['version'] as num).toInt(),
  exportedAt: json['exportedAt'] as String,
  appVersion: json['appVersion'] as String,
  sections: json['sections'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ProfileBackupFileModelToJson(
  ProfileBackupFileModel instance,
) => <String, dynamic>{
  'format': instance.format,
  'version': instance.version,
  'exportedAt': instance.exportedAt,
  'appVersion': instance.appVersion,
  'sections': instance.sections,
};
