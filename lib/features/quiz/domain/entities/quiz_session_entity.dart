import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:meta/meta.dart';

/// A finished or abandoned quiz session, kept as a journal entry that is
/// never changed afterwards.
@immutable
final class QuizSessionEntity {
  /// Creates a session record.
  const QuizSessionEntity({
    required this.id,
    required this.profileId,
    required this.domainId,
    required this.mode,
    required this.status,
    required this.startedAt,
    required this.duration,
    required this.questionCount,
    required this.correctCount,
    this.sourceKey,
    this.bossOutcome,
  });

  /// Records [run], ended at [endedAt] with [status].
  ///
  /// Only the scored answers count: second chances are left out, except
  /// in a boss fight where every answer counts.
  factory QuizSessionEntity.fromRun({
    required QuizRun run,
    required QuizSessionStatus status,
    required DateTime endedAt,
  }) {
    return QuizSessionEntity(
      id: run.sessionId,
      profileId: run.profileId,
      domainId: run.domainId,
      mode: run.mode,
      status: status,
      startedAt: run.startedAt,
      duration: endedAt.difference(run.startedAt),
      questionCount: run.scoredAnswers.length,
      correctCount: run.correctCount,
      sourceKey: run.sourceKey,
      bossOutcome: run.bossOutcome,
    );
  }

  /// Unique identifier, a UUID.
  final String id;

  /// Player of the session.
  final String profileId;

  /// Learning domain, such as `multiplication`.
  final String domainId;

  /// How the quiz was started.
  final QuizMode mode;

  /// Whether the session was completed or abandoned.
  final QuizSessionStatus status;

  /// When the first question appeared.
  final DateTime startedAt;

  /// Time from the start to the end of the session.
  final Duration duration;

  /// Scored questions of the session; second chances are not counted.
  final int questionCount;

  /// Right answers among the scored questions.
  final int correctCount;

  /// What the quiz was played for, such as a stage of the learning path,
  /// or `null`.
  final String? sourceKey;

  /// How a boss fight ended, or `null` for another quiz.
  final BossOutcome? bossOutcome;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuizSessionEntity &&
            other.id == id &&
            other.profileId == profileId &&
            other.domainId == domainId &&
            other.mode == mode &&
            other.status == status &&
            other.startedAt == startedAt &&
            other.duration == duration &&
            other.questionCount == questionCount &&
            other.correctCount == correctCount &&
            other.sourceKey == sourceKey &&
            other.bossOutcome == bossOutcome;
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    domainId,
    mode,
    status,
    startedAt,
    duration,
    questionCount,
    correctCount,
    sourceKey,
    bossOutcome,
  );
}
