import 'package:json_annotation/json_annotation.dart';

part 'assessment_result_local_model.g.dart';

/// Row of the `assessment_result` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class AssessmentResultLocalModel {
  /// Creates a row with every column given.
  const AssessmentResultLocalModel({
    required this.assessmentId,
    required this.profileId,
    required this.takenAt,
    required this.wordCount,
    required this.understoodWordCount,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory AssessmentResultLocalModel.fromJson(Map<String, Object?> json) =>
      _$AssessmentResultLocalModelFromJson(json);

  /// Assessment taken.
  final String assessmentId;

  /// Pupil who took it.
  final String profileId;

  /// When it was finished, in milliseconds since epoch.
  final int takenAt;

  /// Words of the word check asked.
  final int wordCount;

  /// Words of the word check understood.
  final int understoodWordCount;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$AssessmentResultLocalModelToJson(this);
}
