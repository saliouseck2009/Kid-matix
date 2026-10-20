import 'package:meta/meta.dart';

/// What merging a class file added on this tablet; a file received twice
/// adds nothing the second time.
@immutable
final class ClassroomMergeReport {
  /// Creates the report.
  const ClassroomMergeReport({
    required this.classroomName,
    required this.addedPupilCount,
    required this.addedSessionCount,
  });

  /// Name of the class of the file.
  final String classroomName;

  /// Pupils that were not on the tablet yet.
  final int addedPupilCount;

  /// Sessions that were not on the tablet yet.
  final int addedSessionCount;

  /// Returns a copy with the given fields replaced.
  ClassroomMergeReport copyWith({
    String? classroomName,
    int? addedPupilCount,
    int? addedSessionCount,
  }) {
    return ClassroomMergeReport(
      classroomName: classroomName ?? this.classroomName,
      addedPupilCount: addedPupilCount ?? this.addedPupilCount,
      addedSessionCount: addedSessionCount ?? this.addedSessionCount,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassroomMergeReport &&
            other.classroomName == classroomName &&
            other.addedPupilCount == addedPupilCount &&
            other.addedSessionCount == addedSessionCount;
  }

  @override
  int get hashCode =>
      Object.hash(classroomName, addedPupilCount, addedSessionCount);
}
