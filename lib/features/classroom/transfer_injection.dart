import 'package:get_it/get_it.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_transfer_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/classroom_merger.dart';
import 'package:kid_matix/features/classroom/domain/usecases/export_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_export_mark_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/import_classroom_use_case.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Registers the class files (F29-10) in [sl]: written to the share
/// sheet, read from the file picker and merged without duplicates.
void registerClassroomTransfer(GetIt sl) {
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
  sl.registerLazySingleton<GetExportMarkUseCase>(
    () => GetExportMarkUseCase(transfers: sl()),
  );
  sl.registerLazySingleton<ImportClassroomUseCase>(
    () => ImportClassroomUseCase(transfers: sl(), merger: sl()),
  );
}
