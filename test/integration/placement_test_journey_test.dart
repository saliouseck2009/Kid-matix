import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_choice_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_journey.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/build_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_domain_choice_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_placement_history_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/placement_answer_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/save_placement_result_use_case.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';

import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// Lot F27 "done when": a child who can count but cannot add starts on the
/// first addition unit, and the dated result is kept, over the real wiring
/// and an on-disk database.
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

  List<String> openUnitsOf(LearningPathEntity path) {
    return <String>[
      for (final TablePathNode table in path.tables)
        if (table.status != TableStatus.locked) table.unitKey,
    ];
  }

  /// Takes the whole test as [profileId] with the real use cases: right
  /// while [isRight] says so for the question number, "Je ne sais pas"
  /// otherwise.
  Future<void> takeTest(
    String profileId,
    bool Function(int rank) isRight,
  ) async {
    PlacementJourney journey = PlacementJourney.start();
    int rank = 0;
    while (!journey.isOver) {
      final Question question = ((await sl<BuildPlacementQuestionUseCase>()(
        params: PlacementProbeParams(
          domainId: journey.skill!.domainId,
          unitKey: journey.probeUnitKey!,
        ),
      )) as DataSuccess<Question>).data;
      final bool wantsRight = isRight(rank++);
      final DataState<bool> answered =
          await sl<AnswerPlacementQuestionUseCase>()(
            params: PlacementAnswerParams(
              profileId: profileId,
              domainId: journey.skill!.domainId,
              question: question,
              answer: wantsRight ? question.expectedAnswer : null,
              answerTime: const Duration(seconds: 4),
              unitKeysToOpen: journey.unitKeysToOpen,
            ),
          );
      journey = journey.answered(
        isCorrect: (answered as DataSuccess<bool>).data,
      );
    }
    await sl<SavePlacementResultUseCase>()(
      params: SavePlacementResultParams(
        profileId: profileId,
        outcome: journey.outcome,
      ),
    );
  }

  test(
    'starts a child who counts but cannot add on the first addition',
    () async {
      // Arrange
      final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
      // Act: the numbers are right, the additions are not.
      await takeTest(inputPlayer.id, (int rank) => rank < 3);
      await TestApp.stop();
      await TestApp.start(
        databasesPath: databaseFolder.path,
        storage: phoneStorage,
      );
      // Assert: the home opens on the addition, current on the first unit.
      final DomainChoiceEntity actualChoice =
          ((await sl<GetDomainChoiceUseCase>()(
            params: inputPlayer.id,
          )) as DataSuccess<DomainChoiceEntity>).data;
      expect(actualChoice.selectedId, 'addition');
      final LearningPathEntity actualAddition = await TestApp.pathOf(
        inputPlayer.id,
        domainId: 'addition',
      );
      expect(actualAddition.currentTable!.unitKey, 'addsub:add5');
      expect(openUnitsOf(actualAddition), <String>['addsub:add5']);
      final LearningPathEntity actualNumbers = await TestApp.pathOf(
        inputPlayer.id,
        domainId: 'numbers',
      );
      expect(
        openUnitsOf(actualNumbers),
        containsAll(<String>['num:count10', 'num:count20', 'num:order']),
      );
      expect(
        actualNumbers.tables.map((TablePathNode table) => table.totalStars),
        everyElement(0),
      );
      final ProfileEntity actualPlayer = ((await sl<GetProfileUseCase>()(
        params: inputPlayer.id,
      )) as DataSuccess<ProfileEntity>).data;
      expect(actualPlayer.totalXp, 0);
      expect(
        ((await sl<MasteryService>().readMasteredItems(
          profileId: inputPlayer.id,
          domainId: 'addition',
        )) as DataSuccess<Set<String>>).data,
        isEmpty,
      );
    },
  );

  test('keeps every test with its date and the level of each domain', () async {
    // Arrange
    final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
    // Act: a first test where nothing is known, then one where all is.
    await takeTest(inputPlayer.id, (int rank) => false);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await takeTest(inputPlayer.id, (int rank) => true);
    await TestApp.stop();
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
    // Assert
    final List<PlacementResultEntity> actualHistory =
        ((await sl<GetPlacementHistoryUseCase>()(
          params: inputPlayer.id,
        )) as DataSuccess<List<PlacementResultEntity>>).data;
    expect(actualHistory, hasLength(2));
    expect(
      actualHistory.first.takenAt.isBefore(actualHistory.last.takenAt),
      isFalse,
    );
    expect(
      actualHistory.first.domains.map((DomainResultEntity d) => d.level),
      <int>[1, 2, 1, 1],
    );
    expect(actualHistory.first.recommended, isNull);
    expect(
      actualHistory.last.domains.map((DomainResultEntity d) => d.level),
      <int?>[0, null, null, null],
    );
    expect(actualHistory.last.recommended!.startUnitKey, 'num:count10');
  });
}
