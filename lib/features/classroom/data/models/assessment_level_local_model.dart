import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';

part 'assessment_level_local_model.g.dart';

/// Row of the `assessment_level` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class AssessmentLevelLocalModel {
  /// Creates a row with every column given.
  const AssessmentLevelLocalModel({
    required this.assessmentId,
    required this.profileId,
    required this.domainId,
    required this.skillCount,
    required this.updatedAt,
    this.level,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory AssessmentLevelLocalModel.fromJson(Map<String, Object?> json) =>
      _$AssessmentLevelLocalModelFromJson(json);

  /// Assessment taken.
  final String assessmentId;

  /// Pupil who took it.
  final String profileId;

  /// Learning domain.
  final String domainId;

  /// Skills of the domain the pupil had, or `null` when not reached.
  final int? level;

  /// Skills the test checks in the domain.
  final int skillCount;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$AssessmentLevelLocalModelToJson(this);

  /// Returns the level of this row.
  DomainPlacement toEntity() {
    return DomainPlacement(
      domainId: domainId,
      level: level,
      skillCount: skillCount,
    );
  }
}
