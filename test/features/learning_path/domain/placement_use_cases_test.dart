import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/learning_path/data/datasources/path_domain_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/path_domain_repository_impl.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_journey.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_level.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_levels.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/build_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_placement_history_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/placement_answer_params.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/save_placement_result_use_case.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/in_memory_local_storage.dart';
import '../../../helpers/test_path_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

PlacementJourney _play(List<bool> answers) {
  PlacementJourney journey = PlacementJourney.start();
  for (final bool isCorrect in answers) {
    if (journey.isOver) break;
    journey = journey.answered(isCorrect: isCorrect);
  }
  return journey;
}

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();

  group('BuildPlacementQuestionUseCase', () {
    BuildPlacementQuestionUseCase buildUseCase({int seed = 1}) {
      return BuildPlacementQuestionUseCase(
        domains: buildDomainRegistry(),
        random: DartRandomSource(seed: seed),
      );
    }

    test(
      'asks a typed question of every typical unit of every skill',
      () async {
        for (final SkillLevel skill in SkillLevels.all) {
          for (final String unitKey in skill.probeUnitKeys) {
            // Act
            final Question actualQuestion = (await buildUseCase()(
              params: PlacementProbeParams(
                domainId: skill.domainId,
                unitKey: unitKey,
              ),
            )).requireData;
            // Assert
            expect(actualQuestion.unitKey, unitKey);
            expect(actualQuestion.questionTypeId, QuestionTypeIds.typedAnswer);
            expect(actualQuestion.expectedAnswer, isA<NumberAnswer>());
          }
        }
      },
    );

    test('draws a fact in the middle of the table', () async {
      // Arrange
      final Set<int> actualMultipliers = <int>{};
      // Act
      for (int seed = 0; seed < 30; seed++) {
        final Question question = (await buildUseCase(seed: seed)(
          params: const PlacementProbeParams(
            domainId: 'multiplication',
            unitKey: 'mul:7',
          ),
        )).requireData;
        final MultiplicationFact fact = domain.findItem(question.itemKey)!;
        expect(fact.table, 7);
        actualMultipliers.add(fact.multiplier);
      }
      // Assert
      expect(actualMultipliers, <int>{3, 4, 5, 6, 7, 8});
    });

    test('fails on an unknown domain or unit', () async {
      // Act
      final AppException? actualDomain = (await buildUseCase()(
        params: const PlacementProbeParams(
          domainId: 'unknown',
          unitKey: 'mul:7',
        ),
      )).exceptionOrNull;
      final AppException? actualUnit = (await buildUseCase()(
        params: const PlacementProbeParams(
          domainId: 'multiplication',
          unitKey: 'mul:99',
        ),
      )).exceptionOrNull;
      // Assert
      expect(actualDomain, isA<ValidationException>());
      expect(actualUnit, isA<ValidationException>());
    });

    test('fails on a unit whose items cannot be typed', () async {
      // Act
      final AppException? actualException = (await buildUseCase()(
        params: const PlacementProbeParams(
          domainId: 'numbers',
          unitKey: 'num:compare',
        ),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
  });

  group('AnswerPlacementQuestionUseCase', () {
    late InMemoryStageProgressRepository repository;
    late FakeMasteryService mastery;
    late AnswerPlacementQuestionUseCase useCase;
    late Question question;

    setUp(() async {
      repository = InMemoryStageProgressRepository();
      mastery = FakeMasteryService();
      useCase = AnswerPlacementQuestionUseCase(
        repository: repository,
        mastery: mastery,
      );
      question =
          (await BuildPlacementQuestionUseCase(
                domains: buildDomainRegistry(),
                random: DartRandomSource(seed: 1),
              )(
                params: const PlacementProbeParams(
                  domainId: 'multiplication',
                  unitKey: 'mul:7',
                ),
              ))
              .requireData;
    });

    Future<DataState<bool>> answer(
      Answer? given, {
      List<String> unitKeysToOpen = const <String>[],
    }) {
      return useCase(
        params: PlacementAnswerParams(
          profileId: 'p1',
          domainId: domain.id,
          question: question,
          answer: given,
          answerTime: const Duration(seconds: 4),
          unitKeysToOpen: unitKeysToOpen,
        ),
      );
    }

    test('opens the table of a right answer and records it', () async {
      // Act
      final bool actualCorrect = (await answer(
        question.expectedAnswer,
      )).requireData;
      // Assert
      final ItemAnswer actualRecorded = mastery.recordedAnswers.single;
      expect(actualCorrect, isTrue);
      expect(repository.placedUnitKeys, <String>{'mul:7'});
      expect(actualRecorded.itemKey, question.itemKey);
      expect(actualRecorded.isCorrect, isTrue);
      expect(actualRecorded.questionTypeId, QuestionTypeIds.typedAnswer);
      expect(actualRecorded.answerTime, const Duration(seconds: 4));
    });

    test('opens every unit it is given for a right answer', () async {
      // Act
      await answer(
        question.expectedAnswer,
        unitKeysToOpen: <String>['mul:1', 'mul:2', 'mul:10'],
      );
      // Assert
      expect(repository.placedUnitKeys, <String>{'mul:1', 'mul:2', 'mul:10'});
    });

    test('records a wrong answer and "Je ne sais pas" as mistakes', () async {
      // Act
      final bool actualWrong = (await answer(
        const NumberAnswer(1000),
        unitKeysToOpen: <String>['mul:1'],
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
        question.expectedAnswer,
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
      expect(repository.placedUnitKeys, isEmpty);
    });

    test('fails when a unit cannot be opened', () async {
      // Arrange
      repository.openFailure = const CacheException();
      // Act
      final AppException? actualException = (await answer(
        question.expectedAnswer,
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('SavePlacementResultUseCase', () {
    late InMemoryPlacementResultRepository results;
    late InMemoryStageProgressRepository stages;
    late InMemoryLocalStorage storage;
    late SavePlacementResultUseCase useCase;

    setUp(() {
      results = InMemoryPlacementResultRepository(clock: FakeClock(quizStart));
      stages = InMemoryStageProgressRepository();
      storage = InMemoryLocalStorage();
      useCase = SavePlacementResultUseCase(
        results: results,
        stages: stages,
        domains: PathDomainRepositoryImpl(
          domains: PathDomainLocalDataSourceImpl(storage: storage),
        ),
      );
    });

    Future<String?> chosenDomain() async {
      return (await PathDomainRepositoryImpl(
        domains: PathDomainLocalDataSourceImpl(storage: storage),
      ).getDomain(profileId: 'p1')).requireData;
    }

    test(
      'keeps the result, opens the start unit and chooses its domain',
      () async {
        // Act: the child counts but cannot add.
        final DataState<void> actualSaved = await useCase(
          params: SavePlacementResultParams(
            profileId: 'p1',
            outcome: _play(<bool>[true, true, true, false, false]).outcome,
          ),
        );
        // Assert
        expect(actualSaved, isA<DataSuccess<void>>());
        expect(results.saved, hasLength(1));
        expect(results.saved.single.takenAt, quizStart);
        expect(stages.placedUnitKeys, <String>{'addsub:add5'});
        expect(await chosenDomain(), 'addition');
      },
    );

    test('leaves the domain alone when every skill is passed', () async {
      // Act
      await useCase(
        params: SavePlacementResultParams(
          profileId: 'p1',
          outcome: _play(List<bool>.filled(15, true)).outcome,
        ),
      );
      // Assert
      expect(results.saved, hasLength(1));
      expect(stages.placedUnitKeys, isEmpty);
      expect(await chosenDomain(), isNull);
    });

    test('keeps nothing when the start unit cannot be opened', () async {
      // Arrange
      stages.openFailure = const CacheException();
      // Act
      final DataState<void> actualSaved = await useCase(
        params: SavePlacementResultParams(
          profileId: 'p1',
          outcome: _play(<bool>[false, false]).outcome,
        ),
      );
      // Assert
      expect(actualSaved, isA<DataFailed<void>>());
      expect(results.saved, isEmpty);
      expect(await chosenDomain(), isNull);
    });

    test('fails without choosing a domain when the result is lost', () async {
      // Arrange
      results.saveFailure = const CacheException();
      // Act
      final DataState<void> actualSaved = await useCase(
        params: SavePlacementResultParams(
          profileId: 'p1',
          outcome: _play(<bool>[false, false]).outcome,
        ),
      );
      // Assert
      expect(actualSaved, isA<DataFailed<void>>());
      expect(await chosenDomain(), isNull);
    });
  });

  group('GetPlacementHistoryUseCase', () {
    test('lists the tests of a player, the latest first', () async {
      // Arrange
      final FakeClock clock = FakeClock(quizStart);
      final InMemoryPlacementResultRepository results =
          InMemoryPlacementResultRepository(clock: clock);
      await results.save(
        profileId: 'p1',
        outcome: _play(<bool>[false, false]).outcome,
      );
      clock.now_ = quizStart.add(const Duration(days: 30));
      await results.save(
        profileId: 'p1',
        outcome: _play(<bool>[true, true, true, false, false]).outcome,
      );
      await results.save(
        profileId: 'p2',
        outcome: _play(<bool>[false, false]).outcome,
      );
      // Act
      final List<PlacementResultEntity> actualHistory =
          (await GetPlacementHistoryUseCase(repository: results)(
            params: 'p1',
          )).requireData;
      // Assert
      expect(
        actualHistory.map((PlacementResultEntity r) => r.takenAt),
        <DateTime>[
          quizStart.add(const Duration(days: 30)),
          quizStart,
        ],
      );
      expect(actualHistory.first.domainOf('numbers')!.level, 1);
      expect(actualHistory.first.recommended!.domainId, 'addition');
      expect(actualHistory.first.recommended!.startUnitKey, 'addsub:add5');
      expect(actualHistory.last.domainOf('numbers')!.level, 0);
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

    test('points at the recommended unit while it is open and not done', () {
      // Act
      final LearningPathEntity actualPath = const LearningPathBuilder().build(
        domainId: domain.id,
        units: domain.path,
        progress: const [],
        isEverythingUnlocked: false,
        placedUnitKeys: <String>{'mul:1', 'mul:2', 'mul:10'},
        recommendedUnitKey: 'mul:10',
      );
      // Assert
      expect(actualPath.currentTable!.unitKey, 'mul:10');
      expect(
        actualPath.tables.where(
          (TablePathNode table) => table.status == TableStatus.current,
        ),
        hasLength(1),
      );
    });

    test('ignores a recommended unit that is locked or unknown', () {
      for (final String key in <String>['mul:7', 'addsub:add5']) {
        // Act
        final LearningPathEntity actualPath = const LearningPathBuilder().build(
          domainId: domain.id,
          units: domain.path,
          progress: const [],
          isEverythingUnlocked: false,
          recommendedUnitKey: key,
        );
        // Assert
        expect(actualPath.currentTable!.unitKey, 'mul:1', reason: key);
      }
    });
  });

  group('GetLearningPathUseCase with the placement test', () {
    test('makes the recommended unit of the domain the current one', () async {
      // Arrange
      final InMemoryPlacementResultRepository results =
          InMemoryPlacementResultRepository(clock: FakeClock(quizStart));
      final InMemoryStageProgressRepository stages =
          InMemoryStageProgressRepository();
      stages.placedUnitKeys.addAll(<String>[
        'addsub:add5',
        'addsub:add7',
        'addsub:sub5',
      ]);
      await results.save(
        profileId: 'p1',
        outcome: _play(<bool>[
          true, true, true, // numbers
          true, true, false, // addition: add5 and toten right, add20 wrong
          false, false, // subtraction missed
        ]).outcome,
      );
      // Act
      final LearningPathEntity actualAddition =
          (await buildTestPathUseCases(
                repository: stages,
                placements: results,
              ).getLearningPath(
                params: const LearningPathParams(
                  profileId: 'p1',
                  domainId: 'addition',
                ),
              ))
              .requireData;
      final LearningPathEntity actualMultiplication =
          (await buildTestPathUseCases(
                repository: stages,
                placements: results,
              ).getLearningPath(
                params: const LearningPathParams(
                  profileId: 'p1',
                  domainId: 'multiplication',
                ),
              ))
              .requireData;
      // Assert
      expect(actualAddition.currentTable!.unitKey, 'addsub:sub5');
      expect(actualMultiplication.currentTable!.unitKey, 'mul:1');
    });
  });
}
