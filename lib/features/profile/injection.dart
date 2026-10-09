import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/services/player_settings_service_impl.dart';
import 'package:kid_matix/features/profile/domain/usecases/clear_active_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_session_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_profile_changes_use_case.dart';
import 'package:kid_matix/features/profile/presentation/session/profile_session_service_impl.dart';

/// Registers the profile feature in [sl]; Blocs are never registered.
void registerProfileFeature(GetIt sl) {
  _registerData(sl);
  _registerUseCases(sl);
  sl.registerLazySingleton<PlayerSettingsService>(
    () => PlayerSettingsServiceImpl(repository: sl()),
  );
  sl.registerLazySingleton<ProfileSessionService>(
    () => ProfileSessionServiceImpl(getSession: sl(), watchChanges: sl()),
  );
}

void _registerData(GetIt sl) {
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<ActiveProfileLocalDataSource>(
    () => ActiveProfileLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      profiles: sl(),
      activeProfile: sl(),
      clock: sl(),
      changeBus: sl(),
    ),
  );
}

void _registerUseCases(GetIt sl) {
  sl.registerLazySingleton<NicknameChecker>(
    () => NicknameChecker(repository: sl()),
  );
  sl.registerLazySingleton<GetProfilesUseCase>(
    () => GetProfilesUseCase(repository: sl()),
  );
  sl.registerLazySingleton<CreateProfileUseCase>(
    () => CreateProfileUseCase(
      repository: sl(),
      nicknameChecker: sl(),
      idGenerator: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(repository: sl(), nicknameChecker: sl()),
  );
  sl.registerLazySingleton<DeleteProfileUseCase>(
    () => DeleteProfileUseCase(repository: sl()),
  );
  sl.registerLazySingleton<SelectProfileUseCase>(
    () => SelectProfileUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetProfileSessionUseCase>(
    () => GetProfileSessionUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ClearActiveProfileUseCase>(
    () => ClearActiveProfileUseCase(repository: sl()),
  );
  sl.registerLazySingleton<WatchProfileChangesUseCase>(
    () => WatchProfileChangesUseCase(repository: sl()),
  );
}
