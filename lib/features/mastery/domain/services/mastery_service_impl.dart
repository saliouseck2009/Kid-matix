import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/usecases/plan_quiz_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/record_answer_use_case.dart';

/// [MasteryService] over the use cases of the mastery feature.
final class MasteryServiceImpl implements MasteryService {
  /// Creates the service.
  const MasteryServiceImpl({
    required this._planQuiz,
    required this._recordAnswer,
  });

  final PlanQuizUseCase _planQuiz;
  final RecordAnswerUseCase _recordAnswer;

  @override
  Future<DataState<List<QuizItemPlan>>> planQuiz({
    required QuizPlanRequest request,
  }) {
    return _planQuiz(params: request);
  }

  @override
  Future<DataState<void>> recordAnswer({required ItemAnswer answer}) async {
    return switch (await _recordAnswer(params: answer)) {
      DataSuccess<ItemProgressEntity>() => const DataSuccess<void>(null),
      DataFailed<ItemProgressEntity>(:final exception) => DataFailed<void>(
        exception,
      ),
    };
  }
}
