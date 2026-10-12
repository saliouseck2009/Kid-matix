import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The player picks, among four operations, the only one that gives the
/// result shown.
final class FindOperationQuestionType implements QuestionType {
  /// Creates the question type.
  const FindOperationQuestionType();

  @override
  String get id => QuestionTypeIds.findOperation;

  @override
  AnswerNature get answerNature => AnswerNature.recognized;

  @override
  int get timeFactor => 1;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}
