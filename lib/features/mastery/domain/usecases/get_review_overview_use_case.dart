import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/review_overview.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';
import 'package:kid_matix/features/mastery/domain/services/review_item_selector.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';

/// Counts the items a player has to review today and the items they
/// have already been asked.
class GetReviewOverviewUseCase
    implements UseCase<DataState<ReviewOverview>, MasteryScope> {
  /// Creates the use case.
  const GetReviewOverviewUseCase({
    required this._repository,
    required this._clock,
    this._selector = const ReviewItemSelector(),
  });

  final ItemProgressRepository _repository;
  final Clock _clock;
  final ReviewItemSelector _selector;

  @override
  Future<DataState<ReviewOverview>> call({required MasteryScope params}) async {
    final DataState<List<ItemProgressEntity>> progress = await _repository
        .getProgress(profileId: params.profileId, domainId: params.domainId);
    return switch (progress) {
      DataSuccess<List<ItemProgressEntity>>(:final data) =>
        DataSuccess<ReviewOverview>(
          ReviewOverview(
            dueCount: _selector.dueOf(progress: data, now: _clock.now()).length,
            seenCount: data
                .where(
                  (ItemProgressEntity item) =>
                      item.box >= MasteryPolicy.firstBox,
                )
                .length,
          ),
        ),
      DataFailed<List<ItemProgressEntity>>(:final exception) =>
        DataFailed<ReviewOverview>(exception),
    };
  }
}
