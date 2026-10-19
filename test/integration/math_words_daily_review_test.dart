import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';

import '../features/quiz/helpers/quiz_fixtures.dart';
import '../helpers/in_memory_local_storage.dart';
import 'helpers/test_app.dart';

/// The daily review mixes every domain: a word missed today is asked again
/// the next day, in a format that fits it.
void main() {
  late Directory databaseFolder;
  late FakeClock clock;

  setUp(() async {
    databaseFolder = await Directory.systemTemp.createTemp('kid_matix_');
    clock = FakeClock(DateTime(2026, 10, 19, 18));
    await TestApp.start(
      databasesPath: databaseFolder.path,
      storage: InMemoryLocalStorage(),
    );
    sl.allowReassignment = true;
    sl.registerLazySingleton<Clock>(() => clock);
    sl.allowReassignment = false;
  });

  tearDown(() async {
    await TestApp.stop();
    await databaseFolder.delete(recursive: true);
  });

  Future<List<QuizItemPlan>> dailyReview(String profileId) async {
    final List<String> itemKeys = <String>[
      for (final LearningDomain domain in sl<DomainRegistry>().domains)
        for (final LearningUnit unit in domain.units)
          for (final LearningItem item in unit.items) item.key,
    ];
    return ((await sl<MasteryService>().planQuiz(
      request: QuizPlanRequest(
        profileId: profileId,
        domainId: LearningDomainIds.mixed,
        itemKeys: itemKeys,
        questionTypeIds: ChallengeRules.dailyReviewQuestionTypeIds,
        questionCount: ChallengeRules.dailyReviewQuestionCount,
        selection: QuizSelection.review,
      ),
    )) as DataSuccess<List<QuizItemPlan>>).data;
  }

  test('asks a word missed today again the next day', () async {
    // Arrange
    final ProfileEntity player = await TestApp.createPlayer('Awa');
    await sl<MasteryService>().recordAnswer(
      answer: ItemAnswer(
        profileId: player.id,
        domainId: LearningDomainIds.mathWords,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.listenAndTouch,
        isCorrect: false,
        answerTime: const Duration(seconds: 4),
      ),
    );
    // Act
    clock.now_ = DateTime(2026, 10, 20, 9);
    final List<QuizItemPlan> actualPlans = await dailyReview(player.id);
    // Assert
    final QuizItemPlan actualPlan = actualPlans.singleWhere(
      (QuizItemPlan plan) => plan.itemKey == 'word:il_reste',
    );
    expect(actualPlan.questionTypeIds, isNotEmpty);
    expect(
      actualPlan.questionTypeIds,
      everyElement(
        isIn(<String>[
          QuestionTypeIds.listenAndTouch,
          QuestionTypeIds.wordAndImage,
          QuestionTypeIds.whichOperation,
        ]),
      ),
    );
  });

  test('never asks a sentence to touch in the daily review', () {
    // Assert
    expect(
      ChallengeRules.dailyReviewQuestionTypeIds,
      isNot(contains(QuestionTypeIds.touchToUnderstand)),
    );
  });
}
