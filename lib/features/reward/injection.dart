import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
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
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';

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
  sl.registerLazySingleton<GetDailyGoalUseCase>(
    () => GetDailyGoalUseCase(repository: sl(), settings: sl(), clock: sl()),
  );
  sl.registerLazySingleton<GetSessionRewardsUseCase>(
    () => GetSessionRewardsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<WatchRewardChangesUseCase>(
    () => WatchRewardChangesUseCase(repository: sl()),
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
}
