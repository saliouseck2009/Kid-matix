import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';

/// When a quiz sets a new record.
final class RecordPolicy {
  /// Creates the policy.
  const RecordPolicy();

  /// Modes that keep a record: the score is their right answers.
  static const Set<QuizMode> recordModes = <QuizMode>{QuizMode.timeAttack};

  /// The record set by a completed quiz of [mode] with [score] right
  /// answers, or `null` when it beats nothing: a mode without records, no
  /// right answer, or a score not above [current].
  RecordEntity? newRecordOf({
    required QuizMode mode,
    required int score,
    required String sessionId,
    required DateTime endedAt,
    RecordEntity? current,
  }) {
    if (!recordModes.contains(mode) || score <= 0) return null;
    final int? best = current?.bestScore;
    if (best != null && score <= best) return null;
    return RecordEntity(
      mode: mode,
      bestScore: score,
      sessionId: sessionId,
      achievedAt: endedAt,
      previousBest: best,
    );
  }
}
