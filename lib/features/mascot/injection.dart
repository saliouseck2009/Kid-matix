import 'package:get_it/get_it.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_local_data_source.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_local_data_source_impl.dart';
import 'package:kid_matix/features/mascot/data/repositories/mascot_repository_impl.dart';
import 'package:kid_matix/features/mascot/domain/repositories/mascot_repository.dart';
import 'package:kid_matix/features/mascot/domain/usecases/get_mascot_use_case.dart';
import 'package:kid_matix/features/mascot/domain/usecases/update_mascot_use_cases.dart';
import 'package:kid_matix/features/mascot/domain/usecases/watch_mascot_changes_use_case.dart';

/// Registers the mascot feature in [sl]; Blocs are never registered.
void registerMascotFeature(GetIt sl) {
  sl.registerLazySingleton<MascotLocalDataSource>(
    () => MascotLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<MascotRepository>(
    () => MascotRepositoryImpl(mascots: sl(), clock: sl(), changeBus: sl()),
  );
  sl.registerLazySingleton<GetMascotUseCase>(
    () => GetMascotUseCase(repository: sl(), rewards: sl(), crowns: sl()),
  );
  sl.registerLazySingleton<WatchMascotChangesUseCase>(
    () => WatchMascotChangesUseCase(
      repository: sl(),
      rewards: sl(),
      crowns: sl(),
    ),
  );
  sl.registerLazySingleton<UpdateMascotUseCases>(
    () => UpdateMascotUseCases(repository: sl()),
  );
}
