import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:meta/meta.dart';

/// The level groups the class mode proposes, from the least to the most
/// advanced, in the spirit of « Teaching at the Right Level ».
enum LevelGroupKind {
  /// Less than a third of the items acquired.
  firstSteps,

  /// From a third to two thirds.
  onTheWay,

  /// Two thirds or more.
  confident,

  /// No placement and no answer yet in the domain.
  notYet,
}

/// One proposed level group and its pupils.
@immutable
final class LevelGroup {
  /// Creates the group [kind].
  const LevelGroup({required this.kind, required this.pupils});

  /// Which group.
  final LevelGroupKind kind;

  /// Its pupils, in the order of the class list.
  final List<PupilEntity> pupils;

  /// Returns a copy with the given fields replaced.
  LevelGroup copyWith({LevelGroupKind? kind, List<PupilEntity>? pupils}) {
    return LevelGroup(kind: kind ?? this.kind, pupils: pupils ?? this.pupils);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LevelGroup &&
            other.kind == kind &&
            Object.hashAll(other.pupils) == Object.hashAll(pupils);
  }

  @override
  int get hashCode => Object.hash(kind, Object.hashAll(pupils));
}
