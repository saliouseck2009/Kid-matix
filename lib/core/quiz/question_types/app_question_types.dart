import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/find_operation_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/match_pairs_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/version_one_question_types.dart';

/// Every question type of the app, to register at startup: those of
/// version 1.0, then those of version 1.1.
const List<QuestionType> appQuestionTypes = <QuestionType>[
  ...versionOneQuestionTypes,
  FindOperationQuestionType(),
  MatchPairsQuestionType(),
];
