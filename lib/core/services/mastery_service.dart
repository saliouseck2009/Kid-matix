import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';

/// The mastery engine, as the features that ask questions see it.
///
/// Implemented by the mastery feature, which owns the progress of each
/// item.
abstract interface class MasteryService {
  /// Chooses the items of a quiz and the question types of each one from
  /// the player's progress.
  Future<DataState<List<QuizItemPlan>>> planQuiz({
    required QuizPlanRequest request,
  });

  /// Updates the progress of the item of [answer] as soon as it is given.
  Future<DataState<void>> recordAnswer({required ItemAnswer answer});

  /// Returns the keys of the items of [domainId] that [profileId] has
  /// mastered.
  Future<DataState<Set<String>>> readMasteredItems({
    required String profileId,
    required String domainId,
  });
}
