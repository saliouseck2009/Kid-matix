import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';

/// Chooses the items of a review among those already presented.
///
/// The items whose review date has passed come first, the longest
/// overdue first; then the other items, the lowest success rate first.
/// An item never presented is never reviewed.
final class ReviewItemSelector {
  /// Creates the selector.
  const ReviewItemSelector({this._policy = const MasteryPolicy()});

  final MasteryPolicy _policy;

  /// The items of [progress] due at [now]: the longest overdue first,
  /// then, on the same day, the lowest success rate first.
  List<ItemProgressEntity> dueOf({
    required Iterable<ItemProgressEntity> progress,
    required DateTime now,
  }) {
    return progress
        .where(
          (ItemProgressEntity item) =>
              _isSeen(item) && _policy.isDue(progress: item, now: now),
        )
        .toList()
      ..sort(_compareDue);
  }

  /// At most [count] items of [progress] to review at [now], each once:
  /// the due items first, then the weakest of the others.
  List<ItemProgressEntity> select({
    required Iterable<ItemProgressEntity> progress,
    required DateTime now,
    required int count,
  }) {
    final List<ItemProgressEntity> due = dueOf(progress: progress, now: now);
    final Set<String> dueKeys = <String>{
      for (final ItemProgressEntity item in due) item.itemKey,
    };
    final List<ItemProgressEntity> others =
        progress
            .where(
              (ItemProgressEntity item) =>
                  _isSeen(item) && !dueKeys.contains(item.itemKey),
            )
            .toList()
          ..sort(_compareWeakest);
    return <ItemProgressEntity>[...due, ...others].take(count).toList();
  }

  /// Whether [item] has been presented, so it can be reviewed.
  static bool _isSeen(ItemProgressEntity item) {
    return item.box >= MasteryPolicy.firstBox;
  }

  static int _compareDue(ItemProgressEntity a, ItemProgressEntity b) {
    final int byDate = a.nextReviewAt!.compareTo(b.nextReviewAt!);
    if (byDate != 0) return byDate;
    return _compareWeakest(a, b);
  }

  /// Lowest success rate first, then lowest box, then key order so the
  /// choice never depends on the storage order.
  static int _compareWeakest(ItemProgressEntity a, ItemProgressEntity b) {
    final int byRate = _successRate(a).compareTo(_successRate(b));
    if (byRate != 0) return byRate;
    final int byBox = a.box.compareTo(b.box);
    if (byBox != 0) return byBox;
    return a.itemKey.compareTo(b.itemKey);
  }

  static double _successRate(ItemProgressEntity item) {
    if (item.presentationCount == 0) return 0;
    return item.correctCount / item.presentationCount;
  }
}
