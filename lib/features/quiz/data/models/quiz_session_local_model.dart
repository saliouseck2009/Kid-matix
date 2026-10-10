import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';

part 'quiz_session_local_model.g.dart';

/// Row of the `quiz_session` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class QuizSessionLocalModel {
  /// Creates a row with every column given.
  const QuizSessionLocalModel({
    required this.id,
    required this.profileId,
    required this.domainId,
    required this.mode,
    required this.status,
    required this.startedAt,
    required this.durationMs,
    required this.questionCount,
    required this.correctCount,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Builds the row of [session], written at [updatedAt].
  factory QuizSessionLocalModel.fromEntity({
    required QuizSessionEntity session,
    required DateTime updatedAt,
  }) {
    return QuizSessionLocalModel(
      id: session.id,
      profileId: session.profileId,
      domainId: session.domainId,
      mode: session.mode,
      status: session.status,
      startedAt: session.startedAt.millisecondsSinceEpoch,
      durationMs: session.duration.inMilliseconds,
      questionCount: session.questionCount,
      correctCount: session.correctCount,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory QuizSessionLocalModel.fromJson(Map<String, Object?> json) =>
      _$QuizSessionLocalModelFromJson(json);

  /// Primary key, a UUID.
  final String id;

  /// Player of the session.
  final String profileId;

  /// Learning domain.
  final String domainId;

  /// How the quiz was started, stored by name.
  final QuizMode mode;

  /// How the session ended, stored by name.
  final QuizSessionStatus status;

  /// Start, in milliseconds since epoch.
  final int startedAt;

  /// Length of the session in milliseconds.
  final int durationMs;

  /// Scored questions answered.
  final int questionCount;

  /// Right answers among them.
  final int correctCount;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$QuizSessionLocalModelToJson(this);

  /// Returns the domain session of this row.
  QuizSessionEntity toEntity() {
    return QuizSessionEntity(
      id: id,
      profileId: profileId,
      domainId: domainId,
      mode: mode,
      status: status,
      startedAt: DateTime.fromMillisecondsSinceEpoch(startedAt),
      duration: Duration(milliseconds: durationMs),
      questionCount: questionCount,
      correctCount: correctCount,
    );
  }
}
