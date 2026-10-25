import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
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

import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// Lot F30, over the real wiring and an on-disk database: a new player
/// chooses « Problèmes », plays the first unit and wins its stars; the
/// mastery follows each problem, not its numbers, and a trap problem is
/// still new until its own unit.
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

  test('wins the stars of the first unit and follows each problem', () async {
    // Arrange
    final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
    await sl<SelectDomainUseCase>()(
      params: LearningPathParams(
        profileId: inputPlayer.id,
        domainId: LearningDomainIds.problems,
      ),
    );
    // Act
    for (final StageKind stage in <StageKind>[
      StageKind.discovery,
      StageKind.training,
      StageKind.writing,
      StageKind.speed,
      StageKind.boss,
    ]) {
      await playStage(inputPlayer.id, 'probs:add1', stage);
    }
    await TestApp.stop();
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
    // Assert
    final LearningPathEntity actualPath = await TestApp.pathOf(
      inputPlayer.id,
      domainId: LearningDomainIds.problems,
    );
    expect(actualPath.tables, hasLength(15));
    final TablePathNode actualUnit = actualPath.tables.first;
    expect(actualUnit.unitKey, 'probs:add1');
    expect(actualUnit.stageOf(StageKind.discovery).stars, 3);
    expect(actualPath.tables[1].unitKey, 'probs:sub1');
    expect(actualPath.tables[1].status, TableStatus.current);
    final MasteryGridEntity actualGrid = ((await sl<GetMasteryGridUseCase>()(
      params: MasteryScope(
        profileId: inputPlayer.id,
        domainId: LearningDomainIds.problems,
      ),
    )) as DataSuccess<MasteryGridEntity>).data;
    final Map<String, MasteryStatus> actualStatuses = <String, MasteryStatus>{
      for (final List<ItemMasteryEntity> row in actualGrid.rows.values)
        for (final ItemMasteryEntity cell in row) cell.itemKey: cell.status,
    };
    expect(
      actualStatuses['problem:billes_recues'],
      isNot(MasteryStatus.notSeen),
    );
    expect(
      actualStatuses['problem:mangues_donnees_piege'],
      MasteryStatus.notSeen,
    );
    expect(sl<WordAudioService>().languages, isEmpty);
  });
}
