import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/find_operation_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/match_pairs_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/number_question_types.dart';
import 'package:kid_matix/core/quiz/question_types/version_one_question_types.dart';
import 'package:kid_matix/core/quiz/question_types/word_question_types.dart';

/// Every question type of the app, to register at startup: those of
/// version 1.0, then those of version 1.1, then those of the numbers and
/// of the math words of version 2.0.
const List<QuestionType> appQuestionTypes = <QuestionType>[
  ...versionOneQuestionTypes,
  FindOperationQuestionType(),
  MatchPairsQuestionType(),
  ...numberQuestionTypes,
  ...wordQuestionTypes,
];
