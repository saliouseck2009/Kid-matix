import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_answer.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';

/// The spaced repetition rules: boxes, review days and mastery.
///
/// A right answer moves the item up one box, a wrong one or a timeout
/// sends it back to box 1. Box 1 holds only the items to review, so the
/// first right answer of a new item moves it straight to
/// [firstRightBox]. An answer picked among choices never moves it past
/// [recognizedBoxCap]: only a written answer goes higher.
final class MasteryPolicy {
  /// Creates the policy.
  const MasteryPolicy();

  /// Box of an item answered wrong.
  static const int firstBox = 1;

  /// Box of a new item answered right the first time.
  static const int firstRightBox = 2;

  /// Highest box an answer picked among choices can reach.
  static const int recognizedBoxCap = 3;

  /// Highest box.
  static const int lastBox = 5;

  /// Days before an item comes back, by box: index 1 is box 1.
  static const List<int> reviewDays = <int>[0, 1, 2, 4, 7, 15];

  /// Answer times kept per item to judge its speed.
  static const int answerTimeCount = 5;

  /// Median answer time under which an item of the last box is mastered.
  static const Duration masteredSpeed = Duration(seconds: 3);

  /// Returns [progress] after [answer], given at [now].
  ///
  /// The second chance of a fact missed in the same quiz counts in the
  /// statistics but never moves the item up: the fact still comes back
  /// the next day.
  ItemProgressEntity apply({
    required ItemProgressEntity progress,
    required MasteryAnswer answer,
    required DateTime now,
  }) {
    final int box = _nextBox(progress.box, answer);
    return progress.copyWith(
      presentationCount: progress.presentationCount + 1,
      correctCount: progress.correctCount + (answer.isCorrect ? 1 : 0),
      lastAnswerTimes: _keepLastTimes(<Duration>[
        ...progress.lastAnswerTimes,
        answer.answerTime,
      ]),
      box: box,
      nextReviewAt: reviewDateOf(box: box, now: now),
    );
  }

  /// First day an item of [box] answered at [now] is due again: the start
  /// of the day, [reviewDays] days later.
  DateTime reviewDateOf({required int box, required DateTime now}) {
    return DateTime(now.year, now.month, now.day + reviewDays[box]);
  }

  /// Whether [progress] is due for a review at [now]; an item never
  /// presented is not.
  bool isDue({required ItemProgressEntity progress, required DateTime now}) {
    final DateTime? reviewAt = progress.nextReviewAt;
    return reviewAt != null && !reviewAt.isAfter(now);
  }

  /// What the player is shown about [progress].
  MasteryStatus statusOf(ItemProgressEntity progress) {
    return switch (progress.box) {
      0 => MasteryStatus.notSeen,
      firstBox => MasteryStatus.toReview,
      lastBox when _isFast(progress) => MasteryStatus.mastered,
      >= 4 => MasteryStatus.acquired,
      _ => MasteryStatus.inProgress,
    };
  }

  int _nextBox(int box, MasteryAnswer answer) {
    if (!answer.isCorrect) return firstBox;
    if (answer.isRetry) return box < firstBox ? firstBox : box;
    if (box == 0) return firstRightBox;
    final int cap = answer.answerNature == AnswerNature.recognized
        ? recognizedBoxCap
        : lastBox;
    if (box >= cap) return box;
    return box + 1;
  }

  List<Duration> _keepLastTimes(List<Duration> times) {
    if (times.length <= answerTimeCount) return times;
    return times.sublist(times.length - answerTimeCount);
  }

  bool _isFast(ItemProgressEntity progress) {
    final Duration? median = progress.medianAnswerTime;
    return progress.lastAnswerTimes.length >= answerTimeCount &&
        median != null &&
        median < masteredSpeed;
  }
}
