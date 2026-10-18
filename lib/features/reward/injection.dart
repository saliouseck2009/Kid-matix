import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/core/services/xp_award_service.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/reward/domain/services/reward_service_impl.dart';
import 'package:kid_matix/features/reward/domain/services/xp_award_service_impl.dart';
import 'package:kid_matix/features/reward/domain/usecases/award_xp_use_case.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_local_data_source.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_repository_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_session_hook.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_badges_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_daily_goal_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_player_level_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_session_rewards_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_streak_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_total_xp_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_backup_part.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_reset_hook.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_local_data_source.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_visibility_local_data_source.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_visibility_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/leaderboard_repository_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/leaderboard_visibility_repository_impl.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_repository.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_visibility_repository.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/set_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_leaderboard_visibility_use_case.dart';

/// Registers the reward feature in [sl] and adds its session hook;
/// Blocs are never registered.
void registerRewardFeature(GetIt sl) {
  sl.registerLazySingleton<RewardLocalDataSource>(
    () => RewardLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<RewardRepository>(
    () => RewardRepositoryImpl(rewards: sl(), changeBus: sl()),
  );
  sl.registerLazySingleton<GetStreakUseCase>(
    () => GetStreakUseCase(repository: sl(), clock: sl()),
  );
  sl.registerLazySingleton<GetBadgesUseCase>(
    () => GetBadgesUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetPlayerLevelUseCase>(
    () => GetPlayerLevelUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetTotalXpUseCase>(
    () => GetTotalXpUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetDailyGoalUseCase>(
    () => GetDailyGoalUseCase(repository: sl(), settings: sl(), clock: sl()),
  );
  sl.registerLazySingleton<GetSessionRewardsUseCase>(
    () => GetSessionRewardsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<WatchRewardChangesUseCase>(
    () => WatchRewardChangesUseCase(repository: sl()),
  );
  sl.registerLazySingleton<RewardService>(
    () => RewardServiceImpl(
      getTotalXp: sl(),
      getLevel: sl(),
      getBadges: sl(),
      getStreak: sl(),
      watchChanges: sl(),
    ),
  );
  sl.registerLazySingleton<AwardXpUseCase>(
    () => AwardXpUseCase(repository: sl(), ids: sl(), clock: sl()),
  );
  sl.registerLazySingleton<XpAwardService>(
    () => XpAwardServiceImpl(awardXp: sl()),
  );
  sl<SessionSavedHooks>().add(
    RewardSessionHook(
      rewards: sl(),
      mastery: sl(),
      learningPath: sl(),
      domains: sl(),
      clock: sl(),
    ),
  );
  sl<ProgressResetHooks>().add(const RewardResetHook());
  sl<ProfileBackupParts>().add(const RewardBackupPart());
  _registerLeaderboard(sl);
}

/// Registers the weekly leaderboard of the phone and its setting.
void _registerLeaderboard(GetIt sl) {
  sl.registerLazySingleton<LeaderboardLocalDataSource>(
    () => LeaderboardLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(local: sl(), players: sl()),
  );
  sl.registerLazySingleton<GetLeaderboardUseCase>(
    () => GetLeaderboardUseCase(repository: sl(), clock: sl()),
  );
  sl.registerLazySingleton<LeaderboardVisibilityLocalDataSource>(
    () => LeaderboardVisibilityLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<LeaderboardVisibilityRepository>(
    () => LeaderboardVisibilityRepositoryImpl(local: sl()),
  );
  sl.registerLazySingleton<GetLeaderboardVisibilityUseCase>(
    () => GetLeaderboardVisibilityUseCase(repository: sl()),
  );
  sl.registerLazySingleton<SetLeaderboardVisibilityUseCase>(
    () => SetLeaderboardVisibilityUseCase(repository: sl()),
  );
  sl.registerLazySingleton<WatchLeaderboardVisibilityUseCase>(
    () => WatchLeaderboardVisibilityUseCase(repository: sl()),
  );
}
