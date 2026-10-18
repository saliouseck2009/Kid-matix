import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/services/review_item_selector.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';

/// Returns the items a player should review today: the longest overdue
/// first, then, on the same day, the lowest success rate first.
class GetDueFactsUseCase
    implements UseCase<DataState<List<ItemProgressEntity>>, MasteryScope> {
  /// Creates the use case.
  const GetDueFactsUseCase({
    required this._repository,
    required this._clock,
    this._selector = const ReviewItemSelector(),
  });

  final ItemProgressRepository _repository;
  final Clock _clock;
  final ReviewItemSelector _selector;

  @override
  Future<DataState<List<ItemProgressEntity>>> call({
    required MasteryScope params,
  }) async {
    final DataState<List<ItemProgressEntity>> progress = await _repository
        .getProgress(profileId: params.profileId, domainId: params.domainId);
    return switch (progress) {
      DataSuccess<List<ItemProgressEntity>>(:final data) =>
        DataSuccess<List<ItemProgressEntity>>(
          _selector.dueOf(progress: data, now: _clock.now()),
        ),
      DataFailed<List<ItemProgressEntity>>() => progress,
    };
  }
}
