import 'dart:io';

import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/classroom/data/datasources/classroom_local_data_source_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/pupil_enrollment.dart';
import 'package:kid_matix/features/classroom/domain/usecases/add_pupils_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/create_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classroom_roster_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/get_classrooms_use_case.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/services/pupil_roster_service_impl.dart';
import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/core/storage/progress_resetter.dart';
import 'package:kid_matix/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/reset_progress_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/services/placement_result_service.dart';
import 'package:kid_matix/features/learning_path/data/datasources/placement_result_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/placement_result_repository_impl.dart';
import 'package:kid_matix/features/learning_path/domain/services/placement_result_service_impl.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/addition/domain/services/addition_domain.dart';
import 'package:kid_matix/features/classroom/data/datasources/assessment_local_data_source_impl.dart';
import 'package:kid_matix/features/classroom/data/datasources/assignment_local_data_source_impl.dart';
import 'package:kid_matix/features/classroom/data/repositories/assessment_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
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
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/core/entities/shared_file.dart';
import 'package:kid_matix/core/storage/shared_file_data_source.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_transfer_repository_impl.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_transfer_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/classroom_merger.dart';
import 'package:kid_matix/features/classroom/domain/usecases/export_classroom_use_case.dart';
import 'package:kid_matix/features/classroom/domain/usecases/import_classroom_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/in_memory_local_storage.dart';

/// A clock that the test moves by hand.
final class MovableClock implements Clock {
  /// Creates the clock at [current].
  MovableClock(this.current);

  /// The time it gives.
  DateTime current;

  @override
  DateTime now() => current;
}

/// Identifiers `prefix-1`, `prefix-2`...
final class CountingIds implements IdGenerator {
  /// Creates the generator; [prefix] keeps two devices apart.
  CountingIds(this.prefix);

  /// Start of every identifier.
  final String prefix;
  int _count = 0;

  @override
  String generateId() => '$prefix-${++_count}';
}

/// The share sheet and the file picker of a tablet.
final class FakeSharedFiles implements SharedFileDataSource {
  /// Name of the last file shared.
  String? sharedName;

  /// Content of the last file shared.
  String? sharedContent;

  /// Content the picker gives next, or `null` for a cancelled picker.
  String? fileToPick;

  @override
  Future<bool> shareFile({
    required String fileName,
    required String content,
  }) async {
    if (!isSharing) return false;
    sharedName = fileName;
    sharedContent = content;
    return true;
  }

  /// Whether the share sheet sends the file; `false` as when it is
  /// closed without choosing.
  bool isSharing = true;

  @override
  Future<String?> pickFile() async => fileToPick;

  /// The files of the last multi-file share, such as a report.
  List<SharedFile> sharedFiles = <SharedFile>[];

  @override
  Future<bool> shareFiles({required List<SharedFile> files}) async {
    if (!isSharing) return false;
    sharedFiles = files;
    return true;
  }
}

/// One tablet of a class: a real in-memory database with the profile and
/// class mode storage wired as in the app.
final class ClassroomDevice {
  ClassroomDevice._(this.database, this.clock, String name)
    : changeBus = TableChangeBus(),
      ids = CountingIds(name);

  /// The database of the device.
  final AppDatabase database;

  /// Its clock.
  final MovableClock clock;

  /// Its table change bus.
  final TableChangeBus changeBus;

  /// Its identifiers.
  final CountingIds ids;

  /// Opens a new device named [name].
  static Future<ClassroomDevice> open(
    String name, {
    DateTime? now,
  }) async {
    // A file per device: two tablets of one test never share a database.
    final Directory folder = Directory.systemTemp.createTempSync(
      'classroom_$name',
    );
    final String path = '${folder.path}/kid_matix.db';
    final AppDatabase database = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => path,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    await database.database;
    return ClassroomDevice._(
      database,
      MovableClock(now ?? DateTime(2026, 10, 20, 9)),
      name,
    );
  }

  /// The players of the device.
  late final ProfileRepository profiles = ProfileRepositoryImpl(
    profiles: ProfileLocalDataSourceImpl(database: database),
    activeProfile: ActiveProfileLocalDataSourceImpl(
      storage: InMemoryLocalStorage(),
    ),
    clock: clock,
    changeBus: changeBus,
  );

  /// The pupils, as the class mode sees them.
  late final PupilRosterService roster = PupilRosterServiceImpl(
    repository: profiles,
    selectProfile: SelectProfileUseCase(repository: profiles),
    resetProgress: ResetProgressUseCase(
      resetter: ProgressResetter(
        database: database,
        hooks: ProgressResetHooks(),
        changeBus: changeBus,
      ),
    ),
    deleteProfile: DeleteProfileUseCase(repository: profiles),
    clock: clock,
  );

