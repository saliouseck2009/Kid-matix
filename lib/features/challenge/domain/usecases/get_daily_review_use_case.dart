import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/review_overview.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// What the daily review of a player holds: the facts due today and
/// whether they have seen any fact yet.
class GetDailyReviewUseCase
    implements UseCase<DataState<ReviewOverview>, String> {
  /// Creates the use case.
  const GetDailyReviewUseCase({required this._mastery});

  /// Domain of the facts reviewed.
  static const String domainId = LearningDomainIds.multiplication;

  final MasteryService _mastery;

  /// Returns the review overview of the player [params].
  @override
  Future<DataState<ReviewOverview>> call({required String params}) {
    return _mastery.readReviewOverview(profileId: params, domainId: domainId);
  }
}
