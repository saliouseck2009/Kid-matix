import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';

/// A question type whose answer is right when it equals the one the
/// question expects: most types differ only by their identifier, how the
/// answer is collected and their time.
final class ExpectedAnswerQuestionType implements QuestionType {
  /// Creates the type [id] collecting [answerNature] answers.
  const ExpectedAnswerQuestionType({
    required this.id,
    required this.answerNature,
    this.timeFactor = 1,
  });

  @override
  final String id;

  @override
  final AnswerNature answerNature;

  @override
  final int timeFactor;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}
