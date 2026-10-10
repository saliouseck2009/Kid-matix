import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';

/// What the quiz screen shows.
sealed class QuizState {
  /// Creates a state.
  const QuizState();
}

/// The quiz is being built.
final class QuizPreparing extends QuizState {
  /// Creates the state.
  const QuizPreparing();
}

/// A question waits for an answer.
final class QuizAsking extends QuizState {
  /// Creates the state.
  const QuizAsking({
    required this.run,
    this.elapsed = Duration.zero,
    this.isPaused = false,
    this.typedDigits = '',
  });

  /// Most digits the keypad accepts; every answer of version 1.0 fits.
  static const int maxTypedDigits = 3;

  /// Quiz being played; its current turn is the question shown.
  final QuizRun run;

  /// Time spent on the question so far, pauses excluded.
  final Duration elapsed;

  /// Whether the app is in the background.
  final bool isPaused;

  /// Digits typed on the keypad so far, for written answers.
  final String typedDigits;

  /// Question shown.
  QuizTurn get turn => run.currentTurn!;

  /// Questions answered before this one.
  int get answeredCount => run.answers.length;

  /// Fraction of the time left, from 1 to 0; `null` without a timer.
  double? get remainingFraction {
    final Duration? limit = run.timeLimit;
    if (limit == null) return null;
    final double left = 1 - elapsed.inMilliseconds / limit.inMilliseconds;
    return left.clamp(0, 1);
  }

  /// Whether the timer is in its last seconds.
  bool get isRunningOut {
    final Duration? limit = run.timeLimit;
    return limit != null && limit - elapsed <= QuizTimeLimits.warning;
  }

  /// Returns the state with [digit] typed after the others; a leading 0
  /// is replaced, and digits past [maxTypedDigits] are ignored.
  QuizAsking withDigit(int digit) {
    if (typedDigits.length >= maxTypedDigits) return this;
    final String kept = typedDigits == '0' ? '' : typedDigits;
    return copyWith(typedDigits: '$kept$digit');
  }

  /// Returns the state with the last typed digit erased.
  QuizAsking withoutLastDigit() {
    if (typedDigits.isEmpty) return this;
    return copyWith(
      typedDigits: typedDigits.substring(0, typedDigits.length - 1),
    );
  }

  /// Returns a copy with the given fields replaced.
  QuizAsking copyWith({
    Duration? elapsed,
    bool? isPaused,
    String? typedDigits,
  }) {
    return QuizAsking(
      run: run,
      elapsed: elapsed ?? this.elapsed,
      isPaused: isPaused ?? this.isPaused,
      typedDigits: typedDigits ?? this.typedDigits,
    );
  }
}

/// What the last answer did to the boss of a fight.
enum BossBlow {
  /// A right answer took 1 hit point.
  hit,

  /// A lightning answer took 2 hit points.
  criticalHit,

  /// A wrong answer: the monster strikes back, the player loses nothing.
  strikeBack,
}

/// The answer was judged; the player reads the feedback.
final class QuizShowingFeedback extends QuizState {
  /// Creates the state.
  const QuizShowingFeedback({required this.submission, this.givenAnswer});

  /// Judged answer and the quiz after it.
  final QuizSubmission submission;

  /// Answer the player gave, or `null` when the time ran out.
  final Answer? givenAnswer;

  /// What the answer did to the boss, or `null` outside a boss fight.
  BossBlow? get bossBlow {
    final BossFight? boss = submission.run.boss;
    if (boss == null) return null;
    if (boss.lastDamage == 0) return BossBlow.strikeBack;
    return boss.isLastHitCritical ? BossBlow.criticalHit : BossBlow.hit;
  }
}

/// Every question was answered and the session is saved.
final class QuizCompleted extends QuizState {
  /// Creates the state.
  const QuizCompleted({required this.session});

  /// Saved session, whose identifier opens the results.
  final QuizSessionEntity session;
}

/// The player left the quiz.
final class QuizLeft extends QuizState {
  /// Creates the state.
  const QuizLeft();
}

/// The quiz could not be built or saved.
final class QuizFailure extends QuizState {
  /// Creates the state.
  const QuizFailure({required this.errorCode});

  /// Reason of the failure, turned into text by the screen.
  final AppErrorCode errorCode;
}
