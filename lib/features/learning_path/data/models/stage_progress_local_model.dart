import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';

part 'stage_progress_local_model.g.dart';

/// Row of the `stage_progress` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class StageProgressLocalModel {
  /// Creates a row with every column given.
  const StageProgressLocalModel({
    required this.profileId,
    required this.domainId,
    required this.unitKey,
    required this.stage,
    required this.bestStars,
    required this.bestScore,
    required this.completedAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory StageProgressLocalModel.fromJson(Map<String, Object?> json) =>
      _$StageProgressLocalModelFromJson(json);

  /// Player.
  final String profileId;

  /// Learning domain.
  final String domainId;

  /// Key of the table or of the review.
  final String unitKey;

  /// Stage, stored by name.
  final StageKind stage;

  /// Best stars earned.
  final int bestStars;

  /// Best number of right answers.
  final int bestScore;

  /// First completion, in milliseconds since epoch.
  final int completedAt;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$StageProgressLocalModelToJson(this);

  /// Returns the domain progress of this row.
  StageProgressEntity toEntity() {
    return StageProgressEntity(
      profileId: profileId,
      domainId: domainId,
      unitKey: unitKey,
      stage: stage,
      bestStars: bestStars,
      bestScore: bestScore,
      completedAt: DateTime.fromMillisecondsSinceEpoch(completedAt),
    );
  }
}
