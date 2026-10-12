import 'package:kid_matix/features/reward/domain/repositories/leaderboard_visibility_repository.dart';

/// Emits whether the leaderboard is shown, each time the setting changes.
class WatchLeaderboardVisibilityUseCase {
  /// Creates the use case over [repository].
  const WatchLeaderboardVisibilityUseCase({required this._repository});

  final LeaderboardVisibilityRepository _repository;

  /// Returns the stream of values.
  Stream<bool> call() => _repository.watchShown();
}
