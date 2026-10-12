import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/placement_answer_params.dart';

/// Records one answer of the placement test as soon as it is given and
/// returns whether it was right.
///
/// The answer counts in the mastery like a quiz answer: a right one moves
/// the fact up a box, a wrong one or "Je ne sais pas" sends it back to
/// "À revoir". A right answer opens the unit of the question on the
/// learning path, without any star; so a test left midway keeps the
/// units already found.
class AnswerPlacementQuestionUseCase
    implements UseCase<DataState<bool>, PlacementAnswerParams> {
  /// Creates the use case.
  const AnswerPlacementQuestionUseCase({
    required this._repository,
    required this._mastery,
  });

  final StageProgressRepository _repository;
  final MasteryService _mastery;

  @override
  Future<DataState<bool>> call({required PlacementAnswerParams params}) async {
    final bool isCorrect = params.answer == params.question.expectedAnswer;
    final DataState<void> recorded = await _mastery.recordAnswer(
      answer: ItemAnswer(
        profileId: params.profileId,
        domainId: params.domainId,
        itemKey: params.question.itemKey,
        questionTypeId: params.question.questionTypeId,
        isCorrect: isCorrect,
        answerTime: params.answerTime,
      ),
    );
    if (recorded case DataFailed<void>(:final exception)) {
      return DataFailed<bool>(exception);
    }
    if (!isCorrect) return const DataSuccess<bool>(false);
    final DataState<void> opened = await _repository.openUnit(
      profileId: params.profileId,
      domainId: params.domainId,
      unitKey: params.question.unitKey,
    );
    return switch (opened) {
      DataSuccess<void>() => const DataSuccess<bool>(true),
      DataFailed<void>(:final exception) => DataFailed<bool>(exception),
    };
  }
}
