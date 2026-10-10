import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/question_type_registry.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/mastery/data/datasources/item_progress_local_data_source_impl.dart';
import 'package:kid_matix/features/mastery/data/repositories/item_progress_repository_impl.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_mastery_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_grid_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_status.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_service_impl.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_due_facts_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';
import 'package:kid_matix/features/mastery/domain/usecases/plan_quiz_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/record_answer_use_case.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/mastery_fixtures.dart';

ItemAnswer _answer({
  String itemKey = 'mul:7x8',
  String questionTypeId = QuestionTypeIds.typedAnswer,
  bool isCorrect = true,
}) {
  return ItemAnswer(
    profileId: 'p1',
    domainId: 'multiplication',
    itemKey: itemKey,
    questionTypeId: questionTypeId,
    isCorrect: isCorrect,
    answerTime: const Duration(milliseconds: 2100),
  );
}

QuizPlanRequest _planRequest({
  List<String> itemKeys = const <String>['mul:7x8', 'mul:7x9'],
  List<String> questionTypeIds = const <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.typedAnswer,
  ],
}) {
  return QuizPlanRequest(
    profileId: 'p1',
    domainId: 'multiplication',
    itemKeys: itemKeys,
    questionTypeIds: questionTypeIds,
    questionCount: 4,
  );
}

const MasteryScope _scope = MasteryScope(
  profileId: 'p1',
  domainId: 'multiplication',
);

