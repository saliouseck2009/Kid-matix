import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';

/// Emits an event each time the rewards of a player may have changed.
class WatchRewardChangesUseCase {
  /// Creates the use case over [repository].
  const WatchRewardChangesUseCase({required this._repository});

  final RewardRepository _repository;

  /// Returns the stream of changes.
  Stream<void> call() => _repository.watchChanges();
}
