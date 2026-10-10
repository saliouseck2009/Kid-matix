import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/challenge/data/datasources/record_local_data_source.dart';
import 'package:kid_matix/features/challenge/data/datasources/record_local_data_source_impl.dart';
import 'package:kid_matix/features/challenge/data/datasources/training_choice_local_data_source.dart';
import 'package:kid_matix/features/challenge/data/datasources/training_choice_local_data_source_impl.dart';
import 'package:kid_matix/features/challenge/data/repositories/record_repository_impl.dart';
import 'package:kid_matix/features/challenge/data/repositories/record_session_hook.dart';
import 'package:kid_matix/features/challenge/data/repositories/training_choice_repository_impl.dart';
import 'package:kid_matix/features/challenge/domain/repositories/record_repository.dart';
import 'package:kid_matix/features/challenge/domain/repositories/training_choice_repository.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_records_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_session_record_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_time_attack_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_training_choice_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/save_training_choice_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/watch_record_changes_use_case.dart';

/// Registers the challenge feature in [sl] and adds its session hook;
/// Blocs are never registered.
void registerChallengeFeature(GetIt sl) {
  sl.registerLazySingleton<RecordLocalDataSource>(
    () => RecordLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<TrainingChoiceLocalDataSource>(
    () => TrainingChoiceLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<RecordRepository>(
    () => RecordRepositoryImpl(records: sl(), changeBus: sl()),
  );
  sl.registerLazySingleton<TrainingChoiceRepository>(
    () => TrainingChoiceRepositoryImpl(choices: sl()),
  );
  sl.registerLazySingleton<GetRecordsUseCase>(
    () => GetRecordsUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetSessionRecordUseCase>(
    () => GetSessionRecordUseCase(repository: sl()),
  );
  sl.registerLazySingleton<WatchRecordChangesUseCase>(
    () => WatchRecordChangesUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetTrainingChoiceUseCase>(
    () => GetTrainingChoiceUseCase(
      repository: sl(),
      openUnits: sl(),
      settings: sl(),
    ),
  );
  sl.registerLazySingleton<SaveTrainingChoiceUseCase>(
    () => SaveTrainingChoiceUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetTimeAttackUseCase>(
    () => GetTimeAttackUseCase(openUnits: sl()),
  );
  sl<SessionSavedHooks>().add(RecordSessionHook(records: sl(), clock: sl()));
}
