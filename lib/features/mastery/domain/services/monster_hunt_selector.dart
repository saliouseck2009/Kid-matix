import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/monster_rule.dart';
import 'package:kid_matix/features/mastery/domain/services/review_item_selector.dart';

/// Chooses the questions of a monster hunt and their order.
///
/// Each monster [MonsterRule] shows is asked [asksPerMonster] times; the
/// other questions are the facts a review would pick, each once. The
/// order is random, and the same fact is never asked twice in a row.
final class MonsterHuntSelector {
  /// Creates the selector.
  const MonsterHuntSelector({
    this._rule = const MonsterRule(),
    this._review = const ReviewItemSelector(),
  });

  final MonsterRule _rule;
  final ReviewItemSelector _review;

  /// Times each monster is asked in a hunt.
  static const int asksPerMonster = 2;

  /// At most [count] questions of a hunt among [progress] at [now], in
  /// the order to ask them.
  List<ItemProgressEntity> select({
    required Iterable<ItemProgressEntity> progress,
    required DateTime now,
    required int count,
    required RandomSource random,
  }) {
    final List<ItemProgressEntity> monsters = _rule
        .wildOf(progress)
        .take(count ~/ asksPerMonster)
        .toList();
    final Set<String> monsterKeys = <String>{
      for (final ItemProgressEntity monster in monsters) monster.itemKey,
    };
    final List<ItemProgressEntity> others = _review.select(
      progress: progress.where(
        (ItemProgressEntity item) => !monsterKeys.contains(item.itemKey),
      ),
      now: now,
      count: count - monsters.length * asksPerMonster,
    );
    return _spreadApart(<ItemProgressEntity>[
      for (int ask = 0; ask < asksPerMonster; ask++) ...monsters,
      ...others,
    ], random);
  }

  /// [items] in a random order where no fact follows itself. A copy that
  /// can only follow itself, at the very end, is left out.
  List<ItemProgressEntity> _spreadApart(
    List<ItemProgressEntity> items,
    RandomSource random,
  ) {
    final Map<String, List<ItemProgressEntity>> left =
        <String, List<ItemProgressEntity>>{};
    for (final ItemProgressEntity item in random.shuffled(items)) {
      left.putIfAbsent(item.itemKey, () => <ItemProgressEntity>[]).add(item);
    }
    final List<ItemProgressEntity> order = <ItemProgressEntity>[];
    for (int remaining = items.length; remaining > 0; remaining--) {
      final String? key = _pickNext(
        left: left,
        previous: order.isEmpty ? null : order.last.itemKey,
        remaining: remaining,
        random: random,
      );
      if (key == null) break;
      order.add(left[key]!.removeLast());
    }
    return order;
  }

  /// The fact to ask next: never [previous], and a fact whose copies
  /// would otherwise end up side by side when one is left that needs it.
  String? _pickNext({
    required Map<String, List<ItemProgressEntity>> left,
    required String? previous,
    required int remaining,
    required RandomSource random,
  }) {
    final List<String> candidates = <String>[
      for (final MapEntry<String, List<ItemProgressEntity>> entry
          in left.entries)
        if (entry.value.isNotEmpty && entry.key != previous) entry.key,
    ];
    if (candidates.isEmpty) return null;
    // A fact with c copies needs 2c - 1 places to be spread: when only
    // that many are left, it must come now.
    final List<String> forced = candidates
        .where((String key) => 2 * left[key]!.length - 1 >= remaining)
        .toList();
    final List<String> pool = forced.isEmpty ? candidates : forced;
    return pool[random.nextInt(pool.length)];
  }
}
