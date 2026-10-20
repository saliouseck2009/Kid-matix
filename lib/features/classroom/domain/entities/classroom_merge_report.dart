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
    this.renamedNicknames = const <String>[],
  });

  /// Name of the class of the file.
  final String classroomName;

  /// Pupils that were not on the tablet yet.
  final int addedPupilCount;

  /// Sessions that were not on the tablet yet.
  final int addedSessionCount;

  /// New nicknames of the pupils renamed because another pupil of the
  /// class had theirs, such as « Moussa 2 ».
  final List<String> renamedNicknames;

  /// Returns a copy with the given fields replaced.
  ClassroomMergeReport copyWith({
    String? classroomName,
    int? addedPupilCount,
    int? addedSessionCount,
    List<String>? renamedNicknames,
  }) {
    return ClassroomMergeReport(
      classroomName: classroomName ?? this.classroomName,
      addedPupilCount: addedPupilCount ?? this.addedPupilCount,
      addedSessionCount: addedSessionCount ?? this.addedSessionCount,
      renamedNicknames: renamedNicknames ?? this.renamedNicknames,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClassroomMergeReport &&
            other.classroomName == classroomName &&
            other.addedPupilCount == addedPupilCount &&
            other.addedSessionCount == addedSessionCount &&
            other.renamedNicknames.join(',') == renamedNicknames.join(',');
  }

  @override
  int get hashCode => Object.hash(
    classroomName,
    addedPupilCount,
    addedSessionCount,
    Object.hashAll(renamedNicknames),
  );
}
