import 'package:meta/meta.dart';

/// A fact the player keeps missing, shown as a little monster to tame.
@immutable
final class MonsterEntity {
  /// Creates the monster of [itemKey].
  const MonsterEntity({
    required this.itemKey,
    required this.box,
    required this.missCount,
  });

  /// Key of the fact, such as `mul:7x8`.
  final String itemKey;

  /// Review box of the fact; the monster is tamed from
  /// `MonsterRule.tamedBox`.
  final int box;

  /// Wrong answers given on the fact so far.
  final int missCount;

  /// Returns a copy with the given fields replaced.
  MonsterEntity copyWith({String? itemKey, int? box, int? missCount}) {
    return MonsterEntity(
      itemKey: itemKey ?? this.itemKey,
      box: box ?? this.box,
      missCount: missCount ?? this.missCount,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MonsterEntity &&
            other.itemKey == itemKey &&
            other.box == box &&
            other.missCount == missCount;
  }

  @override
  int get hashCode => Object.hash(itemKey, box, missCount);

  @override
  String toString() => 'MonsterEntity($itemKey, box $box, $missCount missed)';
}
