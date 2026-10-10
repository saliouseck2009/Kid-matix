import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/quiz/question_types/version_one_question_types.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Test double of [ItemProgressRepository].
final class MockItemProgressRepository extends Mock
    implements ItemProgressRepository {}

/// [Clock] stopped at a time the test sets.
final class StoppedClock implements Clock {
  /// Creates a clock stopped at [current].
  StoppedClock(this.current);

  /// Current time; tests move it forward.
  DateTime current;

  @override
  DateTime now() => current;
}

/// When the test answers are given.
final DateTime masteryNow = DateTime(2026, 10, 10, 18);

/// Opens an in-memory database at the latest version, with the player
/// `p1`.
Future<AppDatabase> openMasteryDatabase() async {
  final AppDatabase database = AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => inMemoryDatabasePath,
    migrationRunner: MigrationRunner(migrations: appMigrations),
  );
  await (await database.database).insert('profile', <String, Object?>{
    'id': 'p1',
    'nickname': 'Awa',
    'normalized_nickname': 'awa',
    'avatar': 'avatar1',
    'color': 'violet',
    'created_at': 0,
    'updated_at': 0,
  });
  return database;
}

/// Registries with the question types of version 1.0 and multiplication.
(DomainRegistry, QuestionTypeRegistry) buildMasteryRegistries() {
  final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain());
  final QuestionTypeRegistry types = QuestionTypeRegistry();
  versionOneQuestionTypes.forEach(types.register);
  return (domains, types);
}

/// Progress of `p1` on [itemKey] in multiplication.
ItemProgressEntity buildProgress(
  String itemKey, {
  int box = 1,
  int presentationCount = 1,
  int correctCount = 1,
  DateTime? nextReviewAt,
}) {
  return ItemProgressEntity(
    profileId: 'p1',
    domainId: 'multiplication',
    itemKey: itemKey,
    presentationCount: presentationCount,
    correctCount: correctCount,
    lastAnswerTimes: const <Duration>[Duration(milliseconds: 2400)],
    box: box,
    nextReviewAt: nextReviewAt,
  );
}
