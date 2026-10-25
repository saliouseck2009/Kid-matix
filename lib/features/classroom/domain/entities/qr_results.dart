import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:meta/meta.dart';

/// The small results a tablet shows as a QR code to the teacher's tablet
/// (F31-05): the new sessions of the pupils of one class and their new
/// assessment results, nothing of the class itself, which the teacher's
/// tablet already has.
@immutable
final class QrResults {
  /// Creates the results of [classroomId].
  QrResults({
    required this.classroomId,
    required List<PracticeSession> sessions,
    required List<AssessmentResult> results,
  }) : sessions = List<PracticeSession>.unmodifiable(sessions),
       results = List<AssessmentResult>.unmodifiable(results);

  /// Most characters of a QR code text: above, the code is too dense for
  /// the camera of a low-end tablet, and the class file is used instead.
  static const int maxTextLength = 1000;

  /// Class of the results.
  final String classroomId;

  /// The sessions of its pupils, with their answers.
  final List<PracticeSession> sessions;

  /// The assessment results of its pupils.
  final List<AssessmentResult> results;

  /// Whether there is nothing to send.
  bool get isEmpty => sessions.isEmpty && results.isEmpty;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QrResults &&
            other.classroomId == classroomId &&
            Object.hashAll(other.sessions) == Object.hashAll(sessions) &&
            Object.hashAll(other.results) == Object.hashAll(results);
  }

  @override
  int get hashCode => Object.hash(
    classroomId,
    Object.hashAll(sessions),
    Object.hashAll(results),
  );
}
