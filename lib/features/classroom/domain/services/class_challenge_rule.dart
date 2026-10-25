import 'package:kid_matix/features/classroom/domain/entities/class_challenge.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';

/// Computes the class challenge of the week, which starts again every
/// Monday 00:00 like the leaderboard of the phone.
abstract final class ClassChallengeRule {
  /// Monday 00:00 of the week of [now].
  static DateTime weekStartOf(DateTime now) {
    // Built from the calendar fields, so a change of daylight saving time
    // during the week never shifts midnight.
    return DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - DateTime.monday),
    );
  }

  /// The challenge of the week of [now] towards [goal], from the right
  /// answers of the class [sessions] played that week.
  static ClassChallenge compute({
    required int goal,
    required List<PracticeSession> sessions,
    required DateTime now,
  }) {
    final DateTime weekStart = weekStartOf(now);
    final int correctCount = sessions
        .where(
          (PracticeSession session) => !session.startedAt.isBefore(weekStart),
        )
        .fold(
          0,
          (int total, PracticeSession session) => total + session.correctCount,
        );
    return ClassChallenge(
      goal: goal,
      correctCount: correctCount,
      weekStart: weekStart,
    );
  }
}
