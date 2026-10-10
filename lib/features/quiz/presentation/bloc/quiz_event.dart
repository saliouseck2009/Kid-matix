import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';

/// Something that happens during a quiz.
sealed class QuizEvent {
  /// Creates an event.
  const QuizEvent();
}

/// The quiz screen opened with [request].
final class QuizStarted extends QuizEvent {
  /// Creates the event.
  const QuizStarted({required this.request});

  /// Quiz to play.
  final QuizRequest request;
}

/// The player answered the current question.
final class AnswerSubmitted extends QuizEvent {
  /// Creates the event.
  const AnswerSubmitted({required this.answer});

  /// Answer given.
  final Answer answer;
}

/// The player typed [digit] on the keypad.
final class DigitTyped extends QuizEvent {
  /// Creates the event.
  const DigitTyped({required this.digit});

  /// Digit typed, from 0 to 9.
  final int digit;
}

/// The player erased the last digit typed.
final class DigitErased extends QuizEvent {
  /// Creates the event.
  const DigitErased();
}

/// The player validated the number typed on the keypad.
final class TypedAnswerValidated extends QuizEvent {
  /// Creates the event.
  const TypedAnswerValidated();
}

/// One tick of the timer went by.
final class TimerTicked extends QuizEvent {
  /// Creates the event.
  const TimerTicked();
}

/// The time to answer the current question ran out.
final class TimeExpired extends QuizEvent {
  /// Creates the event.
  const TimeExpired();
}

/// The time to play the whole quiz ran out.
final class ClockRanOut extends QuizEvent {
  /// Creates the event.
  const ClockRanOut();
}

/// The player tapped "Continuer" after the feedback, or its time went by
/// in a quiz against the clock.
final class NextRequested extends QuizEvent {
  /// Creates the event.
  const NextRequested();
}

/// The app went to the background: the timer stops.
final class QuizPaused extends QuizEvent {
  /// Creates the event.
  const QuizPaused();
}

/// The app came back: the timer goes on; against the clock, a new
/// question replaces the one shown.
final class QuizResumed extends QuizEvent {
  /// Creates the event.
  const QuizResumed();
}

/// The player confirmed leaving the quiz.
final class QuizAbandoned extends QuizEvent {
  /// Creates the event.
  const QuizAbandoned();
}
