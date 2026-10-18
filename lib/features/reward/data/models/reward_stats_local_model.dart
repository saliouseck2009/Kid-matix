import 'package:json_annotation/json_annotation.dart';

part 'reward_stats_local_model.g.dart';

/// Row of the `reward_stats` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class RewardStatsLocalModel {
  /// Creates a row with every column given.
  const RewardStatsLocalModel({
    required this.profileId,
    required this.lightningAnswers,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Reads a row returned by `sqflite`.
  factory RewardStatsLocalModel.fromJson(Map<String, Object?> json) =>
      _$RewardStatsLocalModelFromJson(json);

  /// Player.
  final String profileId;

  /// Lightning answers given so far, for the Éclair badge.
  final int lightningAnswers;

  /// Last change of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$RewardStatsLocalModelToJson(this);
}
