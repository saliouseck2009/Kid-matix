import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/services/placement_result_service.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/classroom/data/datasources/assessment_local_data_source.dart';
import 'package:kid_matix/features/classroom/data/datasources/assessment_local_data_source_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/assessment_repository_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/assessment_session_hook.dart';
import 'package:kid_matix/features/classroom/data/repositories/report_share_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/report_share_repository.dart';
import 'package:kid_matix/features/classroom/domain/usecases/audio_pack_file_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/close_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_assessments_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_class_report_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_exercise_sheet_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_pending_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_program_report_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_teacher_recordings_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_word_cards_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/open_assessment_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/record_explanation_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/share_files_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_assessment_changes_use_case.dart';

/// Registers the class assessments (lot F31) in [sl]: their storage, the
/// hook that keeps a pupil's result at the end of the word check, their
/// use cases and the reports.
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
  _registerReports(sl);
  _registerRecordings(sl);
  sl<SessionSavedHooks>().add(
    AssessmentSessionHook(
      roster: () => sl<PupilRosterService>(),
      placements: () => sl<PlacementResultService>(),
      assessments: sl(),
    ),
  );
}

void _registerReports(GetIt sl) {
  sl.registerLazySingleton<ReportShareRepository>(
    () => ReportShareRepositoryImpl(files: sl()),
  );
  sl.registerLazySingleton<ShareFilesUseCase>(
    () => ShareFilesUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetClassReportUseCase>(
    () => GetClassReportUseCase(
      getRoster: sl(),
      assessments: sl(),
      journal: sl(),
      numbers: sl(),
      clock: sl(),
    ),
  );
  sl.registerLazySingleton<GetProgramReportUseCase>(
    () => GetProgramReportUseCase(
      getClassrooms: sl(),
      assessments: sl(),
      getClassReport: sl(),
      clock: sl(),
    ),
  );
}

void _registerRecordings(GetIt sl) {
  sl.registerLazySingleton<GetTeacherRecordingsUseCase>(
    () => GetTeacherRecordingsUseCase(audio: sl(), domains: sl()),
  );
  sl.registerLazySingleton<RecordExplanationUseCase>(
    () => RecordExplanationUseCase(audio: sl(), words: sl()),
  );
  sl.registerLazySingleton<GetExerciseSheetUseCase>(
    () => GetExerciseSheetUseCase(domains: sl(), random: sl()),
  );
  sl.registerLazySingleton<GetWordCardsUseCase>(
    () => GetWordCardsUseCase(cards: sl(), audio: sl()),
  );
  sl.registerLazySingleton<AudioPackFileUseCase>(
    () => AudioPackFileUseCase(audio: sl(), files: sl(), clock: sl()),
  );
}
