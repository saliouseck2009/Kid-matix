import 'package:kid_matix/features/classroom/domain/entities/classroom_entity.dart';
import 'package:meta/meta.dart';

/// A class with the number of its pupils, as the lists of classes show
/// it.
@immutable
final class ClassroomSummary {
  /// Creates the summary of [classroom].
  const ClassroomSummary({required this.classroom, required this.pupilCount});

  /// The class.
  final ClassroomEntity classroom;

  /// How many pupils it holds.
  final int pupilCount;

  /// Returns a copy with the given fields replaced.
  ClassroomSummary copyWith({ClassroomEntity? classroom, int? pupilCount}) {
    return ClassroomSummary(
      classroom: classroom ?? this.classroom,
      pupilCount: pupilCount ?? this.pupilCount,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassroomSummary &&
            other.classroom == classroom &&
            other.pupilCount == pupilCount;
  }

  @override
  int get hashCode => Object.hash(classroom, pupilCount);
}
