import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/expected_answer_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/question_types/touch_to_understand_question_type.dart';

/// The question types of the math words, version 2.0 (lot F28).
///
/// The statement format is a produced answer: its four operations are the
/// same for every statement, so nothing is recognized among candidate
/// answers, as for the comparison of the numbers. Touching the words of a
/// sentence is discovery only: it moves no box. A statement takes twice
/// the time of a timed quiz, since it is read first.
const List<QuestionType> wordQuestionTypes = <QuestionType>[
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.listenAndTouch,
    answerNature: AnswerNature.recognized,
  ),
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.wordAndImage,
    answerNature: AnswerNature.recognized,
    timeFactor: 2,
  ),
  TouchToUnderstandQuestionType(),
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.whichOperation,
    answerNature: AnswerNature.produced,
    timeFactor: 2,
  ),
];
