import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';

/// A way to ask an item and collect the answer, shared by every domain.
///
/// Its answer widget belongs to the quiz screen; here it only describes how
/// an answer is judged and what kind of answer it collects.
abstract interface class QuestionType {
  /// Stable identifier, such as `multipleChoice`.
  String get id;

  /// Whether the answer is picked or written.
  AnswerNature get answerNature;

  /// Whether [answer] is right for [question].
  bool isCorrect({required Question question, required Answer answer});
}
