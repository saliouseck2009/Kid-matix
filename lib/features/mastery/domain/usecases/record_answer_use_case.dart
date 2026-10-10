import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_answer.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';

/// Updates the progress of an item right after an answer, so a quiz left
/// or an app closed midway loses nothing.
///
/// Fails with a `ValidationException` when the question type is unknown.
class RecordAnswerUseCase
    implements UseCase<DataState<ItemProgressEntity>, ItemAnswer> {
  /// Creates the use case.
  const RecordAnswerUseCase({
    required this._repository,
    required this._questionTypes,
    required this._clock,
    this._policy = const MasteryPolicy(),
  });

  final ItemProgressRepository _repository;
  final QuestionTypeRegistry _questionTypes;
  final Clock _clock;
  final MasteryPolicy _policy;

  @override
  Future<DataState<ItemProgressEntity>> call({
    required ItemAnswer params,
  }) async {
    final QuestionType? type = _questionTypes.find(params.questionTypeId);
    if (type == null) {
      return const DataFailed<ItemProgressEntity>(
        ValidationException(message: 'Unknown question type.'),
      );
    }
    final DataState<ItemProgressEntity> stored = await _repository
        .getItemProgress(
          profileId: params.profileId,
          domainId: params.domainId,
          itemKey: params.itemKey,
        );
    if (stored is DataFailed<ItemProgressEntity>) return stored;
    final ItemProgressEntity progress = _policy.apply(
      progress: (stored as DataSuccess<ItemProgressEntity>).data,
      answer: MasteryAnswer(
        isCorrect: params.isCorrect,
        answerNature: type.answerNature,
        answerTime: params.answerTime,
        isRetry: params.isRetry,
      ),
      now: _clock.now(),
    );
    return switch (await _repository.saveProgress(progress: progress)) {
      DataSuccess<void>() => DataSuccess<ItemProgressEntity>(progress),
      DataFailed<void>(:final exception) => DataFailed<ItemProgressEntity>(
        exception,
      ),
    };
  }
}
