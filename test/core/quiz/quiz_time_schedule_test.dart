import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';

const QuizTimeSchedule _schedule = QuizTimeSchedule(
  start: Duration(seconds: 10),
  step: Duration(milliseconds: 500),
  stepEvery: 5,
  floor: Duration(seconds: 4),
);

void main() {
  group('QuizTimeSchedule', () {
    test('keeps the start time until the first step', () {
      // Act
      final Duration actualFirst = _schedule.limitAfter(0);
      final Duration actualBeforeStep = _schedule.limitAfter(4);
      // Assert
      expect(actualFirst, const Duration(seconds: 10));
      expect(actualBeforeStep, const Duration(seconds: 10));
    });
    test('loses a step every 5 right answers', () {
      // Act
      final Duration actualAfterFive = _schedule.limitAfter(5);
      final Duration actualAfterTwelve = _schedule.limitAfter(12);
      // Assert
      expect(actualAfterFive, const Duration(milliseconds: 9500));
      expect(actualAfterTwelve, const Duration(seconds: 9));
    });
    test('never goes below the floor', () {
      // Act
      final Duration actualAtFloor = _schedule.limitAfter(60);
      final Duration actualPastFloor = _schedule.limitAfter(200);
      // Assert
      expect(actualAtFloor, const Duration(seconds: 4));
      expect(actualPastFloor, const Duration(seconds: 4));
    });
    test('stretches every time with its start', () {
      // Act
      final QuizTimeSchedule actualRelaxed = _schedule.scaledTo(
        const Duration(seconds: 15),
      );
      // Assert
      expect(
        actualRelaxed,
        const QuizTimeSchedule(
          start: Duration(seconds: 15),
          step: Duration(milliseconds: 750),
          stepEvery: 5,
          floor: Duration(seconds: 6),
        ),
      );
      expect(actualRelaxed.limitAfter(5), const Duration(milliseconds: 14250));
      expect(actualRelaxed.limitAfter(60), const Duration(seconds: 6));
      expect(actualRelaxed.hashCode, isNot(_schedule.hashCode));
    });
  });
}
