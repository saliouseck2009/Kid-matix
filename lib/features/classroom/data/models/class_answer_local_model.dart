import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/storage/sqlite_bool_converter.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';

part 'class_answer_local_model.g.dart';

/// Row of the `class_answer` table.
@JsonSerializable(fieldRename: FieldRename.snake)
@SqliteBoolConverter()
final class ClassAnswerLocalModel {
  /// Creates a row with every column given.
  const ClassAnswerLocalModel({
    required this.sessionId,
    required this.position,
    required this.itemKey,
    required this.isCorrect,
    required this.isRetry,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Builds the row of [answer] of the session [sessionId].
  factory ClassAnswerLocalModel.fromEntity(
    PracticeAnswer answer, {
    required String sessionId,
    required DateTime updatedAt,
  }) {
    return ClassAnswerLocalModel(
      sessionId: sessionId,
      position: answer.position,
      itemKey: answer.itemKey,
      isCorrect: answer.isCorrect,
      isRetry: answer.isRetry,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite` or a class file.
  factory ClassAnswerLocalModel.fromJson(Map<String, Object?> json) =>
      _$ClassAnswerLocalModelFromJson(json);

  /// Session of the answer.
  final String sessionId;

  /// Order of the answer in the session, from 1.
  final int position;

  /// Item asked.
  final String itemKey;

  /// Whether the answer was right.
  final bool isCorrect;

  /// Whether it was a second chance.
  final bool isRetry;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ClassAnswerLocalModelToJson(this);

  /// Returns the answer of this row.
  PracticeAnswer toEntity() {
    return PracticeAnswer(
      position: position,
      itemKey: itemKey,
      isCorrect: isCorrect,
      isRetry: isRetry,
    );
  }
}