void main() {
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

  RecordAnswerUseCase recordAnswer() => RecordAnswerUseCase(
    repository: repository,
    questionTypes: types,
    clock: clock,
  );

  PlanQuizUseCase planQuiz() => PlanQuizUseCase(
    repository: repository,
    domains: domains,
    questionTypes: types,
    random: DartRandomSource(seed: 1),
  );

  group('RecordAnswerUseCase', () {
    test('creates the progress of an item at its first answer', () async {
      // Act
      final ItemProgressEntity actualProgress = (await recordAnswer()(
        params: _answer(),
      )).requireData;
      // Assert
      final ItemProgressEntity actualStored = (await repository.getItemProgress(
        profileId: 'p1',
        domainId: 'multiplication',
        itemKey: 'mul:7x8',
      )).requireData;
      expect(actualProgress.box, 1);
      expect(actualProgress.nextReviewAt, DateTime(2026, 10, 11));
      expect(actualStored, actualProgress);
    });
    test('caps a picked answer at box 3', () async {
      // Arrange
      await repository.saveProgress(
        progress: buildProgress('mul:7x8', box: 3),
      );
      // Act
      final ItemProgressEntity actualProgress = (await recordAnswer()(
        params: _answer(questionTypeId: QuestionTypeIds.multipleChoice),
      )).requireData;
      // Assert
      expect(actualProgress.box, 3);
      expect(actualProgress.presentationCount, 2);
    });
    test('sends a wrong answer back to box 1', () async {
      // Arrange
      await repository.saveProgress(
        progress: buildProgress('mul:7x8', box: 4),
      );
      // Act
      final ItemProgressEntity actualProgress = (await recordAnswer()(
        params: _answer(isCorrect: false),
      )).requireData;
      // Assert
      expect(actualProgress.box, 1);
    });
    test('fails on an unknown question type', () async {
      // Act
      final AppException? actualException = (await recordAnswer()(
        params: _answer(questionTypeId: 'unknown'),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
    test('fails when the progress cannot be read', () async {
      // Arrange
      final MockItemProgressRepository mockRepository =
          MockItemProgressRepository();
      when(
        () => mockRepository.getItemProgress(
          profileId: any(named: 'profileId'),
          domainId: any(named: 'domainId'),
          itemKey: any(named: 'itemKey'),
        ),
      ).thenAnswer(
        (_) async => const DataFailed<ItemProgressEntity>(CacheException()),
      );
      // Act
      final AppException? actualException = (await RecordAnswerUseCase(
        repository: mockRepository,
        questionTypes: types,
        clock: clock,
      )(params: _answer())).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
    test('fails when the progress cannot be saved', () async {
      // Act
      final AppException? actualException = (await recordAnswer()(
        params: const ItemAnswer(
          profileId: 'unknown',
          domainId: 'multiplication',
          itemKey: 'mul:7x8',
          questionTypeId: QuestionTypeIds.typedAnswer,
          isCorrect: true,
          answerTime: Duration(seconds: 2),
        ),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('PlanQuizUseCase', () {
    test('plans the questions among the given items', () async {
      // Act
      final List<QuizItemPlan> actualPlans = (await planQuiz()(
        params: _planRequest(),
      )).requireData;
      // Assert
      expect(actualPlans, hasLength(4));
      for (final QuizItemPlan plan in actualPlans) {
        expect(<String>['mul:7x8', 'mul:7x9'], contains(plan.itemKey));
        expect(plan.questionTypeIds, <String>[QuestionTypeIds.multipleChoice]);
      }
    });
    test('asks written answers for an item in box 3', () async {
      // Arrange
      await repository.saveProgress(
        progress: buildProgress('mul:7x8', box: 3),
      );
      // Act
      final List<QuizItemPlan> actualPlans = (await planQuiz()(
        params: _planRequest(itemKeys: const <String>['mul:7x8']),
      )).requireData;
      // Assert
      expect(actualPlans.first.questionTypeIds, <String>[
        QuestionTypeIds.typedAnswer,
      ]);
    });
    test('fails on an unknown item, domain or question type', () async {
      // Act
      final AppException? actualItem = (await planQuiz()(
        params: _planRequest(itemKeys: const <String>['mul:13x1']),
      )).exceptionOrNull;
      final AppException? actualTypes = (await planQuiz()(
        params: _planRequest(questionTypeIds: const <String>['unknown']),
      )).exceptionOrNull;
      final AppException? actualDomain = (await planQuiz()(
        params: QuizPlanRequest(
          profileId: 'p1',
          domainId: 'division',
          itemKeys: const <String>[],
          questionTypeIds: const <String>[],
          questionCount: 1,
        ),
      )).exceptionOrNull;
      // Assert
      expect(actualItem, isA<ValidationException>());
      expect(actualTypes, isA<ValidationException>());
      expect(actualDomain, isA<ValidationException>());
    });
    test('fails when the progress cannot be read', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await planQuiz()(
        params: _planRequest(),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('GetDueFactsUseCase', () {
    test('returns the due items, longest overdue then least known', () async {
      // Arrange
      final List<ItemProgressEntity> inputProgress = <ItemProgressEntity>[
        buildProgress('mul:7x8', nextReviewAt: DateTime(2026, 10, 10)),
        buildProgress(
          'mul:7x9',
          nextReviewAt: DateTime(2026, 10, 10),
          presentationCount: 4,
          correctCount: 1,
        ),
        buildProgress('mul:6x7', nextReviewAt: DateTime(2026, 10, 8)),
        buildProgress('mul:2x2', nextReviewAt: DateTime(2026, 10, 11)),
      ];
      for (final ItemProgressEntity progress in inputProgress) {
        await repository.saveProgress(progress: progress);
      }
      // Act
      final List<ItemProgressEntity> actualDue = (await GetDueFactsUseCase(
        repository: repository,
        clock: clock,
      )(params: _scope)).requireData;
      // Assert
      expect(
        actualDue.map((ItemProgressEntity item) => item.itemKey).toList(),
        <String>['mul:6x7', 'mul:7x9', 'mul:7x8'],
      );
    });
    test('fails when the progress cannot be read', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await GetDueFactsUseCase(
        repository: repository,
        clock: clock,
      )(params: _scope)).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('GetMasteryGridUseCase', () {
    test('gives every fact of every table its status', () async {
      // Arrange
      await repository.saveProgress(
        progress: buildProgress('mul:7x8', box: 4),
      );
      // Act
      final MasteryGridEntity actualGrid = (await GetMasteryGridUseCase(
        repository: repository,
        domains: domains,
      )(params: _scope)).requireData;
      // Assert
      expect(actualGrid.rows.keys.first, 'mul:1');
      expect(actualGrid.rows, hasLength(12));
      expect(
        actualGrid.rows.values.expand((List<ItemMasteryEntity> row) => row),
        hasLength(120),
      );
      expect(
        actualGrid.rows['mul:7']![7],
        const ItemMasteryEntity(
          itemKey: 'mul:7x8',
          status: MasteryStatus.acquired,
        ),
      );
      expect(actualGrid.rows['mul:7']![8].status, MasteryStatus.notSeen);
    });
    test('fails on an unknown domain', () async {
      // Act
      final AppException? actualException =
          (await GetMasteryGridUseCase(
                repository: repository,
                domains: domains,
              )(
                params: const MasteryScope(
                  profileId: 'p1',
                  domainId: 'division',
                ),
              ))
              .exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
    test('fails when the progress cannot be read', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await GetMasteryGridUseCase(
        repository: repository,
        domains: domains,
      )(params: _scope)).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('MasteryServiceImpl', () {
    test('plans a quiz and records its answers', () async {
      // Arrange
      final MasteryServiceImpl service = MasteryServiceImpl(
        planQuiz: planQuiz(),
        recordAnswer: recordAnswer(),
      );
      // Act
      final List<QuizItemPlan> actualPlans = (await service.planQuiz(
        request: _planRequest(),
      )).requireData;
      final DataState<void> actualRecord = await service.recordAnswer(
        answer: _answer(),
      );
      final AppException? actualFailure = (await service.recordAnswer(
        answer: _answer(questionTypeId: 'unknown'),
      )).exceptionOrNull;
      // Assert
      expect(actualPlans, hasLength(4));
      expect(actualRecord, isA<DataSuccess<void>>());
      expect(actualFailure, isA<ValidationException>());
    });
  });
}
