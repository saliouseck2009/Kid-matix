import 'package:json_annotation/json_annotation.dart';

part 'placement_local_model.g.dart';

/// Row of the `stage_progress` table for a unit opened by the placement
/// test: its `stage` is `placement`, with no star.
@JsonSerializable(fieldRename: FieldRename.snake)
final class PlacementLocalModel {
  /// Creates a row with every column given.
  const PlacementLocalModel({
    required this.profileId,
    required this.domainId,
    required this.unitKey,
    required this.completedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory PlacementLocalModel.fromJson(Map<String, Object?> json) =>
      _$PlacementLocalModelFromJson(json);

  /// Player.
  final String profileId;

  /// Learning domain.
  final String domainId;

  /// Unit opened, such as `mul:7`.
  final String unitKey;

  /// When the test opened it, in milliseconds since epoch.
  final int completedAt;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$PlacementLocalModelToJson(this);
}
