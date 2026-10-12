import 'package:meta/meta.dart';

/// A time per question that shrinks as the right answers add up: it
/// starts at [start], loses [step] every [stepEvery] right answers and
/// never goes below [floor].
@immutable
final class QuizTimeSchedule {
  /// Creates the schedule.
  const QuizTimeSchedule({
    required this.start,
    required this.step,
    required this.stepEvery,
    required this.floor,
  }) : assert(stepEvery > 0, 'stepEvery must be positive');

  /// Time to answer the first question.
  final Duration start;

  /// Time lost at each step.
  final Duration step;

  /// Right answers between two steps.
  final int stepEvery;

  /// Shortest time to answer a question.
  final Duration floor;

  /// Time to answer the next question after [correctCount] right answers.
  Duration limitAfter(int correctCount) {
    final Duration limit = start - step * (correctCount ~/ stepEvery);
    return limit < floor ? floor : limit;
  }

  /// The same schedule stretched so that it starts at [newStart], as the
  /// relaxed timer of a player stretches every time.
  QuizTimeSchedule scaledTo(Duration newStart) {
    Duration scale(Duration time) => Duration(
      microseconds:
          time.inMicroseconds * newStart.inMicroseconds ~/ start.inMicroseconds,
    );
    return QuizTimeSchedule(
      start: newStart,
      step: scale(step),
      stepEvery: stepEvery,
      floor: scale(floor),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuizTimeSchedule &&
            other.start == start &&
            other.step == step &&
            other.stepEvery == stepEvery &&
            other.floor == floor;
  }

  @override
  int get hashCode => Object.hash(start, step, stepEvery, floor);
}
