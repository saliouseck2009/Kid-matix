import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:meta/meta.dart';

/// One quiz session a pupil played, as the class mode keeps it: the
/// unit of the class results, carried between tablets by file and
/// merged by its identifier.
@immutable
final class PracticeSession {
  /// Creates the session [id].
  const PracticeSession({
    required this.id,
    required this.pupilId,
    required this.classroomId,
    required this.domainId,
    required this.startedAt,
    required this.duration,
    required this.questionCount,
    required this.correctCount,
    this.answers = const <PracticeAnswer>[],
  });

  /// Identifier, the one of the quiz session on the tablet it was
  /// played on.
  final String id;

  /// Pupil who played.
  final String pupilId;

  /// Class of the pupil.
  final String classroomId;

  /// Learning domain of the quiz.
  final String domainId;

  /// When the session started.
  final DateTime startedAt;

  /// Time played.
  final Duration duration;

  /// Scored questions answered.
  final int questionCount;

  /// Right answers among them.
  final int correctCount;

  /// Every answer, in order.
  final List<PracticeAnswer> answers;

  /// When the session ended.
  DateTime get endedAt => startedAt.add(duration);

  /// Returns a copy with the given fields replaced.
  PracticeSession copyWith({
    String? id,
    String? pupilId,
    String? classroomId,
    String? domainId,
    DateTime? startedAt,
    Duration? duration,
    int? questionCount,
    int? correctCount,
    List<PracticeAnswer>? answers,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      pupilId: pupilId ?? this.pupilId,
      classroomId: classroomId ?? this.classroomId,
      domainId: domainId ?? this.domainId,
      startedAt: startedAt ?? this.startedAt,
      duration: duration ?? this.duration,
      questionCount: questionCount ?? this.questionCount,
      correctCount: correctCount ?? this.correctCount,
      answers: answers ?? this.answers,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PracticeSession &&
            other.id == id &&
            other.pupilId == pupilId &&
            other.classroomId == classroomId &&
            other.domainId == domainId &&
            other.startedAt == startedAt &&
            other.duration == duration &&
            other.questionCount == questionCount &&
            other.correctCount == correctCount &&
            _haveSameAnswers(other.answers, answers);
  }

  @override
  int get hashCode => Object.hash(
    id,
    pupilId,
    classroomId,
    domainId,
    startedAt,
    duration,
    questionCount,
    correctCount,
    Object.hashAll(answers),
  );

  @override
  String toString() => 'PracticeSession($id, $pupilId)';

  static bool _haveSameAnswers(
    List<PracticeAnswer> a,
    List<PracticeAnswer> b,
  ) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
