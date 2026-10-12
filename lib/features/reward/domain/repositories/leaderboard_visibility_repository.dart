import 'package:kid_matix/core/error/data_state.dart';

/// Whether the leaderboard is shown on this phone, for every player.
abstract interface class LeaderboardVisibilityRepository {
  /// Returns whether the leaderboard is shown; `true` until changed.
  Future<DataState<bool>> isShown();

  /// Shows the leaderboard when [isShown], hides it otherwise.
  Future<DataState<void>> setShown({required bool isShown});

  /// Emits the new value each time it changes.
  Stream<bool> watchShown();
}
