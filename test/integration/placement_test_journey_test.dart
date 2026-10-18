import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/review_overview.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_test_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/placement_answer_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/run_placement_test_use_case.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';

import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// Lot F16 "done when": a new player who answers the tables of 1, 2 and
/// 10 right starts with those three tables open, over the real wiring
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

  List<String> openTablesOf(LearningPathEntity path) {
    return <String>[
      for (final TablePathNode table in path.tables)
        if (table.status != TableStatus.locked) table.unitKey,
    ];
  }

  test('opens the tables 1, 2 and 10 found by a new player', () async {
    // Arrange
    final ProfileEntity inputPlayer = await TestApp.createPlayer('Awa');
    final PlacementTestEntity inputTest = ((await sl<RunPlacementTestUseCase>()(
      params: LearningDomainIds.multiplication,
    )) as DataSuccess<PlacementTestEntity>).data;
    // Act
    for (final PlacementQuestionEntity question in inputTest.questions) {
      final bool isKnown = <int>{1, 2, 10}.contains(question.unitNumber);
      await sl<AnswerPlacementQuestionUseCase>()(
        params: PlacementAnswerParams(
          profileId: inputPlayer.id,
          domainId: LearningDomainIds.multiplication,
          question: question.question,
          answer: isKnown
              ? question.question.expectedAnswer
              : const NumberAnswer(0),
          answerTime: const Duration(seconds: 4),
        ),
      );
    }
    await TestApp.stop();
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: phoneStorage,
    );
    // Assert
    final LearningPathEntity actualPath = await TestApp.pathOf(
      inputPlayer.id,
    );
    expect(openTablesOf(actualPath), <String>['mul:1', 'mul:2', 'mul:10']);
    expect(actualPath.currentTable!.number, 1);
    expect(
      actualPath.tables.map((TablePathNode table) => table.totalStars),
      everyElement(0),
    );
    final ReviewOverview actualReview =
        ((await sl<MasteryService>().readReviewOverview(
          profileId: inputPlayer.id,
          domainId: LearningDomainIds.multiplication,
        )) as DataSuccess<ReviewOverview>).data;
    expect(actualReview.seenCount, 12);
    final ProfileEntity actualPlayer = ((await sl<GetProfileUseCase>()(
      params: inputPlayer.id,
    )) as DataSuccess<ProfileEntity>).data;
    expect(actualPlayer.totalXp, 0);
  });
}
