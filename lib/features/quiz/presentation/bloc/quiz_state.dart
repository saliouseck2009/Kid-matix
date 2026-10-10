import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/quiz/answer.dart';
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
  });

  /// Quiz being played; its current turn is the question shown.
  final QuizRun run;

  /// Time spent on the question so far, pauses excluded.
  final Duration elapsed;

  /// Whether the app is in the background.
  final bool isPaused;

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

  /// Returns a copy with [elapsed] and [isPaused] replaced.
  QuizAsking copyWith({Duration? elapsed, bool? isPaused}) {
    return QuizAsking(
      run: run,
      elapsed: elapsed ?? this.elapsed,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

/// The answer was judged; the player reads the feedback.
final class QuizShowingFeedback extends QuizState {
  /// Creates the state.
  const QuizShowingFeedback({required this.submission, this.givenAnswer});

  /// Judged answer and the quiz after it.
  final QuizSubmission submission;

  /// Answer the player gave, or `null` when the time ran out.
  final Answer? givenAnswer;
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
