import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:meta/meta.dart';

/// The best score of a player in a mode, such as the most right answers
/// in a time attack.
@immutable
final class RecordEntity {
  /// Creates the record.
  const RecordEntity({
    required this.mode,
    required this.bestScore,
    required this.sessionId,
    required this.achievedAt,
    this.previousBest,
  });

  /// Mode of the record.
  final QuizMode mode;

  /// Best score so far.
  final int bestScore;

  /// Session that set the record.
  final String sessionId;

  /// When the record was set.
  final DateTime achievedAt;

  /// Record beaten by this one, or `null` for a first record.
  final int? previousBest;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RecordEntity &&
            other.mode == mode &&
            other.bestScore == bestScore &&
            other.sessionId == sessionId &&
            other.achievedAt == achievedAt &&
            other.previousBest == previousBest;
  }

  @override
  int get hashCode =>
      Object.hash(mode, bestScore, sessionId, achievedAt, previousBest);
}
