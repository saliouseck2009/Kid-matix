import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/expected_answer_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

/// The question types of the word problems, version 2.0 (lot F30).
///
/// The two boards (guided solving, bar model) chain several steps and end
/// with one answer, right when no step was missed, as the pairs do; they
/// are produced answers. Picking the operation of a statement is the short
/// format of the timed stages and takes three times the time, since the
/// statement is read first.
const List<QuestionType> problemQuestionTypes = <QuestionType>[
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.solveProblem,
    answerNature: AnswerNature.produced,
  ),
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.barModel,
    answerNature: AnswerNature.produced,
  ),
  ExpectedAnswerQuestionType(
    id: QuestionTypeIds.problemOperation,
    answerNature: AnswerNature.recognized,
    timeFactor: 3,
  ),
];
