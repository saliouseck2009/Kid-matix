import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/learning_path/data/datasources/placement_result_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/placement_result_repository_impl.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_journey.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

PlacementOutcome _outcomeOf(List<bool> answers) {
  PlacementJourney journey = PlacementJourney.start();
  for (final bool isCorrect in answers) {
    if (journey.isOver) break;
    journey = journey.answered(isCorrect: isCorrect);
  }
  return journey.outcome;
}

void main() {
  late AppDatabase appDatabase;
  late FakeClock clock;
  late TableChangeBus changeBus;
  late PlacementResultRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    final Database database = await appDatabase.database;
    for (final String id in <String>['p1', 'p2']) {
      await database.insert('profile', <String, Object?>{
        'id': id,
        'nickname': id,
        'normalized_nickname': id,
        'avatar': 'avatar1',
        'color': 'violet',
        'created_at': 0,
        'updated_at': 0,
      });
    }
    clock = FakeClock(quizStart);
    changeBus = TableChangeBus();
    repository = PlacementResultRepositoryImpl(
      results: PlacementResultLocalDataSourceImpl(database: appDatabase),
      changeBus: changeBus,
      clock: clock,
    );
  });

  tearDown(() async {
    await appDatabase.close();
    await changeBus.dispose();
  });

  group('PlacementResultRepositoryImpl', () {
    test('keeps a level per domain with the date of the test', () async {
      // Act: the child counts but cannot add.
      await repository.save(
        profileId: 'p1',
        outcome: _outcomeOf(<bool>[true, true, true, false, false]),
      );
      // Assert
      final List<PlacementResultEntity> actualHistory =
          (await repository.getHistory(profileId: 'p1')).requireData;
      expect(actualHistory, hasLength(1));
      final PlacementResultEntity actualResult = actualHistory.single;
      expect(
        actualResult.takenAt.millisecondsSinceEpoch,
        quizStart.millisecondsSinceEpoch,
      );
      expect(
        actualResult.domains.map((DomainResultEntity d) => d.domainId),
        <String>['numbers', 'addition', 'multiplication', 'division'],
      );
      expect(
        actualResult.domains.map((DomainResultEntity d) => d.level),
        <int?>[1, 0, null, null],
      );
      expect(actualResult.domainOf('addition')!.skillCount, 2);
      expect(actualResult.domainOf('numbers')!.unitCount, 6);
      expect(actualResult.recommended!.domainId, 'addition');
      expect(actualResult.recommended!.startUnitKey, 'addsub:add5');
      expect(actualResult.domainOf('numbers')!.startUnitKey, isNull);
    });

    test('keeps the earlier tests, the latest first, per player', () async {
      // Act
      await repository.save(
        profileId: 'p1',
        outcome: _outcomeOf(<bool>[false, false]),
      );
      clock.now_ = quizStart.add(const Duration(days: 60));
      await repository.save(
        profileId: 'p1',
        outcome: _outcomeOf(List<bool>.filled(15, true)),
      );
      await repository.save(
        profileId: 'p2',
        outcome: _outcomeOf(<bool>[false, false]),
      );
      // Assert
      final List<PlacementResultEntity> actualHistory =
          (await repository.getHistory(profileId: 'p1')).requireData;
      expect(actualHistory, hasLength(2));
      expect(
        actualHistory.map(
          (PlacementResultEntity r) => r.takenAt.difference(
            DateTime.fromMillisecondsSinceEpoch(
              quizStart.millisecondsSinceEpoch,
            ),
          ),
        ),
        <Duration>[const Duration(days: 60), Duration.zero],
      );
      expect(actualHistory.first.recommended, isNull);
      expect(actualHistory.last.domainOf('numbers')!.level, 0);
      expect(
        (await repository.getHistory(profileId: 'p2')).requireData,
        hasLength(1),
      );
      expect(
        (await repository.getHistory(profileId: 'nobody')).requireData,
        isEmpty,
      );
    });

    test('tells the watchers when a result is kept', () async {
      // Arrange
      int changes = 0;
      final StreamSubscription<void> subscription = repository
          .watchChanges()
          .listen((_) => changes++);
      // Act
      await repository.save(
        profileId: 'p1',
        outcome: _outcomeOf(<bool>[false, false]),
      );
      await pumpEventQueue();
      // Assert
      expect(changes, 1);
      await subscription.cancel();
    });

    test('fails when the profile does not exist', () async {
      // Act
      final bool actualFailed =
          (await repository.save(
            profileId: 'nobody',
            outcome: _outcomeOf(<bool>[false, false]),
          )).exceptionOrNull !=
          null;
      // Assert
      expect(actualFailed, isTrue);
    });
  });
}
