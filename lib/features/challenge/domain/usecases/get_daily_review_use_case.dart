import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/review_overview.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';

/// What the daily review of a player holds: the facts due today and
/// whether they have seen any fact yet, in every domain.
///
/// The review mixes the missed items of every domain (owner's decision,
/// 2026-10-18), so a fact missed in the additions comes back the next day
/// like a multiplication fact.
class GetDailyReviewUseCase
    implements UseCase<DataState<ReviewOverview>, String> {
  /// Creates the use case.
  const GetDailyReviewUseCase({
    required this._mastery,
    required this._domains,
  });

  final MasteryService _mastery;
  final DomainRegistry _domains;

  /// Returns the review overview of the player [params], summed over the
  /// domains; fails with the first failure met.
  @override
  Future<DataState<ReviewOverview>> call({required String params}) async {
    int dueCount = 0;
    int seenCount = 0;
    for (final LearningDomain domain in _domains.domains) {
      final DataState<ReviewOverview> overview = await _mastery
          .readReviewOverview(profileId: params, domainId: domain.id);
      switch (overview) {
        case DataSuccess<ReviewOverview>(:final data):
          dueCount += data.dueCount;
          seenCount += data.seenCount;
        case DataFailed<ReviewOverview>(:final exception):
          return DataFailed<ReviewOverview>(exception);
      }
    }
    return DataSuccess<ReviewOverview>(
      ReviewOverview(dueCount: dueCount, seenCount: seenCount),
    );
  }
}
