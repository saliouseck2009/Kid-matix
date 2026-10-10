import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';

part 'item_progress_local_model.g.dart';

/// Row of the `item_progress` table.
@JsonSerializable(fieldRename: FieldRename.snake)
final class ItemProgressLocalModel {
  /// Creates a row with every column given.
  const ItemProgressLocalModel({
    required this.profileId,
    required this.domainId,
    required this.itemKey,
    required this.presentationCount,
    required this.correctCount,
    required this.lastAnswerTimesMs,
    required this.box,
    required this.updatedAt,
    this.nextReviewAt,
    this.deletedAt,
  });

  /// Builds the row of [progress], written at [updatedAt].
  factory ItemProgressLocalModel.fromEntity({
    required ItemProgressEntity progress,
    required DateTime updatedAt,
  }) {
    return ItemProgressLocalModel(
      profileId: progress.profileId,
      domainId: progress.domainId,
      itemKey: progress.itemKey,
      presentationCount: progress.presentationCount,
      correctCount: progress.correctCount,
      lastAnswerTimesMs: progress.lastAnswerTimes
          .map((Duration time) => time.inMilliseconds)
          .join(timeSeparator),
      box: progress.box,
      nextReviewAt: progress.nextReviewAt?.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  /// Reads a row returned by `sqflite`.
  factory ItemProgressLocalModel.fromJson(Map<String, Object?> json) =>
      _$ItemProgressLocalModelFromJson(json);

  /// Separator of the answer times in [lastAnswerTimesMs].
  static const String timeSeparator = ',';

  /// Player of the row.
  final String profileId;

  /// Learning domain of the item.
  final String domainId;

  /// Key of the item.
  final String itemKey;

  /// Times the item was asked.
  final int presentationCount;

  /// Right answers among them.
  final int correctCount;

  /// Last answer times in milliseconds, oldest first, separated by
  /// [timeSeparator]; empty without any answer.
  final String lastAnswerTimesMs;

  /// Review box, from 0 to 5.
  final int box;

  /// Start of the review day, in milliseconds since epoch.
  final int? nextReviewAt;

  /// Write time of the row, in milliseconds since epoch.
  final int updatedAt;

  /// Soft deletion date, or `null` for a live row.
  final int? deletedAt;

  /// Returns the columns to write with `sqflite`.
  Map<String, Object?> toJson() => _$ItemProgressLocalModelToJson(this);

  /// Returns the domain progress of this row.
  ItemProgressEntity toEntity() {
    final int? reviewAt = nextReviewAt;
    return ItemProgressEntity(
      profileId: profileId,
      domainId: domainId,
      itemKey: itemKey,
      presentationCount: presentationCount,
      correctCount: correctCount,
      lastAnswerTimes: lastAnswerTimesMs.isEmpty
          ? const <Duration>[]
          : lastAnswerTimesMs
                .split(timeSeparator)
                .map((String ms) => Duration(milliseconds: int.parse(ms)))
                .toList(),
      box: box,
      nextReviewAt: reviewAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(reviewAt),
    );
  }
}
