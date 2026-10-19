import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_test_entity.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/placement_answer_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/run_placement_test_use_case.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/test_path_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();

  Future<PlacementTestEntity> runTest({int seed = 1}) async {
    final RunPlacementTestUseCase useCase = RunPlacementTestUseCase(
      domains: buildDomainRegistry(),
      random: DartRandomSource(seed: seed),
    );
    return (await useCase(params: domain.id)).requireData;
  }

  group('RunPlacementTestUseCase', () {
    test('asks one typed question per table, from 1 to 12', () async {
      // Act
      final PlacementTestEntity actualTest = await runTest();
      // Assert
      expect(actualTest.domainId, domain.id);
      expect(
        actualTest.questions.map((PlacementQuestionEntity q) => q.unitNumber),
        <int>[for (int number = 1; number <= 12; number++) number],
      );
      for (final PlacementQuestionEntity question in actualTest.questions) {
        expect(question.unitKey, 'mul:${question.unitNumber}');
        expect(question.question.questionTypeId, QuestionTypeIds.typedAnswer);
      }
    });
    test('draws a fact in the middle of each table', () async {
      // Arrange
      final Set<int> actualMultipliers = <int>{};
      // Act
      for (int seed = 0; seed < 20; seed++) {
        for (final PlacementQuestionEntity question in (await runTest(
          seed: seed,
        )).questions) {
          final MultiplicationFact fact = domain.findItem(
            question.question.itemKey,
          )!;
          expect(fact.table, question.unitNumber);
          actualMultipliers.add(fact.multiplier);
        }
      }
      // Assert
      expect(actualMultipliers, <int>{3, 4, 5, 6, 7, 8});
    });
    test('draws the same test from the same seed', () async {
      // Act
      final PlacementTestEntity actualFirst = await runTest(seed: 7);
      final PlacementTestEntity actualSecond = await runTest(seed: 7);
      // Assert
      expect(actualFirst, actualSecond);
      expect(actualFirst.hashCode, actualSecond.hashCode);
    });
    test('fails on an unknown domain', () async {
      // Arrange
      final RunPlacementTestUseCase inputUseCase = RunPlacementTestUseCase(
        domains: buildDomainRegistry(),
        random: DartRandomSource(seed: 1),
      );
      // Act
      final AppException? actualException = (await inputUseCase(
        params: 'unknown',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
  });

  group('AnswerPlacementQuestionUseCase', () {
    late InMemoryStageProgressRepository repository;
    late FakeMasteryService mastery;
    late AnswerPlacementQuestionUseCase useCase;
    late PlacementQuestionEntity question;

    setUp(() async {
      repository = InMemoryStageProgressRepository();
      mastery = FakeMasteryService();
      useCase = AnswerPlacementQuestionUseCase(
        repository: repository,
        mastery: mastery,
      );
      question = (await runTest()).questions[6];
    });

    Future<DataState<bool>> answer(Answer? given) {
      return useCase(
        params: PlacementAnswerParams(
          profileId: 'p1',
          domainId: domain.id,
          question: question.question,
          answer: given,
          answerTime: const Duration(seconds: 4),
        ),
      );
    }

    test('opens the table of a right answer and records it', () async {
      // Act
      final bool actualCorrect = (await answer(
        question.question.expectedAnswer,
      )).requireData;
      // Assert
      final ItemAnswer actualRecorded = mastery.recordedAnswers.single;
      expect(actualCorrect, isTrue);
      expect(repository.placedUnitKeys, <String>{'mul:7'});
      expect(actualRecorded.itemKey, question.question.itemKey);
      expect(actualRecorded.isCorrect, isTrue);
      expect(actualRecorded.questionTypeId, QuestionTypeIds.typedAnswer);
      expect(actualRecorded.answerTime, const Duration(seconds: 4));
      expect(actualRecorded.isRetry, isFalse);
    });
    test('records a wrong answer and "Je ne sais pas" as mistakes', () async {
      // Act
      final bool actualWrong = (await answer(
        const NumberAnswer(1000),
      )).requireData;
      final bool actualUnknown = (await answer(null)).requireData;
      // Assert
      expect(actualWrong, isFalse);
      expect(actualUnknown, isFalse);
      expect(repository.placedUnitKeys, isEmpty);
      expect(
        mastery.recordedAnswers.map((ItemAnswer answer) => answer.isCorrect),
        <bool>[false, false],
      );
    });
    test('fails without opening when the mastery is not written', () async {
      // Arrange
      mastery.failure = const CacheException();
      // Act
      final AppException? actualException = (await answer(
        question.question.expectedAnswer,
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
      expect(repository.placedUnitKeys, isEmpty);
    });
    test('fails when the table cannot be opened', () async {
      // Arrange
      repository.openFailure = const CacheException();
      // Act
      final AppException? actualException = (await answer(
        question.question.expectedAnswer,
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('LearningPathBuilder with the placement test', () {
    test('opens exactly the tables found, each on its own', () {
      // Act
      final LearningPathEntity actualPath = const LearningPathBuilder().build(
        domainId: domain.id,
        units: domain.path,
        progress: const [],
        isEverythingUnlocked: false,
        placedUnitKeys: <String>{'mul:1', 'mul:2', 'mul:10'},
      );
      // Assert
      final List<String> actualOpen = <String>[
        for (final TablePathNode table in actualPath.tables)
          if (table.status != TableStatus.locked) table.unitKey,
      ];
      expect(actualOpen, <String>['mul:1', 'mul:2', 'mul:10']);
      for (final TablePathNode table in actualPath.tables.take(3)) {
        expect(table.totalStars, 0);
        expect(table.stages.first.isUnlocked, isTrue);
        expect(table.stages[1].isUnlocked, isFalse);
      }
      expect(actualPath.tables.first.status, TableStatus.current);
    });
    test('opens a table found beyond a locked one', () {
      // Act
      final LearningPathEntity actualPath = const LearningPathBuilder().build(
        domainId: domain.id,
        units: domain.path,
        progress: const [],
        isEverythingUnlocked: false,
        placedUnitKeys: <String>{'mul:7'},
      );
      // Assert
      final TablePathNode actualSeven = actualPath.tables.firstWhere(
        (TablePathNode table) => table.unitKey == 'mul:7',
      );
      expect(actualSeven.status, TableStatus.open);
      expect(actualPath.tables[1].status, TableStatus.locked);
    });
  });
}
