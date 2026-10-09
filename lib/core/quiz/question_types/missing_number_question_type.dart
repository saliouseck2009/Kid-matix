import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The player writes the number missing from the operation.
final class MissingNumberQuestionType implements QuestionType {
  /// Creates the question type.
  const MissingNumberQuestionType();

  @override
  String get id => QuestionTypeIds.missingNumber;

  @override
  AnswerNature get answerNature => AnswerNature.produced;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}
