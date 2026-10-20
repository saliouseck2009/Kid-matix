import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:meta/meta.dart';

/// A class with its pupils, in the order of their list.
@immutable
final class ClassroomRoster {
  /// Creates the roster of [classroom].
  const ClassroomRoster({required this.classroom, required this.pupils});

  /// The class.
  final ClassroomEntity classroom;

  /// Its pupils, oldest first.
  final List<PupilEntity> pupils;

  /// Returns a copy with the given fields replaced.
  ClassroomRoster copyWith({
    ClassroomEntity? classroom,
    List<PupilEntity>? pupils,
  }) {
    return ClassroomRoster(
      classroom: classroom ?? this.classroom,
      pupils: pupils ?? this.pupils,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassroomRoster &&
            other.classroom == classroom &&
            _haveSamePupils(other.pupils, pupils);
  }

  @override
  int get hashCode => Object.hash(classroom, Object.hashAll(pupils));

  static bool _haveSamePupils(List<PupilEntity> a, List<PupilEntity> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
