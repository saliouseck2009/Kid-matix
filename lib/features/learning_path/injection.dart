import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/learning_path_service.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/learning_path/data/datasources/stage_progress_local_data_source.dart';
import 'package:kid_matix/features/learning_path/data/datasources/stage_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_repository_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_session_hook.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_service_impl.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';

/// Registers the learning path feature in [sl] and adds its session hook;
/// Blocs are never registered.
void registerLearningPathFeature(GetIt sl) {
  sl.registerLazySingleton<StageProgressLocalDataSource>(
    () => StageProgressLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<StageProgressRepository>(
    () => StageProgressRepositoryImpl(progress: sl()),
  );
  sl.registerLazySingleton<GetLearningPathUseCase>(
    () => GetLearningPathUseCase(
      repository: sl(),
      domains: sl(),
      settings: sl(),
    ),
  );
  sl.registerLazySingleton<LearningPathService>(LearningPathServiceImpl.new);
  sl<SessionSavedHooks>().add(
    StageProgressSessionHook(progress: sl(), clock: sl()),
  );
}
