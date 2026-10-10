import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/mastery/data/repositories/item_progress_repository_impl.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_service_impl.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_due_facts_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/watch_mastery_changes_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/plan_quiz_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/record_answer_use_case.dart';
import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/mastery/data/repositories/mastery_reset_hook.dart';

/// Registers the mastery feature in [sl]; Blocs are never registered.
void registerMasteryFeature(GetIt sl) {
  sl.registerLazySingleton<ItemProgressLocalDataSource>(
    () => ItemProgressLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<ItemProgressRepository>(
    () => ItemProgressRepositoryImpl(
      progress: sl(),
      clock: sl(),
      changeBus: sl(),
    ),
  );
  sl.registerLazySingleton<RecordAnswerUseCase>(
    () => RecordAnswerUseCase(
      repository: sl(),
      questionTypes: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<PlanQuizUseCase>(
    () => PlanQuizUseCase(
      repository: sl(),
      domains: sl(),
      questionTypes: sl(),
      random: sl(),
    ),
  );
  sl.registerLazySingleton<GetDueFactsUseCase>(
    () => GetDueFactsUseCase(repository: sl(), clock: sl()),
  );
  sl.registerLazySingleton<GetMasteryGridUseCase>(
    () => GetMasteryGridUseCase(repository: sl(), domains: sl()),
  );
  sl.registerLazySingleton<WatchMasteryChangesUseCase>(
    () => WatchMasteryChangesUseCase(repository: sl()),
  );
  sl.registerLazySingleton<MasteryService>(
    () => MasteryServiceImpl(
      planQuiz: sl(),
      recordAnswer: sl(),
      getGrid: sl(),
    ),
  );
  sl<ProgressResetHooks>().add(const MasteryResetHook());
}
