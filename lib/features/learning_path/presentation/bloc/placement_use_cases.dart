import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/build_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/save_placement_result_use_case.dart';

/// Use cases of the placement test, grouped so the Bloc takes one
/// argument.
final class PlacementUseCases {
  /// Groups the use cases.
  const PlacementUseCases({
    required this.buildQuestion,
    required this.answerQuestion,
    required this.saveResult,
  });

  /// Builds the next question.
  final BuildPlacementQuestionUseCase buildQuestion;

  /// Records an answer and opens its units when it is right.
  final AnswerPlacementQuestionUseCase answerQuestion;

  /// Keeps the result of a finished test with its date.
  final SavePlacementResultUseCase saveResult;
}
