import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The player picks the result among four numbers.
final class MultipleChoiceQuestionType implements QuestionType {
  /// Creates the question type.
  const MultipleChoiceQuestionType();

  @override
  String get id => QuestionTypeIds.multipleChoice;

  @override
  AnswerNature get answerNature => AnswerNature.recognized;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}
