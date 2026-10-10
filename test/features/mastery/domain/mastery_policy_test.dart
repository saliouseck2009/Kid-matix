import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_answer.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';

const MasteryPolicy _policy = MasteryPolicy();
final DateTime _now = DateTime(2026, 10, 10, 18, 30);

ItemProgressEntity _progress({
  int box = 0,
  List<Duration> times = const <Duration>[],
}) {
  return const ItemProgressEntity.notSeen(
    profileId: 'p1',
    domainId: 'multiplication',
    itemKey: 'mul:7x8',
  ).copyWith(box: box, lastAnswerTimes: times);
}

MasteryAnswer _answer({
  bool isCorrect = true,
  AnswerNature nature = AnswerNature.produced,
  int ms = 2000,
  bool isRetry = false,
}) {
  return MasteryAnswer(
    isCorrect: isCorrect,
    answerNature: nature,
    answerTime: Duration(milliseconds: ms),
    isRetry: isRetry,
  );
}

List<Duration> _seconds(List<int> values) =>
    values.map((int value) => Duration(seconds: value)).toList();

void main() {
  group('MasteryPolicy.apply', () {
    test('moves a right answer up one box', () {
      // Arrange
      final ItemProgressEntity inputProgress = _progress(box: 2);
      // Act
      final ItemProgressEntity actualProgress = _policy.apply(
        progress: inputProgress,
        answer: _answer(),
        now: _now,
      );
      // Assert
      expect(actualProgress.box, 3);
      expect(actualProgress.presentationCount, 1);
      expect(actualProgress.correctCount, 1);
    });
    test('sends a wrong answer back to box 1', () {
      // Arrange
      final ItemProgressEntity inputProgress = _progress(box: 4);
      // Act
      final ItemProgressEntity actualProgress = _policy.apply(
        progress: inputProgress,
        answer: _answer(isCorrect: false),
        now: _now,
      );
      // Assert
      expect(actualProgress.box, MasteryPolicy.firstBox);
      expect(actualProgress.correctCount, 0);
      expect(actualProgress.presentationCount, 1);
    });
    test('moves a new item to box 2 after its first right answer', () {
      // Act
      final ItemProgressEntity actualProgress = _policy.apply(
        progress: _progress(),
        answer: _answer(),
        now: _now,
      );
      // Assert
      expect(actualProgress.box, MasteryPolicy.firstRightBox);
    });
    test('moves a new item to box 1 after a first mistake', () {
      // Act
      final ItemProgressEntity actualProgress = _policy.apply(
        progress: _progress(),
        answer: _answer(isCorrect: false),
        now: _now,
      );
      // Assert
      expect(actualProgress.box, MasteryPolicy.firstBox);
    });
    test('never moves a picked answer past box 3', () {
      // Arrange
      const AnswerNature inputNature = AnswerNature.recognized;
      // Act
      final ItemProgressEntity actualFromTwo = _policy.apply(
        progress: _progress(box: 2),
        answer: _answer(nature: inputNature),
        now: _now,
      );
      final ItemProgressEntity actualFromThree = _policy.apply(
        progress: _progress(box: 3),
        answer: _answer(nature: inputNature),
        now: _now,
      );
      final ItemProgressEntity actualFromFour = _policy.apply(
        progress: _progress(box: 4),
        answer: _answer(nature: inputNature),
        now: _now,
      );
      // Assert
      expect(actualFromTwo.box, 3);
      expect(actualFromThree.box, 3);
      expect(actualFromFour.box, 4);
    });
    test('moves a written answer up to box 5 and no further', () {
      // Act
      final ItemProgressEntity actualFromThree = _policy.apply(
        progress: _progress(box: 3),
        answer: _answer(),
        now: _now,
      );
      final ItemProgressEntity actualFromFive = _policy.apply(
        progress: _progress(box: 5),
        answer: _answer(),
        now: _now,
      );
      // Assert
      expect(actualFromThree.box, 4);
      expect(actualFromFive.box, MasteryPolicy.lastBox);
    });
    test('keeps a right second chance in its box', () {
      // Act
      final ItemProgressEntity actualProgress = _policy.apply(
        progress: _progress(box: 1),
        answer: _answer(isRetry: true),
        now: _now,
      );
      // Assert
      expect(actualProgress.box, 1);
      expect(actualProgress.correctCount, 1);
      expect(actualProgress.nextReviewAt, DateTime(2026, 10, 11));
    });
    test('keeps only the last 5 answer times, oldest first', () {
      // Arrange
      final ItemProgressEntity inputProgress = _progress(
        box: 3,
        times: _seconds(<int>[1, 2, 3, 4, 5]),
      );
      // Act
      final ItemProgressEntity actualProgress = _policy.apply(
        progress: inputProgress,
        answer: _answer(ms: 6000),
        now: _now,
      );
      // Assert
      expect(actualProgress.lastAnswerTimes, _seconds(<int>[2, 3, 4, 5, 6]));
    });
  });

  group('MasteryPolicy review dates', () {
    final Map<int, DateTime> expectedDates = <int, DateTime>{
      1: DateTime(2026, 10, 11),
      2: DateTime(2026, 10, 12),
      3: DateTime(2026, 10, 14),
      4: DateTime(2026, 10, 17),
      5: DateTime(2026, 10, 25),
    };
    for (final MapEntry<int, DateTime> entry in expectedDates.entries) {
      test('brings box ${entry.key} back on ${entry.value}', () {
        // Act
        final DateTime actualDate = _policy.reviewDateOf(
          box: entry.key,
          now: _now,
        );
        // Assert
        expect(actualDate, entry.value);
      });
    }
    test('dates the answer with the review day of its new box', () {
      // Act
      final ItemProgressEntity actualProgress = _policy.apply(
        progress: _progress(box: 2),
        answer: _answer(),
        now: _now,
      );
      // Assert
      expect(actualProgress.nextReviewAt, DateTime(2026, 10, 14));
    });
    test('crosses the end of the month', () {
      // Act
      final DateTime actualDate = _policy.reviewDateOf(
        box: 5,
        now: DateTime(2026, 12, 25, 9),
      );
      // Assert
      expect(actualDate, DateTime(2027, 1, 9));
    });
    test('is due from the start of its review day', () {
      // Arrange
      final ItemProgressEntity inputProgress = _progress(
        box: 1,
      ).copyWith(nextReviewAt: DateTime(2026, 10, 11));
      // Act
      final bool actualToday = _policy.isDue(
        progress: inputProgress,
        now: _now,
      );
      final bool actualTomorrow = _policy.isDue(
        progress: inputProgress,
        now: DateTime(2026, 10, 11, 7),
      );
      // Assert
      expect(actualToday, isFalse);
      expect(actualTomorrow, isTrue);
    });
    test('is never due before its first answer', () {
      // Act
      final bool actualDue = _policy.isDue(progress: _progress(), now: _now);
      // Assert
      expect(actualDue, isFalse);
    });
  });

  group('MasteryPolicy.statusOf', () {
    test('names each box', () {
      // Act
      final List<MasteryStatus> actualStatuses = <int>[
        0,
        1,
        2,
        3,
        4,
      ].map((int box) => _policy.statusOf(_progress(box: box))).toList();
      // Assert
      expect(actualStatuses, <MasteryStatus>[
        MasteryStatus.notSeen,
        MasteryStatus.toReview,
        MasteryStatus.inProgress,
        MasteryStatus.inProgress,
        MasteryStatus.acquired,
      ]);
    });
    test('masters box 5 with a median answer time under 3 seconds', () {
      // Arrange
      final ItemProgressEntity inputProgress = _progress(
        box: 5,
        times: _seconds(<int>[1, 2, 2, 6, 7]),
      );
      // Act
      final MasteryStatus actualStatus = _policy.statusOf(inputProgress);
      // Assert
      expect(actualStatus, MasteryStatus.mastered);
    });
    test('keeps box 5 acquired while the median is 3 seconds or more', () {
      // Arrange
      final ItemProgressEntity inputProgress = _progress(
        box: 5,
        times: _seconds(<int>[1, 2, 3, 6, 7]),
      );
      // Act
      final MasteryStatus actualStatus = _policy.statusOf(inputProgress);
      // Assert
      expect(actualStatus, MasteryStatus.acquired);
    });
  });

  group('ItemProgressEntity.medianAnswerTime', () {
    test('takes the middle value of an odd count', () {
      // Act
      final Duration? actualMedian = _progress(
        times: _seconds(<int>[9, 1, 4]),
      ).medianAnswerTime;
      // Assert
      expect(actualMedian, const Duration(seconds: 4));
    });
    test('averages the two middle values of an even count', () {
      // Act
      final Duration? actualMedian = _progress(
        times: _seconds(<int>[1, 2, 4, 8]),
      ).medianAnswerTime;
      // Assert
      expect(actualMedian, const Duration(seconds: 3));
    });
    test('is null without any answer', () {
      // Assert
      expect(_progress().medianAnswerTime, isNull);
    });
    test('is equal to a progress with the same fields', () {
      // Arrange
      final ItemProgressEntity inputProgress = _progress(
        box: 2,
        times: _seconds(<int>[1, 2]),
      );
      // Act
      final ItemProgressEntity actualProgress = inputProgress.copyWith();
      // Assert
      expect(actualProgress, inputProgress);
      expect(actualProgress.hashCode, inputProgress.hashCode);
    });
  });
}
