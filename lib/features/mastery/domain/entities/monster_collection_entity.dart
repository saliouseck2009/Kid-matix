import 'package:kid_matix/features/mastery/domain/entities/monster_entity.dart';
import 'package:meta/meta.dart';

/// The monsters of a player: those still to tame and those tamed.
@immutable
final class MonsterCollectionEntity {
  /// Creates the collection.
  MonsterCollectionEntity({
    required List<MonsterEntity> wild,
    required List<MonsterEntity> tamed,
  }) : wild = List<MonsterEntity>.unmodifiable(wild),
       tamed = List<MonsterEntity>.unmodifiable(tamed);

  /// Monsters still to tame, the toughest first; at most
  /// `MonsterRule.shownCount`.
  final List<MonsterEntity> wild;

  /// Monsters tamed, in the natural order of their facts.
  final List<MonsterEntity> tamed;

  /// Whether there is a monster to hunt.
  bool get hasWildMonsters => wild.isNotEmpty;

  /// Returns a copy with the given fields replaced.
  MonsterCollectionEntity copyWith({
    List<MonsterEntity>? wild,
    List<MonsterEntity>? tamed,
  }) {
    return MonsterCollectionEntity(
      wild: wild ?? this.wild,
      tamed: tamed ?? this.tamed,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MonsterCollectionEntity &&
            _isSameList(other.wild, wild) &&
            _isSameList(other.tamed, tamed);
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(wild), Object.hashAll(tamed));

  @override
  String toString() => 'MonsterCollectionEntity(wild: $wild, tamed: $tamed)';

  static bool _isSameList(List<MonsterEntity> a, List<MonsterEntity> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
