// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_header_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupHeaderModel _$BackupHeaderModelFromJson(Map<String, dynamic> json) =>
    BackupHeaderModel(
      format: json['format'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BackupHeaderModelToJson(BackupHeaderModel instance) =>
    <String, dynamic>{'format': instance.format, 'version': instance.version};
