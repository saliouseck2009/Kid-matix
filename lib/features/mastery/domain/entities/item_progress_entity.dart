import 'package:meta/meta.dart';

/// How well a player knows one item, such as the fact 7 x 8.
///
/// Created at the first presentation of the item, then updated by
/// `MasteryPolicy` after each answer.
@immutable
final class ItemProgressEntity {
  /// Creates the progress with every field given.
  ItemProgressEntity({
    required this.profileId,
    required this.domainId,
    required this.itemKey,
    required this.presentationCount,
    required this.correctCount,
    required List<Duration> lastAnswerTimes,
    required this.box,
    this.nextReviewAt,
  }) : lastAnswerTimes = List<Duration>.unmodifiable(lastAnswerTimes);

  /// Creates the progress of an item never presented: box 0, no answer.
  const ItemProgressEntity.notSeen({
    required this.profileId,
    required this.domainId,
    required this.itemKey,
  }) : presentationCount = 0,
       correctCount = 0,
       lastAnswerTimes = const <Duration>[],
       box = 0,
       nextReviewAt = null;

  /// Player the progress belongs to.
  final String profileId;

  /// Learning domain of the item.
  final String domainId;

  /// Key of the item, such as `mul:7x8`.
  final String itemKey;

  /// Times the item was asked.
  final int presentationCount;

  /// Right answers among them.
  final int correctCount;

  /// Answer times of the last answers, oldest first, at most
  /// `MasteryPolicy.answerTimeCount`.
  final List<Duration> lastAnswerTimes;

  /// Review box, from 0 (never presented) to 5.
  final int box;

  /// Day from which the item is due again, or `null` before its first
  /// answer.
  final DateTime? nextReviewAt;

  /// Median of [lastAnswerTimes], or `null` without any answer.
  Duration? get medianAnswerTime {
    if (lastAnswerTimes.isEmpty) return null;
    final List<Duration> sorted = List<Duration>.of(lastAnswerTimes)..sort();
    final int middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[middle];
    return (sorted[middle - 1] + sorted[middle]) ~/ 2;
  }

  /// Returns a copy with the given fields replaced.
  ItemProgressEntity copyWith({
    int? presentationCount,
    int? correctCount,
    List<Duration>? lastAnswerTimes,
    int? box,
    DateTime? nextReviewAt,
  }) {
    return ItemProgressEntity(
      profileId: profileId,
      domainId: domainId,
      itemKey: itemKey,
      presentationCount: presentationCount ?? this.presentationCount,
      correctCount: correctCount ?? this.correctCount,
      lastAnswerTimes: lastAnswerTimes ?? this.lastAnswerTimes,
      box: box ?? this.box,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ItemProgressEntity &&
            other.profileId == profileId &&
            other.domainId == domainId &&
            other.itemKey == itemKey &&
            other.presentationCount == presentationCount &&
            other.correctCount == correctCount &&
            _isSameList(other.lastAnswerTimes, lastAnswerTimes) &&
            other.box == box &&
            other.nextReviewAt == nextReviewAt;
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    domainId,
    itemKey,
    presentationCount,
    correctCount,
    Object.hashAll(lastAnswerTimes),
    box,
    nextReviewAt,
  );

  static bool _isSameList(List<Duration> a, List<Duration> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
