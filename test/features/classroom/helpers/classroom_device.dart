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
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
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
    final AppDatabase database = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
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

  /// Closes the device.
  Future<void> close() async {
    await changeBus.dispose();
    await database.close();
  }
}
