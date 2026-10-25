import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/placement_result_service.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/classroom/data/datasources/assessment_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/assessment_local_data_source_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/assessment_repository_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/assessment_session_hook.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_assessments_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pending_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_assessment_changes_use_case.dart';

/// Registers the class assessments (lot F31) in [sl]: their storage, the
/// hook that keeps a pupil's result at the end of the word check, and
/// their use cases.
void registerClassAssessments(GetIt sl) {
  sl.registerLazySingleton<AssessmentLocalDataSource>(
    () => AssessmentLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<AssessmentRepository>(
    () => AssessmentRepositoryImpl(
      assessments: sl(),
      clock: sl(),
      changeBus: sl(),
    ),
  );
  sl.registerLazySingleton<OpenAssessmentUseCase>(
    () => OpenAssessmentUseCase(repository: sl(), ids: sl(), clock: sl()),
  );
  sl.registerLazySingleton<CloseAssessmentUseCase>(
    () => CloseAssessmentUseCase(repository: sl(), clock: sl()),
  );
  sl.registerLazySingleton<GetClassAssessmentsUseCase>(
    () => GetClassAssessmentsUseCase(getRoster: sl(), assessments: sl()),
  );
  sl.registerLazySingleton<GetPendingAssessmentUseCase>(
    () => GetPendingAssessmentUseCase(roster: sl(), assessments: sl()),
  );
  sl.registerLazySingleton<WatchAssessmentChangesUseCase>(
    () => WatchAssessmentChangesUseCase(classroom: sl(), assessments: sl()),
  );
  sl<SessionSavedHooks>().add(
    AssessmentSessionHook(
      roster: () => sl<PupilRosterService>(),
      placements: () => sl<PlacementResultService>(),
      assessments: sl(),
    ),
  );
}
