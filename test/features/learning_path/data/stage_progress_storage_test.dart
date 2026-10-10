import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/learning_path/data/datasources/stage_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_repository_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_session_hook.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_service_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';

final class _StoppedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 10, 18);
}

SavedQuizSession _session({
  int correctCount = 8,
  bool isCompleted = true,
  String? sourceKey = 'path:mul:5:training',
  DateTime? endedAt,
}) {
  return SavedQuizSession(
    id: 's1',
    profileId: 'p1',
    domainId: 'multiplication',
    isCompleted: isCompleted,
    questionCount: 10,
    correctCount: correctCount,
    endedAt: endedAt ?? DateTime(2026, 10, 10, 17),
    sourceKey: sourceKey,
  );
}

void main() {
  late AppDatabase appDatabase;
  late StageProgressLocalDataSourceImpl dataSource;
  late StageProgressSessionHook hook;
  late StageProgressRepositoryImpl repository;
  late TableChangeBus changeBus;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    await (await appDatabase.database).insert('profile', <String, Object?>{
      'id': 'p1',
      'nickname': 'Awa',
      'normalized_nickname': 'awa',
      'avatar': 'avatar1',
      'color': 'violet',
      'created_at': 0,
      'updated_at': 0,
    });
    dataSource = StageProgressLocalDataSourceImpl(database: appDatabase);
    hook = StageProgressSessionHook(
      progress: dataSource,
      clock: _StoppedClock(),
    );
    changeBus = TableChangeBus();
    repository = StageProgressRepositoryImpl(
      progress: dataSource,
      changeBus: changeBus,
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  Future<List<String>> save(SavedQuizSession session) async {
    final Database database = await appDatabase.database;
    return database.transaction(
      (Transaction transaction) =>
          hook.onSessionSaved(transaction: transaction, session: session),
    );
  }

  Future<List<StageProgressEntity>> readProgress() async {
    return (await repository.getProgress(
      profileId: 'p1',
      domainId: 'multiplication',
    )).requireData;
  }

  group('StageProgressSessionHook', () {
    test('stores the stars of a completed stage', () async {
      // Act
      final List<String> actualTables = await save(_session());
      // Assert
      final StageProgressEntity actualStage = (await readProgress()).single;
      expect(actualTables, <String>['stage_progress']);
      expect(actualStage.unitKey, 'mul:5');
      expect(actualStage.stage, StageKind.training);
      expect(actualStage.bestStars, 2);
      expect(actualStage.bestScore, 8);
      expect(actualStage.completedAt, DateTime(2026, 10, 10, 17));
    });
    test('keeps the best result and the first completion', () async {
      // Arrange
      await save(_session(correctCount: 10));
      // Act
      await save(
        _session(correctCount: 6, endedAt: DateTime(2026, 10, 11, 9)),
      );
      // Assert
      final StageProgressEntity actualStage = (await readProgress()).single;
      expect(actualStage.bestStars, 3);
      expect(actualStage.bestScore, 10);
      expect(actualStage.completedAt, DateTime(2026, 10, 10, 17));
    });
    test('ignores an abandoned quiz and a quiz played for no stage', () async {
      // Act
      final List<String> actualAbandoned = await save(
        _session(isCompleted: false),
      );
      final List<String> actualOther = await save(_session(sourceKey: null));
      // Assert
      expect(actualAbandoned, isEmpty);
      expect(actualOther, isEmpty);
      expect(await readProgress(), isEmpty);
    });
    test('stores the review of a group of tables', () async {
      // Act
      await save(_session(sourceKey: 'path:review:1:review'));
      // Assert
      final StageProgressEntity actualStage = (await readProgress()).single;
      expect(actualStage.unitKey, 'review:1');
      expect(actualStage.stage, StageKind.review);
    });
  });

  group('StageProgressRepositoryImpl', () {
    test('tells when the stars or the player change', () async {
      // Arrange
      int actualCount = 0;
      final StreamSubscription<void> subscription = repository
          .watchChanges()
          .listen((_) => actualCount++);
      // Act
      changeBus.notifyChanged(table: 'stage_progress');
      changeBus.notifyChanged(table: 'profile');
      changeBus.notifyChanged(table: 'quiz_session');
      await pumpEventQueue();
      // Assert
      expect(actualCount, 2);
      await subscription.cancel();
    });
    test('fails to read once the database is closed', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await repository.getProgress(
        profileId: 'p1',
        domainId: 'multiplication',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('LearningPathServiceImpl', () {
    test('gives the stars of a stage and nothing for another quiz', () {
      // Arrange
      const LearningPathServiceImpl inputService = LearningPathServiceImpl();
      // Act
      final int? actualStage = inputService.starsFor(
        sourceKey: 'path:mul:5:speed',
        correctCount: 9,
        questionCount: 10,
      );
      final int? actualOther = inputService.starsFor(
        sourceKey: null,
        correctCount: 9,
        questionCount: 10,
      );
      // Assert
      expect(actualStage, 2);
      expect(actualOther, isNull);
    });
  });
}
