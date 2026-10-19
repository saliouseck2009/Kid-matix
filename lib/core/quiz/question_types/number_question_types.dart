import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/expected_answer_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The question types of the numbers up to 100, version 2.0.
///
/// The comparison is a produced answer: its three signs are the same for
/// every question, so nothing is recognized among candidate answers and
/// a comparison can be mastered (owner's decision).
const List<QuestionType> numberQuestionTypes = <QuestionType>[
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.countObjects,
    answerNature: AnswerNature.recognized,
    // Counting up to 20 objects takes longer than reading a fact: twice
    // the time in the timed stages (owner's decision, 2026-10-18).
    timeFactor: 2,
  ),
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.tensAndOnes,
    answerNature: AnswerNature.recognized,
  ),
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.compare,
    answerNature: AnswerNature.produced,
  ),
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.numberLine,
    answerNature: AnswerNature.recognized,
  ),
];
