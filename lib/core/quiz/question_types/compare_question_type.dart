import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The player tells how two numbers compare with one of three signs:
/// smaller, equal or greater.
///
/// The three signs are the same for every question, so nothing is
/// recognized among candidate answers: the player decides the relation,
/// and the answer counts as produced for the mastery engine.
final class CompareQuestionType implements QuestionType {
  /// Creates the question type.
  const CompareQuestionType();

  @override
  String get id => QuestionTypeIds.compare;

  @override
  AnswerNature get answerNature => AnswerNature.produced;

  @override
  int get timeFactor => 1;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}
