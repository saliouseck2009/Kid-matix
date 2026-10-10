import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';

/// Returns the items a player should review today: the longest overdue
/// first, then, on the same day, the lowest success rate first.
class GetDueFactsUseCase
    implements UseCase<DataState<List<ItemProgressEntity>>, MasteryScope> {
  /// Creates the use case.
  const GetDueFactsUseCase({
    required this._repository,
    required this._clock,
    this._policy = const MasteryPolicy(),
  });

  final ItemProgressRepository _repository;
  final Clock _clock;
  final MasteryPolicy _policy;

  @override
  Future<DataState<List<ItemProgressEntity>>> call({
    required MasteryScope params,
  }) async {
    final DataState<List<ItemProgressEntity>> progress = await _repository
        .getProgress(profileId: params.profileId, domainId: params.domainId);
    if (progress is DataFailed<List<ItemProgressEntity>>) return progress;
    final DateTime now = _clock.now();
    final List<ItemProgressEntity> due =
        (progress as DataSuccess<List<ItemProgressEntity>>).data
            .where(
              (ItemProgressEntity item) =>
                  _policy.isDue(progress: item, now: now),
            )
            .toList()
          ..sort(_compare);
    return DataSuccess<List<ItemProgressEntity>>(due);
  }

  static int _compare(ItemProgressEntity a, ItemProgressEntity b) {
    final int byDate = a.nextReviewAt!.compareTo(b.nextReviewAt!);
    if (byDate != 0) return byDate;
    return _successRate(a).compareTo(_successRate(b));
  }

  static double _successRate(ItemProgressEntity item) {
    if (item.presentationCount == 0) return 0;
    return item.correctCount / item.presentationCount;
  }
}
