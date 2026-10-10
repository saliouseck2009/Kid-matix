import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/quiz/question_types/version_one_question_types.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/crash_reporter.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/services/log_crash_reporter.dart';
import 'package:kid_matix/core/services/periodic_ticker.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/services/system_clock.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/core/services/uuid_id_generator.dart';
import 'package:kid_matix/core/services/progress_reset_service.dart';
import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/core/storage/progress_resetter.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/core/storage/shared_preferences_local_storage.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/challenge/injection.dart';
import 'package:kid_matix/features/learning_path/injection.dart';
import 'package:kid_matix/features/mascot/injection.dart';
import 'package:kid_matix/features/mastery/injection.dart';
import 'package:kid_matix/features/multiplication/injection.dart';
import 'package:kid_matix/features/profile/injection.dart';
import 'package:kid_matix/features/quiz/injection.dart';
import 'package:kid_matix/features/reward/injection.dart';
import 'package:kid_matix/features/setting/injection.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Service locator, resolved only at the composition root.
///
/// Never call it from a widget, and never register a Bloc or Cubit in it.
final GetIt sl = GetIt.instance;

/// Registers every dependency; call once before the app starts.
///
/// Each feature adds its own `registerXxxFeature()` call here.
Future<void> configureDependencies() async {
  _registerCoreServices();
  _registerCoreStorage();
  _registerQuizEngine();
  registerProfileFeature(sl);
  registerMultiplicationFeature(sl);
  registerMasteryFeature(sl);
  registerLearningPathFeature(sl);
  registerRewardFeature(sl);
  registerMascotFeature(sl);
  registerChallengeFeature(sl);
  registerSettingFeature(sl);
  registerQuizFeature(sl);
}

void _registerCoreServices() {
  sl.registerLazySingleton<Clock>(() => const SystemClock());
  sl.registerLazySingleton<RandomSource>(DartRandomSource.new);
  sl.registerLazySingleton<Ticker>(() => const PeriodicTicker());
  sl.registerLazySingleton<IdGenerator>(() => const UuidIdGenerator());
  sl.registerLazySingleton<CrashReporter>(() => const LogCrashReporter());
}

void _registerCoreStorage() {
  sl.registerLazySingleton<LocalStorage>(
    () => SharedPreferencesLocalStorage(preferences: SharedPreferencesAsync()),
  );
  sl.registerLazySingleton<TableChangeBus>(TableChangeBus.new);
  sl.registerLazySingleton<SessionSavedHooks>(SessionSavedHooks.new);
  sl.registerLazySingleton<ProgressResetHooks>(ProgressResetHooks.new);
  sl.registerLazySingleton<ProgressResetService>(
    () => ProgressResetter(database: sl(), hooks: sl(), changeBus: sl()),
  );
  sl.registerLazySingleton<AppDatabase>(
    () => AppDatabase(
      databaseFactory: databaseFactory,
      resolvePath: _resolveDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    ),
  );
}

void _registerQuizEngine() {
  sl.registerLazySingleton<DomainRegistry>(DomainRegistry.new);
  sl.registerLazySingleton<QuestionTypeRegistry>(() {
    final QuestionTypeRegistry registry = QuestionTypeRegistry();
    versionOneQuestionTypes.forEach(registry.register);
    return registry;
  });
}

Future<String> _resolveDatabasePath() async {
  final String directory = await getDatabasesPath();
  return join(directory, AppDatabase.fileName);
}
