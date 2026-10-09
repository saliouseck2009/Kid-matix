import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/missing_number_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/multiple_choice_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/true_false_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/typed_answer_question_type.dart';

/// The question types of version 1.0, to register at startup.
const List<QuestionType> versionOneQuestionTypes = <QuestionType>[
  MultipleChoiceQuestionType(),
  TypedAnswerQuestionType(),
  MissingNumberQuestionType(),
  TrueFalseQuestionType(),
];
