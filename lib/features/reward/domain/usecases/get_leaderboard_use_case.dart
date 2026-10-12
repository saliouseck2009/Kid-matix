import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_scope.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_repository.dart';
import 'package:kid_matix/features/reward/domain/services/leaderboard_policy.dart';

/// Returns the players of a scope ranked by the XP they earned since
/// Monday 00:00; the ranking starts again from zero every Monday.
class GetLeaderboardUseCase
    implements UseCase<DataState<LeaderboardEntity>, LeaderboardScope> {
  /// Creates the use case.
  const GetLeaderboardUseCase({
    required this._repository,
    required this._clock,
  });

  final LeaderboardRepository _repository;
  final Clock _clock;

  @override
  Future<DataState<LeaderboardEntity>> call({
    required LeaderboardScope params,
  }) async {
    final DateTime weekStart = LeaderboardPolicy.weekStartOf(_clock.now());
    final DataState<List<LeaderboardEntry>> read = await _repository.getEntries(
      scope: params,
      from: weekStart,
      to: LeaderboardPolicy.nextWeekStartOf(weekStart),
    );
    return switch (read) {
      DataSuccess<List<LeaderboardEntry>>(:final data) =>
        DataSuccess<LeaderboardEntity>(
          LeaderboardEntity(
            entries: LeaderboardPolicy.rank(data),
            weekStart: weekStart,
          ),
        ),
      DataFailed<List<LeaderboardEntry>>(:final exception) =>
        DataFailed<LeaderboardEntity>(exception),
    };
  }
}
