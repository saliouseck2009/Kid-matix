import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/compare_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/count_objects_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/number_line_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/tens_and_ones_question_type.dart';

/// The question types of the numbers up to 100, version 2.0.
const List<QuestionType> numberQuestionTypes = <QuestionType>[
  CountObjectsQuestionType(),
  TensAndOnesQuestionType(),
  CompareQuestionType(),
  NumberLineQuestionType(),
];
