import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_visibility_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/leaderboard_visibility_repository_impl.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_scope.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_repository.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_visibility_repository.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/set_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_use_cases.dart';
import 'package:kid_matix/features/reward/presentation/leaderboard_pages.dart';

import '../features/quiz/helpers/quiz_fixtures.dart';
import 'in_memory_local_storage.dart';
import 'test_reward_pages.dart';

/// [LeaderboardRepository] returning the entries the test sets.
final class InMemoryLeaderboardRepository implements LeaderboardRepository {
  /// Creates the repository with [entries].
  InMemoryLeaderboardRepository({
    this.entries = const <LeaderboardEntry>[],
  });

  /// Entries returned for any range.
  List<LeaderboardEntry> entries;

  /// Range of the last read, or `null`.
  ({DateTime from, DateTime to})? lastRange;

  @override
  Future<DataState<List<LeaderboardEntry>>> getEntries({
    required LeaderboardScope scope,
    required DateTime from,
    required DateTime to,
  }) async {
    lastRange = (from: from, to: to);
    return DataSuccess<List<LeaderboardEntry>>(entries);
  }
}

/// The visibility repository over [storage], in memory by default.
LeaderboardVisibilityRepository buildTestVisibilityRepository({
  LocalStorage? storage,
}) {
  return LeaderboardVisibilityRepositoryImpl(
    local: LeaderboardVisibilityLocalDataSourceImpl(
      storage: storage ?? InMemoryLocalStorage(),
    ),
  );
}

/// Use cases of the leaderboard over the given fakes.
LeaderboardUseCases buildTestLeaderboardUseCases({
  LeaderboardRepository? leaderboard,
  LeaderboardVisibilityRepository? visibility,
  RewardRepository? rewards,
  Clock? clock,
}) {
  final LeaderboardVisibilityRepository shown =
      visibility ?? buildTestVisibilityRepository();
  return LeaderboardUseCases(
    getLeaderboard: GetLeaderboardUseCase(
      repository: leaderboard ?? InMemoryLeaderboardRepository(),
      clock: clock ?? FakeClock(quizStart),
    ),
    watchRewardChanges: WatchRewardChangesUseCase(
      repository: rewards ?? InMemoryRewardRepository(),
    ),
    getVisibility: GetLeaderboardVisibilityUseCase(repository: shown),
    setVisibility: SetLeaderboardVisibilityUseCase(repository: shown),
    watchVisibility: WatchLeaderboardVisibilityUseCase(repository: shown),
  );
}

/// Leaderboard pages over the given fakes, empty by default.
LeaderboardPages buildTestLeaderboardPages({
  LeaderboardRepository? leaderboard,
  LeaderboardVisibilityRepository? visibility,
}) {
  return LeaderboardPages(
    useCases: buildTestLeaderboardUseCases(
      leaderboard: leaderboard,
      visibility: visibility,
    ),
  );
}
