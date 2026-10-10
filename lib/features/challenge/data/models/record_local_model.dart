import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';

part 'record_local_model.g.dart';

/// Row of the `record` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class RecordLocalModel {
  /// Creates a row with every column given.
  const RecordLocalModel({
    required this.profileId,
    required this.mode,
    required this.bestScore,
    required this.sessionId,
    required this.achievedAt,
    required this.updatedAt,
    this.previousBest,
    this.deletedAt,
  });

  /// Builds the row of [record] for [profileId], written at [updatedAt].
  factory RecordLocalModel.fromEntity({
    required String profileId,
    required RecordEntity record,
    required DateTime updatedAt,
  }) {
    return RecordLocalModel(
      profileId: profileId,
      mode: record.mode,
      bestScore: record.bestScore,
      sessionId: record.sessionId,
      achievedAt: record.achievedAt.millisecondsSinceEpoch,
      previousBest: record.previousBest,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory RecordLocalModel.fromJson(Map<String, Object?> json) =>
      _$RecordLocalModelFromJson(json);

  /// Player.
  final String profileId;

  /// Mode of the record.
  final QuizMode mode;

  /// Best score.
  final int bestScore;

  /// Session that set the record.
  final String sessionId;

  /// When the record was set, in milliseconds since epoch.
  final int achievedAt;

  /// Record beaten by this one, or `null` for a first record.
  final int? previousBest;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$RecordLocalModelToJson(this);

  /// Returns the record of this row.
  RecordEntity toEntity() {
    return RecordEntity(
      mode: mode,
      bestScore: bestScore,
      sessionId: sessionId,
      achievedAt: DateTime.fromMillisecondsSinceEpoch(achievedAt),
      previousBest: previousBest,
    );
  }
}
