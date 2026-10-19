import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/discovery_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The child touches the math words of a sentence to hear and see them
/// (lot F28). It is discovery only: touching the word asked ends the
/// question, and the word is recorded as presented, not answered.
final class TouchToUnderstandQuestionType implements DiscoveryQuestionType {
  /// Creates the question type.
  const TouchToUnderstandQuestionType();

  @override
  String get id => QuestionTypeIds.touchToUnderstand;

  @override
  AnswerNature get answerNature => AnswerNature.recognized;

  @override
  int get timeFactor => 2;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}