  /// The classes.
  late final ClassroomRepository classrooms = ClassroomRepositoryImpl(
    classrooms: ClassroomLocalDataSourceImpl(database: database),
    changeBus: changeBus,
  );

  /// Adds nicknames as pupils.
  late final PupilEnrollment enrollment = PupilEnrollment(
    roster: roster,
    ids: ids,
  );

  /// Creates a class.
  late final CreateClassroomUseCase createClassroom = CreateClassroomUseCase(
    repository: classrooms,
    enrollment: enrollment,
    ids: ids,
    clock: clock,
  );

  /// Adds pupils to a class.
  late final AddPupilsUseCase addPupils = AddPupilsUseCase(
    roster: roster,
    enrollment: enrollment,
  );

  /// Reads a class and its pupils.
  late final GetClassroomRosterUseCase getRoster = GetClassroomRosterUseCase(
    repository: classrooms,
    roster: roster,
  );

  /// Lists the classes.
  late final GetClassroomsUseCase getClassrooms = GetClassroomsUseCase(
    repository: classrooms,
    roster: roster,
  );

  /// The learning domains: multiplication and addition.
  late final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain())
    ..register(AdditionDomain());

  /// The class results.
  late final ClassJournalLocalDataSourceImpl journalRows =
      ClassJournalLocalDataSourceImpl(database: database);

  /// The class results, as the domain sees them.
  late final ClassJournalRepository journal = ClassJournalRepositoryImpl(
    journal: journalRows,
    clock: clock,
    changeBus: changeBus,
  );

  /// The assignments.
  late final AssignmentRepository assignments = AssignmentRepositoryImpl(
    assignments: AssignmentLocalDataSourceImpl(database: database),
    changeBus: changeBus,
  );

  /// The assessments and their results.
  late final AssessmentRepository assessments = AssessmentRepositoryImpl(
    assessments: AssessmentLocalDataSourceImpl(database: database),
    clock: clock,
    changeBus: changeBus,
  );

  /// The items of the domains.
  late final ClassItemCatalog catalog = ClassItemCatalog(domains: domains);

  /// Gives an assignment.
  late final GiveAssignmentUseCase giveAssignment = GiveAssignmentUseCase(
    assignments: assignments,
    catalog: catalog,
    ids: ids,
    clock: clock,
  );

  /// The dated placement results (F27), as the class mode reads them.
  late final PlacementResultService placements = PlacementResultServiceImpl(
    results: PlacementResultRepositoryImpl(
      results: PlacementResultLocalDataSourceImpl(database: database),
      changeBus: changeBus,
      clock: clock,
    ),
  );

  /// Reads the page of a class.
  late final GetClassOverviewUseCase getOverview = GetClassOverviewUseCase(
    getRoster: getRoster,
    assignments: assignments,
    journal: journal,
    catalog: catalog,
    placements: placements,
    clock: clock,
  );

  /// Reads what a pupil sees of their class.
  late final GetPupilClassViewUseCase getPupilView = GetPupilClassViewUseCase(
    roster: roster,
    classrooms: classrooms,
    assignments: assignments,
    journal: journal,
    catalog: catalog,
    clock: clock,
  );

  /// The hook that keeps the sessions of the pupils.
  late final ClassroomSessionHook hook = ClassroomSessionHook(
    roster: () => roster,
    journal: journalRows,
  );

  /// Saves [session] as the quiz does: the hook prepares, then writes in
  /// a transaction.
  Future<void> play(SavedQuizSession session) async {
    final SessionWrite write = await hook.prepare(session: session);
    final Database db = await database.database;
    await db.transaction(write);
  }

  /// The share sheet and the file picker.
  final FakeSharedFiles files = FakeSharedFiles();

  /// The preferences of the class mode.
  final InMemoryLocalStorage storage = InMemoryLocalStorage();

  /// The class files.
  late final ClassroomTransferRepository transfers =
      ClassroomTransferRepositoryImpl(
        files: files,
        storage: storage,
        clock: clock,
        readAppVersion: () async => '2.0.0',
      );

  /// Sends a class.
  late final ExportClassroomUseCase exportClassroom = ExportClassroomUseCase(
    getRoster: getRoster,
    assignments: assignments,
    journal: journal,
    assessments: assessments,
    transfers: transfers,
    clock: clock,
  );

  /// Receives a class file.
  late final ImportClassroomUseCase importClassroom = ImportClassroomUseCase(
    transfers: transfers,
    merger: ClassroomMerger(
      classrooms: classrooms,
      roster: roster,
      assignments: assignments,
      journal: journal,
      assessments: assessments,
    ),
  );

  /// Closes the device.
  Future<void> close() async {
    await changeBus.dispose();
    await database.close();
  }
}
