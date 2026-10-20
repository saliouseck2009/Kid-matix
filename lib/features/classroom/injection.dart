import 'package:get_it/get_it.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_transfer_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/classroom_merger.dart';
import 'package:kid_matix/features/classroom/domain/usecases/export_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/import_classroom_use_case.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kid_matix/core/services/teacher_area_lock.dart';
import 'package:kid_matix/core/services/teacher_session_service.dart';
import 'package:kid_matix/core/services/assigned_units_service.dart';
import 'package:kid_matix/features/classroom/domain/services/assigned_units_service_impl.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/classroom/data/datasources/assignment_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/assignment_local_data_source_impl.dart';
import 'package:kid_matix/features/classroom/data/datasources/class_journal_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/class_journal_local_data_source_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/assignment_repository_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/class_journal_repository_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_session_hook.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/class_item_catalog.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_overview_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pupil_class_view_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/set_weekly_goal_use_case.dart';
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
  _registerClassWork(sl);
  _registerTransfer(sl);
  sl<SessionSavedHooks>().add(
    ClassroomSessionHook(
      roster: () => sl<PupilRosterService>(),
      journal: sl(),
    ),
  );
}

void _registerTransfer(GetIt sl) {
  sl.registerLazySingleton<ClassroomTransferRepository>(
    () => ClassroomTransferRepositoryImpl(
      files: sl(),
      storage: sl(),
      clock: sl(),
      readAppVersion: () async => (await PackageInfo.fromPlatform()).version,
    ),
  );
  sl.registerLazySingleton<ClassroomMerger>(
    () => ClassroomMerger(
      classrooms: sl(),
      roster: sl(),
      assignments: sl(),
      journal: sl(),
    ),
  );
  sl.registerLazySingleton<ExportClassroomUseCase>(
    () => ExportClassroomUseCase(
      getRoster: sl(),
      assignments: sl(),
      journal: sl(),
      transfers: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<ImportClassroomUseCase>(
    () => ImportClassroomUseCase(transfers: sl(), merger: sl()),
  );
}

void _registerClassWork(GetIt sl) {
  sl.registerLazySingleton<AssignedUnitsService>(
    () => AssignedUnitsServiceImpl(roster: sl(), assignments: sl()),
  );
  sl.registerLazySingleton<ClassItemCatalog>(
    () => ClassItemCatalog(domains: sl()),
  );
  sl.registerLazySingleton<GetClassOverviewUseCase>(
    () => GetClassOverviewUseCase(
      getRoster: sl(),
      assignments: sl(),
      journal: sl(),
      catalog: sl(),
      placements: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<GiveAssignmentUseCase>(
    () => GiveAssignmentUseCase(
      assignments: sl(),
      catalog: sl(),
      ids: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<SetWeeklyGoalUseCase>(
    () => SetWeeklyGoalUseCase(repository: sl(), clock: sl()),
  );
  sl.registerLazySingleton<GetPupilClassViewUseCase>(
    () => GetPupilClassViewUseCase(
      roster: sl(),
      classrooms: sl(),
      assignments: sl(),
      journal: sl(),
      catalog: sl(),
      clock: sl(),
    ),
  );
}

void _registerData(GetIt sl) {
  sl.registerLazySingleton<ClassroomLocalDataSource>(
    () => ClassroomLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<ClassroomRepository>(
    () => ClassroomRepositoryImpl(classrooms: sl(), changeBus: sl()),
  );
  sl.registerLazySingleton<AssignmentLocalDataSource>(
    () => AssignmentLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<AssignmentRepository>(
    () => AssignmentRepositoryImpl(assignments: sl(), changeBus: sl()),
  );
  sl.registerLazySingleton<ClassJournalLocalDataSource>(
    () => ClassJournalLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<ClassJournalRepository>(
    () => ClassJournalRepositoryImpl(
      journal: sl(),
      clock: sl(),
      changeBus: sl(),
    ),
  );
  sl.registerLazySingleton<TeacherCodeRepository>(
    () => TeacherCodeRepositoryImpl(storage: sl()),
  );
  sl.registerLazySingleton<TeacherSessionService>(
    () => TeacherSessionServiceImpl(session: sl()),
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
    () => WatchClassroomChangesUseCase(
      repository: sl(),
      roster: sl(),
      assignments: sl(),
      journal: sl(),
    ),
  );
}
