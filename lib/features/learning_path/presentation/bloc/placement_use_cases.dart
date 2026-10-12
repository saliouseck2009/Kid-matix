import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/run_placement_test_use_case.dart';

/// Use cases of the placement test, grouped so the Bloc takes one
/// argument.
final class PlacementUseCases {
  /// Groups the use cases.
  const PlacementUseCases({
    required this.runTest,
    required this.answerQuestion,
  });

  /// Builds the test.
  final RunPlacementTestUseCase runTest;

  /// Records an answer and opens its table when it is right.
  final AnswerPlacementQuestionUseCase answerQuestion;
}
