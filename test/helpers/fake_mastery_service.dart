import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/services/mastery_service.dart';

/// [MasteryService] that plans the items in the order given and keeps the
/// answers it records.
final class FakeMasteryService implements MasteryService {
  /// Creates the service; with [failure], every call fails with it.
  FakeMasteryService({this.failure});

  /// Failure of every call, or `null` for success.
  AppException? failure;

  /// Answers recorded so far, in order.
  final List<ItemAnswer> recordedAnswers = <ItemAnswer>[];

  /// Items reported as mastered.
  final Set<String> masteredItems = <String>{};

  @override
  Future<DataState<Set<String>>> readMasteredItems({
    required String profileId,
    required String domainId,
  }) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<Set<String>>(error);
    return DataSuccess<Set<String>>(Set<String>.of(masteredItems));
  }

  @override
  Future<DataState<List<QuizItemPlan>>> planQuiz({
    required QuizPlanRequest request,
  }) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<List<QuizItemPlan>>(error);
    if (request.itemKeys.isEmpty) {
      return const DataSuccess<List<QuizItemPlan>>(<QuizItemPlan>[]);
    }
    return DataSuccess<List<QuizItemPlan>>(<QuizItemPlan>[
      for (int index = 0; index < request.questionCount; index++)
        QuizItemPlan(
          itemKey: request.itemKeys[index % request.itemKeys.length],
          questionTypeIds: request.questionTypeIds,
        ),
    ]);
  }

  @override
  Future<DataState<void>> recordAnswer({required ItemAnswer answer}) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<void>(error);
    recordedAnswers.add(answer);
    return const DataSuccess<void>(null);
  }
}
