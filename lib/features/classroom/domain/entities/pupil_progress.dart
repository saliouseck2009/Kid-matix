import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:meta/meta.dart';

/// What the dashboard shows of one pupil: practice, last session, right
/// answers, the items they know and those they are stuck on.
@immutable
final class PupilProgress {
  /// Creates the progress of [pupil].
  const PupilProgress({
    required this.pupil,
    this.sessionCount = 0,
    this.practiceTime = Duration.zero,
    this.lastPlayedAt,
    this.answerCount = 0,
    this.correctCount = 0,
    this.answeredItemKeys = const <String>{},
    this.acquiredItemKeys = const <String>{},
    this.struggleItemKeys = const <String>[],
    this.assignmentProgress,
  });

  /// The pupil.
  final PupilEntity pupil;

  /// Sessions played.
  final int sessionCount;

  /// Time played, all sessions together.
  final Duration practiceTime;

  /// End of the last session, or `null` before the first one.
  final DateTime? lastPlayedAt;

  /// Scored answers given.
  final int answerCount;

  /// Right answers among them.
  final int correctCount;

  /// Items asked at least once.
  final Set<String> answeredItemKeys;

  /// Items right the last three times.
  final Set<String> acquiredItemKeys;

  /// Items missed at least twice in the last three answers, in the order
  /// of their keys.
  final List<String> struggleItemKeys;

  /// Share of the items of the class's assignment the pupil has
  /// acquired, from 0 to 1, or `null` without assignment.
  final double? assignmentProgress;

  /// Whether the pupil has played at least once.
  bool get hasPlayed => sessionCount > 0;

  /// Returns a copy with the given fields replaced.
  PupilProgress copyWith({
    PupilEntity? pupil,
    int? sessionCount,
    Duration? practiceTime,
    DateTime? lastPlayedAt,
    int? answerCount,
    int? correctCount,
    Set<String>? answeredItemKeys,
    Set<String>? acquiredItemKeys,
    List<String>? struggleItemKeys,
    double? assignmentProgress,
  }) {
    return PupilProgress(
      pupil: pupil ?? this.pupil,
      sessionCount: sessionCount ?? this.sessionCount,
      practiceTime: practiceTime ?? this.practiceTime,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      answerCount: answerCount ?? this.answerCount,
      correctCount: correctCount ?? this.correctCount,
      answeredItemKeys: answeredItemKeys ?? this.answeredItemKeys,
      acquiredItemKeys: acquiredItemKeys ?? this.acquiredItemKeys,
      struggleItemKeys: struggleItemKeys ?? this.struggleItemKeys,
      assignmentProgress: assignmentProgress ?? this.assignmentProgress,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PupilProgress &&
            other.pupil == pupil &&
            other.sessionCount == sessionCount &&
            other.practiceTime == practiceTime &&
            other.lastPlayedAt == lastPlayedAt &&
            other.answerCount == answerCount &&
            other.correctCount == correctCount &&
            other.assignmentProgress == assignmentProgress &&
            other.answeredItemKeys.length == answeredItemKeys.length &&
            other.answeredItemKeys.containsAll(answeredItemKeys) &&
            other.acquiredItemKeys.length == acquiredItemKeys.length &&
            other.acquiredItemKeys.containsAll(acquiredItemKeys) &&
            other.struggleItemKeys.join(',') == struggleItemKeys.join(',');
  }

  @override
  int get hashCode => Object.hash(
    pupil,
    sessionCount,
    practiceTime,
    lastPlayedAt,
    answerCount,
    correctCount,
    assignmentProgress,
    Object.hashAllUnordered(answeredItemKeys),
    Object.hashAllUnordered(acquiredItemKeys),
    Object.hashAll(struggleItemKeys),
  );

  @override
  String toString() => 'PupilProgress(${pupil.nickname}, $sessionCount)';
}
