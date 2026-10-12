import 'package:meta/meta.dart';

/// What a player has to review in a learning domain.
@immutable
final class ReviewOverview {
  /// Creates the overview.
  const ReviewOverview({required this.dueCount, required this.seenCount});

  /// Items whose review date has passed.
  final int dueCount;

  /// Items already presented to the player.
  final int seenCount;

  /// Whether the player has been asked at least one item, so a review
  /// has something to ask.
  bool get hasSeenItems => seenCount > 0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReviewOverview &&
            other.dueCount == dueCount &&
            other.seenCount == seenCount;
  }

  @override
  int get hashCode => Object.hash(dueCount, seenCount);

  @override
  String toString() => 'ReviewOverview($dueCount due, $seenCount seen)';
}
