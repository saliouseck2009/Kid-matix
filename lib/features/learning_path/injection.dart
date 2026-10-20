import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/core/services/learning_path_service.dart';
import 'package:kid_matix/features/learning_path/domain/services/crown_service_impl.dart';
import 'package:kid_matix/features/learning_path/domain/services/open_units_service_impl.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/learning_path/data/datasources/stage_progress_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/datasources/stage_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_repository_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_session_hook.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_service_impl.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/build_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_placement_history_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/save_placement_result_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_placement_results_use_case.dart';
import 'package:kid_matix/features/learning_path/data/datasources/placement_result_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/datasources/placement_result_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/placement_result_repository_impl.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_learning_path_changes_use_case.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_backup_part.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_reset_hook.dart';
import 'package:kid_matix/features/learning_path/data/datasources/path_domain_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/datasources/path_domain_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/path_domain_repository_impl.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/path_domain_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_domain_choice_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/select_domain_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_domain_choice_use_case.dart';

/// Registers the learning path feature in [sl] and adds its session hook;
/// Blocs are never registered.
void registerLearningPathFeature(GetIt sl) {
  sl.registerLazySingleton<StageProgressLocalDataSource>(
    () => StageProgressLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<StageProgressRepository>(
    () => StageProgressRepositoryImpl(
      progress: sl(),
      changeBus: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<PlacementResultLocalDataSource>(
    () => PlacementResultLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<PlacementResultRepository>(
    () => PlacementResultRepositoryImpl(
      results: sl(),
      changeBus: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<GetLearningPathUseCase>(
    () => GetLearningPathUseCase(
      repository: sl(),
      domains: sl(),
      settings: sl(),
      mastery: sl(),
      placements: sl<PlacementResultRepository>(),
    ),
  );
  sl.registerLazySingleton<BuildPlacementQuestionUseCase>(
    () => BuildPlacementQuestionUseCase(domains: sl(), random: sl()),
  );
  sl.registerLazySingleton<SavePlacementResultUseCase>(
    () => SavePlacementResultUseCase(
      results: sl(),
      stages: sl(),
      domains: sl(),
    ),
  );
  sl.registerLazySingleton<GetPlacementHistoryUseCase>(
    () => GetPlacementHistoryUseCase(repository: sl()),
  );
  sl.registerLazySingleton<WatchPlacementResultsUseCase>(
    () => WatchPlacementResultsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<AnswerPlacementQuestionUseCase>(
    () => AnswerPlacementQuestionUseCase(repository: sl(), mastery: sl()),
  );
  sl.registerLazySingleton<WatchLearningPathChangesUseCase>(
    () => WatchLearningPathChangesUseCase(repository: sl()),
  );
  _registerDomainChoice(sl);
  sl.registerLazySingleton<LearningPathService>(LearningPathServiceImpl.new);
  sl.registerLazySingleton<CrownService>(
    () => CrownServiceImpl(getPath: sl(), watchChanges: sl(), domains: sl()),
  );
  sl.registerLazySingleton<OpenUnitsService>(
    () => OpenUnitsServiceImpl(
      getPath: sl(),
      domainId: LearningDomainIds.multiplication,
    ),
  );
  sl<SessionSavedHooks>().add(
    StageProgressSessionHook(progress: sl(), clock: sl()),
  );
  sl<ProgressResetHooks>().add(const StageProgressResetHook());
  sl<ProfileBackupParts>().add(const StageProgressBackupPart());
}

/// The domain each player last chose on the map, kept on the device.
void _registerDomainChoice(GetIt sl) {
  sl.registerLazySingleton<PathDomainLocalDataSource>(
    () => PathDomainLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<PathDomainRepository>(
    () => PathDomainRepositoryImpl(domains: sl()),
  );
  sl.registerLazySingleton<GetDomainChoiceUseCase>(
    () => GetDomainChoiceUseCase(repository: sl(), domains: sl()),
  );
  sl.registerLazySingleton<SelectDomainUseCase>(
    () => SelectDomainUseCase(repository: sl()),
  );
  sl.registerLazySingleton<WatchDomainChoiceUseCase>(
    () => WatchDomainChoiceUseCase(repository: sl()),
  );
}
