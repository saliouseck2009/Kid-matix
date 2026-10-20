import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';

part 'placement_result_local_model.g.dart';

/// Row of the `placement_result` table: the level of a player in one
/// domain at the end of one placement test.
@JsonSerializable(fieldRename: FieldRename.snake)
final class PlacementResultLocalModel {
  /// Creates a row with every column given.
  const PlacementResultLocalModel({
    required this.profileId,
    required this.takenAt,
    required this.domainId,
    required this.level,
    required this.skillCount,
    required this.unitCount,
    required this.updatedAt,
    this.startUnitKey,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory PlacementResultLocalModel.fromJson(Map<String, Object?> json) =>
      _$PlacementResultLocalModelFromJson(json);

  /// Player.
  final String profileId;

  /// When the test was finished, in milliseconds since epoch.
  final int takenAt;

  /// Learning domain.
  final String domainId;

  /// Skills of the domain the child had; `null` when the test did not
  /// reach the domain.
  final int? level;

  /// Skills the test checked in the domain.
  final int skillCount;

  /// Units of the domain the test opened.
  final int unitCount;

  /// Unit to start with, on the row of the domain recommended only.
  final String? startUnitKey;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$PlacementResultLocalModelToJson(this);

  /// Returns the level of this row.
  DomainResultEntity toEntity() {
    return DomainResultEntity(
      domainId: domainId,
      level: level,
      skillCount: skillCount,
      unitCount: unitCount,
      startUnitKey: startUnitKey,
    );
  }
}
