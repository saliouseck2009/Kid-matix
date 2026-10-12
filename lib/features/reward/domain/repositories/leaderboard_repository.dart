import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_scope.dart';

/// The players of a leaderboard and the XP they earned.
///
/// The same contract serves the phone today and the online scopes later,
/// so the screen and its Cubit never change.
abstract interface class LeaderboardRepository {
  /// Returns every player of [scope] with the XP earned from [from],
  /// included, to [to], excluded, quizzes and duels together; a player
  /// who earned nothing has 0. The order is not specified.
  Future<DataState<List<LeaderboardEntry>>> getEntries({
    required LeaderboardScope scope,
    required DateTime from,
    required DateTime to,
  });
}
