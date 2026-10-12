import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';

/// When a fact becomes a little monster, and when it is tamed.
///
/// A fact missed at least [missesToAppear] times is a monster while it is
/// in box 1 to 3, and tamed once it reaches [tamedBox], the « Acquis »
/// status; it is a monster again if it falls back. Everything is computed
/// from the progress of the items: monsters have no table of their own.
final class MonsterRule {
  /// Creates the rule.
  const MonsterRule();

  /// Wrong answers after which a fact becomes a monster.
  static const int missesToAppear = 2;

  /// Box from which a monster is tamed: the « Acquis » status.
  static const int tamedBox = MasteryPolicy.acquiredBox;

  /// Most monsters shown and hunted at once.
  static const int shownCount = 5;

  /// Whether [progress] is a monster still to tame.
  bool isWild(ItemProgressEntity progress) {
    return _hasEnoughMisses(progress) &&
        progress.box >= MasteryPolicy.firstBox &&
        progress.box < tamedBox;
  }

  /// Whether [progress] is a monster already tamed.
  bool isTamed(ItemProgressEntity progress) {
    return _hasEnoughMisses(progress) && progress.box >= tamedBox;
  }

  /// The monsters to show among [progress]: at most [shownCount], the
  /// toughest first.
  List<ItemProgressEntity> wildOf(Iterable<ItemProgressEntity> progress) {
    return (progress.where(isWild).toList()..sort(_compareToughest))
        .take(shownCount)
        .toList();
  }

  /// The monster of [progress].
  MonsterEntity monsterOf(ItemProgressEntity progress) {
    return MonsterEntity(
      itemKey: progress.itemKey,
      box: progress.box,
      missCount: progress.missCount,
    );
  }

  bool _hasEnoughMisses(ItemProgressEntity progress) {
    return progress.missCount >= missesToAppear;
  }

  /// Lowest box first, then most misses, then lowest success rate, then
  /// key order so the choice never depends on the storage order.
  static int _compareToughest(ItemProgressEntity a, ItemProgressEntity b) {
    final int byBox = a.box.compareTo(b.box);
    if (byBox != 0) return byBox;
    final int byMisses = b.missCount.compareTo(a.missCount);
    if (byMisses != 0) return byMisses;
    final int byRate = a.successRate.compareTo(b.successRate);
    if (byRate != 0) return byRate;
    return a.itemKey.compareTo(b.itemKey);
  }
}
