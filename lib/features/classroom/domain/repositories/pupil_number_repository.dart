import 'package:kid_matix/core/error/data_state.dart';

/// The number of each pupil in their class: given at enrolment, the next
/// one of the class, never given again; the anonymous reports show
/// « Élève 7 » by it (F31-04).
abstract interface class PupilNumberRepository {
  /// Gives the next numbers of [classroomId] to those of [pupilIds] that
  /// have none, in that order, and resolves to the number of every pupil
  /// of the class, by pupil identifier.
  Future<DataState<Map<String, int>>> assign({
    required String classroomId,
    required List<String> pupilIds,
  });
}
