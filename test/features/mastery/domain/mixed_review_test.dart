import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/mastery/data/repositories/item_progress_repository_impl.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/usecases/plan_quiz_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/mastery_fixtures.dart';

/// The daily review plans across every domain at once.
void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late ItemProgressEntity Function(String, String, {required bool isDue})
  progressOf;
  late ItemProgressRepositoryImpl repository;
  late StoppedClock clock;
  late DomainRegistry domains;
  late QuestionTypeRegistry types;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = await openMasteryDatabase();
    changeBus = TableChangeBus();
    clock = StoppedClock(DateTime(2026, 10, 11, 9));
    repository = ItemProgressRepositoryImpl(
      progress: ItemProgressLocalDataSourceImpl(database: appDatabase),
      clock: clock,
      changeBus: changeBus,
    );
    (domains, types) = buildMasteryRegistries();
    progressOf = (String domainId, String itemKey, {required bool isDue}) {
      return ItemProgressEntity(
        profileId: 'p1',
        domainId: domainId,
        itemKey: itemKey,
        presentationCount: 3,
        correctCount: 2,
        lastAnswerTimes: const <Duration>[Duration(seconds: 2)],
        box: isDue ? 1 : 4,
        nextReviewAt: DateTime(2026, isDue ? 10 : 12, 20),
      );
    };
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  List<String> keysOf(String domainId) {
    final LearningDomain domain = domains.find(domainId)!;
    return <String>[
      for (final LearningUnit unit in domain.units)
        for (final LearningItem item in unit.items) item.key,
    ];
  }

  test('always asks the one fact due, whichever domain it is in', () async {
    // Arrange
    for (final String key in keysOf('multiplication').take(10)) {
      await repository.saveProgress(
        progress: progressOf('multiplication', key, isDue: false),
      );
    }
    final List<String> additions = keysOf('addition');
    for (final String key in additions.take(10)) {
      await repository.saveProgress(
        progress: progressOf('addition', key, isDue: false),
      );
    }
    await repository.saveProgress(
      progress: progressOf('addition', additions[12], isDue: true),
    );
    for (int seed = 0; seed < 12; seed++) {
      // Act
      final List<QuizItemPlan> actual =
          (await PlanQuizUseCase(
                repository: repository,
                domains: domains,
                questionTypes: types,
                random: DartRandomSource(seed: seed),
                clock: clock,
              )(
                params: QuizPlanRequest(
                  profileId: 'p1',
                  domainId: LearningDomainIds.mixed,
                  itemKeys: <String>[
                    ...keysOf('multiplication'),
                    ...additions,
                  ],
                  questionTypeIds: const <String>[
                    QuestionTypeIds.multipleChoice,
                    QuestionTypeIds.typedAnswer,
                  ],
                  questionCount: 3,
                  selection: QuizSelection.review,
                ),
              ))
              .requireData;
      // Assert
      expect(actual, hasLength(3), reason: 'seed $seed');
      expect(
        actual.map((QuizItemPlan plan) => plan.itemKey),
        contains(additions[12]),
        reason: 'seed $seed',
      );
    }
  });
  test('plans nothing for a player who has seen no fact', () async {
    // Act
    final List<QuizItemPlan> actual =
        (await PlanQuizUseCase(
              repository: repository,
              domains: domains,
              questionTypes: types,
              random: DartRandomSource(seed: 1),
              clock: clock,
            )(
              params: QuizPlanRequest(
                profileId: 'p1',
                domainId: LearningDomainIds.mixed,
                itemKeys: keysOf('addition'),
                questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
                questionCount: 10,
                selection: QuizSelection.review,
              ),
            ))
            .requireData;
    // Assert
    expect(actual, isEmpty);
  });
  test('refuses a mixed plan that is not a review', () async {
    // Act
    final result =
        await PlanQuizUseCase(
          repository: repository,
          domains: domains,
          questionTypes: types,
          random: DartRandomSource(seed: 1),
          clock: clock,
        )(
          params: QuizPlanRequest(
            profileId: 'p1',
            domainId: LearningDomainIds.mixed,
            itemKeys: keysOf('addition'),
            questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
            questionCount: 10,
          ),
        );
    // Assert
    expect(result.exceptionOrNull, isNotNull);
  });
}
