import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_domain_choice_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/select_domain_use_case.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_mastery_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_grid_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

import 'package:sqflite/sqflite.dart';

import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// Lot F24 "done when": a new player chooses « Nombres », passes the
/// stage « compter jusqu'à 20 » and wins its stars, and their progress in
/// the multiplication has not moved; over the real wiring and an on-disk
/// database.
void main() {
  late Directory databaseFolder;
  late InMemoryLocalStorage phoneStorage;

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    phoneStorage = InMemoryLocalStorage();
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  Future<void> playStage(
    String profileId,
    String unitKey,
    StageKind stage,
  ) async {
    final QuizBloc bloc = TestApp.quizBloc();
    await TestApp.startQuiz(
      bloc,
      TestApp.stageRequest(
        profileId: profileId,
        unitKey: unitKey,
        stage: stage,
      ),
    );
    expect(await TestApp.playToEnd(bloc), isA<QuizCompleted>());
    await bloc.close();
  }

  Future<Map<String, MasteryStatus>> gridOf(
    String profileId,
    String domainId,
  ) async {
    final MasteryGridEntity grid = ((await sl<GetMasteryGridUseCase>()(
      params: MasteryScope(profileId: profileId, domainId: domainId),
    )) as DataSuccess<MasteryGridEntity>).data;
    return <String, MasteryStatus>{
      for (final List<ItemMasteryEntity> row in grid.rows.values)
        for (final ItemMasteryEntity cell in row) cell.itemKey: cell.status,
    };
  }

  /// The domain stored with each row of [table], by its [keyColumn].
  Future<Map<String, String>> domainsOf(String table, String keyColumn) async {
    final Database database = await sl<AppDatabase>().database;
    final List<Map<String, Object?>> rows = await database.query(
      table,
      columns: <String>[keyColumn, 'domain_id'],
    );
    return <String, String>{
      for (final Map<String, Object?> row in rows)
        row[keyColumn]! as String: row['domain_id']! as String,
    };
  }

  Map<String, int> starsOf(LearningPathEntity path) {
    return <String, int>{
      for (final TablePathNode table in path.tables)
        for (final StageState stage in table.stages)
          '${table.unitKey}/${stage.kind.name}': stage.stars,
    };
  }

  test('wins stars in the numbers, the multiplication untouched', () async {
    // Arrange
    final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
    await playStage(inputPlayer.id, 'mul:1', StageKind.discovery);
    final Map<String, int> expectedMultiplicationStars = starsOf(
      await TestApp.pathOf(inputPlayer.id),
    );
    final Map<String, MasteryStatus> expectedMultiplicationGrid = await gridOf(
      inputPlayer.id,
      LearningDomainIds.multiplication,
    );
    // Act
    await sl<SelectDomainUseCase>()(
      params: LearningPathParams(
        profileId: inputPlayer.id,
        domainId: LearningDomainIds.numbers,
      ),
    );
    for (final StageKind stage in <StageKind>[
      StageKind.discovery,
      StageKind.training,
      StageKind.writing,
    ]) {
      await playStage(inputPlayer.id, 'num:count10', stage);
    }
    await playStage(inputPlayer.id, 'num:count20', StageKind.discovery);
    await TestApp.stop();
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
    // Assert
    final DomainChoiceEntity actualChoice =
        ((await sl<GetDomainChoiceUseCase>()(
          params: inputPlayer.id,
        )) as DataSuccess<DomainChoiceEntity>).data;
    expect(actualChoice.selectedId, LearningDomainIds.numbers);
    final LearningPathEntity actualNumbers = await TestApp.pathOf(
      inputPlayer.id,
      domainId: LearningDomainIds.numbers,
    );
    final TablePathNode actualCount20 = actualNumbers.tables[1];
    expect(actualCount20.unitKey, 'num:count20');
    expect(actualCount20.stageOf(StageKind.discovery).stars, 3);
    expect(actualCount20.status, TableStatus.current);
    final Map<String, MasteryStatus> actualNumbersGrid = await gridOf(
      inputPlayer.id,
      LearningDomainIds.numbers,
    );
    expect(actualNumbersGrid['num:count:14'], isNot(MasteryStatus.notSeen));
    expect(
      starsOf(await TestApp.pathOf(inputPlayer.id)),
      expectedMultiplicationStars,
    );
    expect(
      await gridOf(inputPlayer.id, LearningDomainIds.multiplication),
      expectedMultiplicationGrid,
    );
    expect(await domainsOf('quiz_session', 'source_key'), <String, String>{
      'path:mul:1:discovery': LearningDomainIds.multiplication,
      'path:num:count10:discovery': LearningDomainIds.numbers,
      'path:num:count10:training': LearningDomainIds.numbers,
      'path:num:count10:writing': LearningDomainIds.numbers,
      'path:num:count20:discovery': LearningDomainIds.numbers,
    });
    final Map<String, String> actualItems = await domainsOf(
      'item_progress',
      'item_key',
    );
    expect(actualItems['mul:1x7'], LearningDomainIds.multiplication);
    expect(actualItems['num:count:14'], LearningDomainIds.numbers);
    final Map<String, String> actualStages = await domainsOf(
      'stage_progress',
      'unit_key',
    );
    expect(actualStages['mul:1'], LearningDomainIds.multiplication);
    expect(actualStages['num:count20'], LearningDomainIds.numbers);
  });
  test('crowns a unit of the numbers once its boss is defeated', () async {
    // Arrange
    final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
    for (final StageKind stage in <StageKind>[
      StageKind.discovery,
      StageKind.training,
      StageKind.writing,
      StageKind.speed,
    ]) {
      await playStage(inputPlayer.id, 'num:count10', stage);
    }
    // Act
    await playStage(inputPlayer.id, 'num:count10', StageKind.boss);
    // Assert
    final LearningPathEntity actualNumbers = await TestApp.pathOf(
      inputPlayer.id,
      domainId: LearningDomainIds.numbers,
    );
    expect(actualNumbers.tables.first.crown, isNot(TableCrown.none));
    expect(actualNumbers.defeatedBosses, hasLength(1));
    expect(
      ((await sl<CrownService>().readCrownCount(
        profileId: inputPlayer.id,
      )) as DataSuccess<int>).data,
      1,
    );
    expect(
      (await TestApp.pathOf(inputPlayer.id)).defeatedBosses,
      isEmpty,
    );
  });
}
