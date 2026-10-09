import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The player says whether the statement shown is true.
final class TrueFalseQuestionType implements QuestionType {
  /// Creates the question type.
  const TrueFalseQuestionType();

  @override
  String get id => QuestionTypeIds.trueFalse;

  @override
  AnswerNature get answerNature => AnswerNature.recognized;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}
