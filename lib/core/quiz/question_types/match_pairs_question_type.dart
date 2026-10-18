import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The player ties 4 operations to their 4 results.
///
/// Each pair counts for its own item. The question is right only when no
/// pairing failed; it gets twice the time of a timed quiz.
final class MatchPairsQuestionType implements QuestionType {
  /// Creates the question type.
  const MatchPairsQuestionType();

  /// Pairs of a question.
  static const int pairCount = 4;

  @override
  String get id => QuestionTypeIds.matchPairs;

  @override
  AnswerNature get answerNature => AnswerNature.recognized;

  @override
  int get timeFactor => 2;

  @override
  bool isCorrect({required Question question, required Answer answer}) {
    return answer == question.expectedAnswer;
  }
}
