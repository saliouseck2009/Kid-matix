import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/teacher_area_lock.dart';
import 'package:kid_matix/core/services/teacher_session_service.dart';
import 'package:kid_matix/features/classroom/domain/services/teacher_code_attempts.dart';
import 'package:kid_matix/features/classroom/domain/usecases/forget_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_local_data_source_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_repository_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/teacher_code_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/teacher_code_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/pupil_enrollment.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/choose_teacher_code_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/find_unusable_nicknames_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classrooms_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_access_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_teacher_area_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/remove_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/reset_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/select_pupil_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_classroom_changes_use_case.dart';
import 'package:kid_matix/features/classroom/presentation/session/teacher_session_service_impl.dart';

/// Registers the class mode in [sl]; Blocs are never registered.
void registerClassroomFeature(GetIt sl) {
  _registerData(sl);
  _registerTeacherAccess(sl);
  _registerClassrooms(sl);
}

void _registerData(GetIt sl) {
  sl.registerLazySingleton<ClassroomLocalDataSource>(
    () => ClassroomLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<ClassroomRepository>(
    () => ClassroomRepositoryImpl(classrooms: sl(), changeBus: sl()),
  );
  sl.registerLazySingleton<TeacherCodeRepository>(
    () => TeacherCodeRepositoryImpl(storage: sl()),
  );
  sl.registerLazySingleton<TeacherSessionService>(
    () => TeacherSessionServiceImpl(session: sl(), clock: sl()),
  );
  // The use cases see the same object through its pure interface.
  sl.registerLazySingleton<TeacherAreaLock>(
    () => sl<TeacherSessionService>(),
  );
  sl.registerLazySingleton<TeacherCodeAttempts>(TeacherCodeAttempts.new);
}

void _registerTeacherAccess(GetIt sl) {
  sl.registerLazySingleton<GetTeacherAccessUseCase>(
    () => GetTeacherAccessUseCase(codes: sl(), session: sl()),
  );
  sl.registerLazySingleton<ChooseTeacherCodeUseCase>(
    () => ChooseTeacherCodeUseCase(codes: sl(), session: sl()),
  );
  sl.registerLazySingleton<OpenTeacherAreaUseCase>(
    () => OpenTeacherAreaUseCase(
      codes: sl(),
      lock: sl(),
      attempts: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<ForgetTeacherCodeUseCase>(
    () => ForgetTeacherCodeUseCase(codes: sl(), attempts: sl()),
  );
  sl.registerLazySingleton<CloseTeacherAreaUseCase>(
    () => CloseTeacherAreaUseCase(session: sl()),
  );
}

void _registerClassrooms(GetIt sl) {
  sl.registerLazySingleton<PupilEnrollment>(
    () => PupilEnrollment(roster: sl(), ids: sl()),
  );
  sl.registerLazySingleton<GetClassroomsUseCase>(
    () => GetClassroomsUseCase(repository: sl(), roster: sl()),
  );
  sl.registerLazySingleton<GetClassroomRosterUseCase>(
    () => GetClassroomRosterUseCase(repository: sl(), roster: sl()),
  );
  sl.registerLazySingleton<CreateClassroomUseCase>(
    () => CreateClassroomUseCase(
      repository: sl(),
      enrollment: sl(),
      ids: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<AddPupilsUseCase>(
    () => AddPupilsUseCase(roster: sl(), enrollment: sl()),
  );
  sl.registerLazySingleton<FindUnusableNicknamesUseCase>(
    () => FindUnusableNicknamesUseCase(enrollment: sl()),
  );
  sl.registerLazySingleton<SelectPupilUseCase>(
    () => SelectPupilUseCase(roster: sl()),
  );
  sl.registerLazySingleton<ResetPupilUseCase>(
    () => ResetPupilUseCase(roster: sl()),
  );
  sl.registerLazySingleton<RemovePupilUseCase>(
    () => RemovePupilUseCase(roster: sl()),
  );
  sl.registerLazySingleton<WatchClassroomChangesUseCase>(
    () => WatchClassroomChangesUseCase(repository: sl(), roster: sl()),
  );
}
