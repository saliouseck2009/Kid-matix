import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';

/// The combo: right answers in a row, celebrated at 3, 5 and 10.
abstract final class QuizCombo {
  /// Combos celebrated during a quiz.
  static const List<int> milestones = <int>[3, 5, 10];

  /// Combo from which the counter shows.
  static const int shownFrom = 2;

  /// Right answers in a row at the end of [answers].
  static int countOf(List<QuizAnswerEntity> answers) {
    int count = 0;
    for (final QuizAnswerEntity answer in answers.reversed) {
      if (!answer.isCorrect) break;
      count++;
    }
    return count;
  }

  /// Whether [count] right answers in a row are celebrated.
  static bool isMilestone(int count) => milestones.contains(count);
}
