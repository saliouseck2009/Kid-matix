import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/storage/sqlite_bool_converter.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';

part 'quiz_answer_local_model.g.dart';

/// Row of the `quiz_answer` table.
@JsonSerializable(fieldRename: FieldRename.snake)
@SqliteBoolConverter()
final class QuizAnswerLocalModel {
  /// Creates a row with every column given.
  const QuizAnswerLocalModel({
    required this.sessionId,
    required this.position,
    required this.itemKey,
    required this.questionTypeId,
    required this.isCorrect,
    required this.isTimedOut,
    required this.isRetry,
    required this.answerTimeMs,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Builds the row of [answer], the [position]th of [sessionId].
  factory QuizAnswerLocalModel.fromEntity({
    required QuizAnswerEntity answer,
    required String sessionId,
    required int position,
    required DateTime updatedAt,
  }) {
    return QuizAnswerLocalModel(
      sessionId: sessionId,
      position: position,
      itemKey: answer.itemKey,
      questionTypeId: answer.questionTypeId,
      isCorrect: answer.isCorrect,
      isTimedOut: answer.isTimedOut,
      isRetry: answer.isRetry,
      answerTimeMs: answer.answerTime.inMilliseconds,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory QuizAnswerLocalModel.fromJson(Map<String, Object?> json) =>
      _$QuizAnswerLocalModelFromJson(json);

  /// Session of the answer.
  final String sessionId;

  /// Order of the answer in the session, from 1.
  final int position;

  /// Item asked.
  final String itemKey;

  /// Type of the question asked.
  final String questionTypeId;

  /// Whether the answer was right.
  final bool isCorrect;

  /// Whether the timer ran out.
  final bool isTimedOut;

  /// Whether it was a second chance.
  final bool isRetry;

  /// Answer time in milliseconds.
  final int answerTimeMs;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$QuizAnswerLocalModelToJson(this);

  /// Returns the domain answer of this row.
  QuizAnswerEntity toEntity() {
    return QuizAnswerEntity(
      itemKey: itemKey,
      questionTypeId: questionTypeId,
      isCorrect: isCorrect,
      isTimedOut: isTimedOut,
      isRetry: isRetry,
      answerTime: Duration(milliseconds: answerTimeMs),
    );
  }
}
