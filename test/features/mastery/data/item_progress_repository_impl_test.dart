import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/mastery/data/models/item_progress_local_model.dart';
import 'package:kid_matix/features/mastery/data/repositories/item_progress_repository_impl.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/mastery_fixtures.dart';

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late ItemProgressRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = await openMasteryDatabase();
    changeBus = TableChangeBus();
    repository = ItemProgressRepositoryImpl(
      progress: ItemProgressLocalDataSourceImpl(database: appDatabase),
      clock: StoppedClock(masteryNow),
      changeBus: changeBus,
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  group('ItemProgressRepositoryImpl', () {
    test('saves a progress and reads it back', () async {
      // Arrange
      final ItemProgressEntity inputProgress =
          buildProgress(
            'mul:7x8',
            box: 3,
            nextReviewAt: DateTime(2026, 10, 14),
          ).copyWith(
            lastAnswerTimes: const <Duration>[
              Duration(milliseconds: 1800),
              Duration(milliseconds: 2600),
            ],
          );
      // Act
      final DataState<void> actualSave = await repository.saveProgress(
        progress: inputProgress,
      );
      final ItemProgressEntity actualProgress =
          (await repository.getItemProgress(
            profileId: 'p1',
            domainId: 'multiplication',
            itemKey: 'mul:7x8',
          )).requireData;
      // Assert
      expect(actualSave, isA<DataSuccess<void>>());
      expect(actualProgress, inputProgress);
    });
    test('replaces the row of an item saved twice', () async {
      // Arrange
      await repository.saveProgress(progress: buildProgress('mul:7x8'));
      // Act
      await repository.saveProgress(
        progress: buildProgress('mul:7x8', box: 2, presentationCount: 2),
      );
      // Assert
      final List<ItemProgressEntity> actualProgress =
          (await repository.getProgress(
            profileId: 'p1',
            domainId: 'multiplication',
          )).requireData;
      expect(actualProgress, hasLength(1));
      expect(actualProgress.single.box, 2);
    });
    test('gives a never presented item box 0', () async {
      // Act
      final ItemProgressEntity actualProgress =
          (await repository.getItemProgress(
            profileId: 'p1',
            domainId: 'multiplication',
            itemKey: 'mul:7x8',
          )).requireData;
      // Assert
      expect(actualProgress.box, 0);
      expect(actualProgress.presentationCount, 0);
      expect(actualProgress.lastAnswerTimes, isEmpty);
    });
    test('reads only the progress of the player and domain', () async {
      // Arrange
      await repository.saveProgress(progress: buildProgress('mul:7x8'));
      // Act
      final List<ItemProgressEntity> actualOther =
          (await repository.getProgress(
            profileId: 'p2',
            domainId: 'multiplication',
          )).requireData;
      final List<ItemProgressEntity> actualOwn = (await repository.getProgress(
        profileId: 'p1',
        domainId: 'multiplication',
      )).requireData;
      // Assert
      expect(actualOther, isEmpty);
      expect(actualOwn, hasLength(1));
    });
    test('tells the watchers that the progress changed', () async {
      // Arrange
      final Future<String> actualChange = changeBus
          .watchTable(table: 'item_progress')
          .first;
      // Act
      await repository.saveProgress(progress: buildProgress('mul:7x8'));
      // Assert
      expect(await actualChange, 'item_progress');
    });
    test('fails to save the progress of an unknown player', () async {
      // Act
      final DataState<void> actualState = await repository.saveProgress(
        progress: const ItemProgressEntity.notSeen(
          profileId: 'unknown',
          domainId: 'multiplication',
          itemKey: 'mul:7x8',
        ),
      );
      // Assert
      expect(actualState.exceptionOrNull, isA<CacheException>());
    });
    test('fails to read once the database is closed', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualList = (await repository.getProgress(
        profileId: 'p1',
        domainId: 'multiplication',
      )).exceptionOrNull;
      final AppException? actualItem = (await repository.getItemProgress(
        profileId: 'p1',
        domainId: 'multiplication',
        itemKey: 'mul:7x8',
      )).exceptionOrNull;
      // Assert
      expect(actualList, isA<CacheException>());
      expect(actualItem, isA<CacheException>());
    });
  });

  group('ItemProgressLocalModel', () {
    test('stores the answer times as milliseconds separated by commas', () {
      // Arrange
      final ItemProgressEntity inputProgress = buildProgress('mul:7x8')
          .copyWith(
            lastAnswerTimes: const <Duration>[
              Duration(milliseconds: 900),
              Duration(milliseconds: 1250),
            ],
          );
      // Act
      final ItemProgressLocalModel actualModel =
          ItemProgressLocalModel.fromEntity(
            progress: inputProgress,
            updatedAt: masteryNow,
          );
      // Assert
      expect(actualModel.lastAnswerTimesMs, '900,1250');
      expect(actualModel.toEntity(), inputProgress);
    });
  });
}
