import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

/// The timer of a quiz, for `QuizBloc`: the injected [Ticker], and what a
/// tick does to the state.
///
/// It measures every answer, even without a visible timer; holds the time
/// of a question while the voice reads it; and, in a non-stop quiz, also
/// counts the time of the feedback and asks for the next question by
/// itself. It never changes the state on its own: the Bloc gives it the
/// state and the emitter, and the events it asks for ([ClockRanOut],
/// [TimeExpired], [NextRequested]) go back through [_addEvent].
final class QuizClock {
  /// Creates the clock; [addEvent] sends an event to the Bloc.
  QuizClock({required this._ticker, required this._addEvent});

  /// Time between two ticks of the timer.
  static const Duration tickInterval = Duration(milliseconds: 100);

  /// In a non-stop quiz, how long a right answer shows before the next
  /// question.
  static const Duration rightFeedbackTime = Duration(milliseconds: 600);

  /// In a non-stop quiz, how long a mistake and its right answer show.
  static const Duration wrongFeedbackTime = Duration(milliseconds: 1500);

  final Ticker _ticker;
  final void Function(QuizEvent event) _addEvent;
  StreamSubscription<int>? _ticks;

  /// Whether the ticks are coming.
  bool get isRunning => _ticks != null;

  /// Starts the ticks, replacing the ones in progress.
  void start() {
    stop();
    _ticks = _ticker
        .tick(interval: tickInterval)
        .listen((_) => _addEvent(const TimerTicked()));
  }

  /// Stops the ticks.
  void stop() {
    unawaited(_ticks?.cancel());
    _ticks = null;
  }

  /// Applies one tick to [state].
  void onTicked(QuizState state, Emitter<QuizState> emit) {
    switch (state) {
      // While the voice reads, the time of the question is held: only the
      // reading is timed, in case the player answers before its end.
      case final QuizAsking current when !current.isPaused && current.isReading:
        emit(
          current.copyWith(readingTime: current.readingTime + tickInterval),
        );
      // The time of a question starts when the voice has finished reading
      // it, and stops while the player listens to it again.
      case final QuizAsking current
          when !current.isPaused && !current.isReading:
        final QuizAsking next = current.copyWith(
          elapsed: current.elapsed + tickInterval,
          playedTime: current.playedTime + tickInterval,
        );
        emit(next);
        final Duration? limit = next.run.currentTimeLimit;
        if (_isOutOfTime(next.run, next.playedTime)) {
          _addEvent(const ClockRanOut());
        } else if (limit != null &&
            next.elapsed >= limit &&
            current.elapsed < limit) {
          // Once only: in a non-stop quiz the ticks go on while the
          // timeout is judged.
          _addEvent(const TimeExpired());
        }
      case final QuizShowingFeedback current:
        _tickFeedback(current, emit);
      default:
        return;
    }
  }

  /// In a non-stop quiz, the feedback counts in the time and leads to
  /// the next question by itself.
  void _tickFeedback(QuizShowingFeedback current, Emitter<QuizState> emit) {
    final QuizShowingFeedback next = current.copyWith(
      playedTime: current.playedTime + tickInterval,
      shownFor: current.shownFor + tickInterval,
    );
    emit(next);
    final Duration shownTime = next.submission.answer.isCorrect
        ? rightFeedbackTime
        : wrongFeedbackTime;
    if (_isOutOfTime(next.submission.run, next.playedTime)) {
      _addEvent(const ClockRanOut());
    } else if (next.shownFor >= shownTime) {
      _addEvent(const NextRequested());
    }
  }

  static bool _isOutOfTime(QuizRun run, Duration playedTime) {
    final Duration? limit = run.totalTimeLimit;
    return limit != null && playedTime >= limit;
  }
}
