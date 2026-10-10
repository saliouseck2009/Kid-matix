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

/// The player tapped "Continuer" after the feedback.
final class NextRequested extends QuizEvent {
  /// Creates the event.
  const NextRequested();
}

/// The app went to the background: the timer stops.
final class QuizPaused extends QuizEvent {
  /// Creates the event.
  const QuizPaused();
}

/// The app came back: the timer goes on.
final class QuizResumed extends QuizEvent {
  /// Creates the event.
  const QuizResumed();
}

/// The player confirmed leaving the quiz.
final class QuizAbandoned extends QuizEvent {
  /// Creates the event.
  const QuizAbandoned();
}
