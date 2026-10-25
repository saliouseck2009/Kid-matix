import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/storage/sqlite_bool_converter.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_word.dart';

part 'assessment_word_local_model.g.dart';

/// Row of the `assessment_word` table.
@JsonSerializable(fieldRename: FieldRename.snake)
@SqliteBoolConverter()
final class AssessmentWordLocalModel {
  /// Creates a row with every column given.
  const AssessmentWordLocalModel({
    required this.assessmentId,
    required this.profileId,
    required this.itemKey,
    required this.isUnderstood,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory AssessmentWordLocalModel.fromJson(Map<String, Object?> json) =>
      _$AssessmentWordLocalModelFromJson(json);

  /// Assessment taken.
  final String assessmentId;

  /// Pupil who took it.
  final String profileId;

  /// Item of the math words asked.
  final String itemKey;

  /// Whether the pupil's first answer was right.
  final bool isUnderstood;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$AssessmentWordLocalModelToJson(this);

  /// Returns the word of this row.
  AssessmentWord toEntity() {
    return AssessmentWord(itemKey: itemKey, isUnderstood: isUnderstood);
  }
}
