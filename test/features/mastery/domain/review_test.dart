import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/review_overview.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/mastery/data/repositories/item_progress_repository_impl.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_service_impl.dart';
import 'package:kid_matix/features/mastery/domain/services/review_item_selector.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_monsters_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_review_overview_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';
import 'package:kid_matix/features/mastery/domain/usecases/plan_quiz_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/record_answer_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/mastery_fixtures.dart';

const MasteryScope _scope = MasteryScope(
  profileId: 'p1',
  domainId: 'multiplication',
);

const List<String> _reviewTypes = <String>[
  QuestionTypeIds.multipleChoice,
  QuestionTypeIds.trueFalse,
  QuestionTypeIds.typedAnswer,
  QuestionTypeIds.missingNumber,
];

List<String> _keysOf(Iterable<ItemProgressEntity> items) {
  return items.map((ItemProgressEntity item) => item.itemKey).toList();
}

void main() {
  group('ReviewItemSelector', () {
    const ReviewItemSelector selector = ReviewItemSelector();
    final DateTime inputNow = DateTime(2026, 10, 11, 9);
    final List<ItemProgressEntity> inputProgress = <ItemProgressEntity>[
      buildProgress('mul:7x8', nextReviewAt: DateTime(2026, 10, 11)),
      buildProgress('mul:6x7', nextReviewAt: DateTime(2026, 10, 9)),
      buildProgress(
        'mul:3x4',
        box: 3,
        presentationCount: 4,
        correctCount: 2,
        nextReviewAt: DateTime(2026, 10, 14),
      ),
      buildProgress(
        'mul:2x2',
        box: 4,
        presentationCount: 4,
        correctCount: 4,
        nextReviewAt: DateTime(2026, 10, 15),
      ),
      buildProgress(
        'mul:9x9',
        box: 2,
        presentationCount: 4,
        correctCount: 2,
        nextReviewAt: DateTime(2026, 10, 13),
      ),
      const ItemProgressEntity.notSeen(
        profileId: 'p1',
        domainId: 'multiplication',
        itemKey: 'mul:5x5',
      ),
    ];

    test('puts the longest overdue first', () {
      // Act
      final List<ItemProgressEntity> actualDue = selector.dueOf(
        progress: inputProgress,
        now: inputNow,
      );
      // Assert
      expect(_keysOf(actualDue), <String>['mul:6x7', 'mul:7x8']);
    });
    test('completes the due facts with the least known seen facts', () {
      // Act
      final List<ItemProgressEntity> actualChosen = selector.select(
        progress: inputProgress,
        now: inputNow,
        count: 10,
      );
      // Assert
      expect(_keysOf(actualChosen), <String>[
        'mul:6x7',
        'mul:7x8',
        'mul:9x9',
        'mul:3x4',
        'mul:2x2',
      ]);
    });
    test('keeps at most the count asked, the due facts first', () {
      // Act
      final List<ItemProgressEntity> actualChosen = selector.select(
        progress: inputProgress,
        now: inputNow,
        count: 3,
      );
      // Assert
      expect(_keysOf(actualChosen), <String>['mul:6x7', 'mul:7x8', 'mul:9x9']);
    });
    test('has nothing to review before any fact was seen', () {
      // Act
      final List<ItemProgressEntity> actualChosen = selector.select(
        progress: inputProgress.skip(5),
        now: inputNow,
        count: 10,
      );
      // Assert
      expect(actualChosen, isEmpty);
    });
  });

  group('Daily review over the stored progress', () {
    late AppDatabase appDatabase;
    late TableChangeBus changeBus;
    late ItemProgressRepositoryImpl repository;
    late StoppedClock clock;
    late DomainRegistry domains;
    late QuestionTypeRegistry types;

    setUpAll(sqfliteFfiInit);

    setUp(() async {
      appDatabase = await openMasteryDatabase();
      changeBus = TableChangeBus();
      clock = StoppedClock(masteryNow);
      repository = ItemProgressRepositoryImpl(
        progress: ItemProgressLocalDataSourceImpl(database: appDatabase),
        clock: clock,
        changeBus: changeBus,
      );
      (domains, types) = buildMasteryRegistries();
    });

    tearDown(() async {
      await changeBus.dispose();
      await appDatabase.close();
    });

    PlanQuizUseCase planQuiz() => PlanQuizUseCase(
      repository: repository,
      domains: domains,
      questionTypes: types,
      random: DartRandomSource(seed: 3),
      clock: clock,
    );

    GetReviewOverviewUseCase getOverview() =>
        GetReviewOverviewUseCase(repository: repository, clock: clock);

    QuizPlanRequest reviewRequest({int questionCount = 10}) {
      return QuizPlanRequest(
        profileId: 'p1',
        domainId: 'multiplication',
        itemKeys: <String>[
          for (int table = 1; table <= 12; table++)
            for (int multiplier = 1; multiplier <= 10; multiplier++)
              'mul:${table}x$multiplier',
        ],
        questionTypeIds: _reviewTypes,
        questionCount: questionCount,
        selection: QuizSelection.review,
      );
    }

    Future<void> answer(String itemKey, {required bool isCorrect}) async {
      await RecordAnswerUseCase(
        repository: repository,
        questionTypes: types,
        clock: clock,
      )(
        params: ItemAnswer(
          profileId: 'p1',
          domainId: 'multiplication',
          itemKey: itemKey,
          questionTypeId: QuestionTypeIds.typedAnswer,
          isCorrect: isCorrect,
          answerTime: const Duration(seconds: 2),
        ),
      );
    }

    test('proposes first the facts missed the day before', () async {
      // Arrange
      await answer('mul:3x4', isCorrect: true);
      await answer('mul:7x8', isCorrect: false);
      await answer('mul:6x6', isCorrect: true);
      clock.current = DateTime(2026, 10, 11, 9);
      // Act
      final List<QuizItemPlan> actualFirst = (await planQuiz()(
        params: reviewRequest(questionCount: 1),
      )).requireData;
      final List<QuizItemPlan> actualAll = (await planQuiz()(
        params: reviewRequest(),
      )).requireData;
      // Assert
      expect(actualFirst, <QuizItemPlan>[
        QuizItemPlan(
          itemKey: 'mul:7x8',
          questionTypeIds: const <String>[
            QuestionTypeIds.multipleChoice,
            QuestionTypeIds.trueFalse,
          ],
        ),
      ]);
      expect(
        actualAll.map((QuizItemPlan plan) => plan.itemKey).toSet(),
        <String>{'mul:3x4', 'mul:7x8', 'mul:6x6'},
      );
      expect(actualAll, hasLength(3));
    });
    test('asks written answers for a fact of box 3', () async {
      // Arrange
      await repository.saveProgress(
        progress: buildProgress(
          'mul:4x4',
          box: 3,
          nextReviewAt: DateTime(2026, 10, 9),
        ),
      );
      // Act
      final List<QuizItemPlan> actualPlans = (await planQuiz()(
        params: reviewRequest(),
      )).requireData;
      // Assert
      expect(actualPlans.single.questionTypeIds, const <String>[
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
      ]);
    });
    test('plans no question before any fact was seen', () async {
      // Act
      final List<QuizItemPlan> actualPlans = (await planQuiz()(
        params: reviewRequest(),
      )).requireData;
      // Assert
      expect(actualPlans, isEmpty);
    });
    test('counts the facts due and the facts seen', () async {
      // Arrange
      await answer('mul:3x4', isCorrect: true);
      await answer('mul:7x8', isCorrect: false);
      // Act
      final ReviewOverview actualToday = (await getOverview()(
        params: _scope,
      )).requireData;
      clock.current = DateTime(2026, 10, 11, 9);
      final ReviewOverview actualNextDay = (await getOverview()(
        params: _scope,
      )).requireData;
      // Assert
      expect(actualToday, const ReviewOverview(dueCount: 0, seenCount: 2));
      expect(actualNextDay, const ReviewOverview(dueCount: 1, seenCount: 2));
    });
    test('gives the overview through the mastery service', () async {
      // Arrange
      final MasteryServiceImpl service = MasteryServiceImpl(
        planQuiz: planQuiz(),
        recordAnswer: RecordAnswerUseCase(
          repository: repository,
          questionTypes: types,
          clock: clock,
        ),
        getGrid: GetMasteryGridUseCase(
          repository: repository,
          domains: domains,
        ),
        getReviewOverview: getOverview(),
        getMonsters: GetMonstersUseCase(
          repository: repository,
          domains: domains,
        ),
      );
      await answer('mul:7x8', isCorrect: false);
      // Act
      final ReviewOverview actualOverview = (await service.readReviewOverview(
        profileId: 'p1',
        domainId: 'multiplication',
      )).requireData;
      // Assert
      expect(actualOverview, const ReviewOverview(dueCount: 0, seenCount: 1));
      expect(actualOverview.toString(), contains('1 seen'));
    });
    test('fails when the progress cannot be read', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await getOverview()(
        params: _scope,
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });
}
