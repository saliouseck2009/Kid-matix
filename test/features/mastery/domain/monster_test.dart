import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
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
import 'package:kid_matix/features/mastery/domain/entities/monster_collection_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_service_impl.dart';
import 'package:kid_matix/features/mastery/domain/services/monster_hunt_selector.dart';
import 'package:kid_matix/features/mastery/domain/services/monster_rule.dart';
import 'package:kid_matix/features/mastery/domain/services/quiz_item_planner.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_monsters_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_review_overview_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';
import 'package:kid_matix/features/mastery/domain/usecases/plan_quiz_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/record_answer_use_case.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/mastery_fixtures.dart';

const MasteryScope _scope = MasteryScope(
  profileId: 'p1',
  domainId: 'multiplication',
);

const MonsterRule _rule = MonsterRule();

const MonsterHuntSelector _hunt = MonsterHuntSelector();

final DateTime _now = DateTime(2026, 10, 11, 9);

/// Progress of [itemKey] in [box] with [missed] wrong answers out of
/// [asked].
ItemProgressEntity _fact(
  String itemKey, {
  required int box,
  required int missed,
  int asked = 4,
}) {
  return buildProgress(
    itemKey,
    box: box,
    presentationCount: asked,
    correctCount: asked - missed,
    nextReviewAt: DateTime(2026, 10, 12),
  );
}

List<String> _keysOf(Iterable<ItemProgressEntity> items) {
  return items.map((ItemProgressEntity item) => item.itemKey).toList();
}

/// Whether some fact of [keys] directly follows itself.
bool _hasNeighbors(List<String> keys) {
  for (int index = 1; index < keys.length; index++) {
    if (keys[index] == keys[index - 1]) return true;
  }
  return false;
}

void main() {
  group('MonsterRule', () {
    test('makes a monster of a fact missed twice in box 1 to 3', () {
      // Arrange
      final List<ItemProgressEntity> inputFacts = <ItemProgressEntity>[
        _fact('mul:7x8', box: 1, missed: 2),
        _fact('mul:6x9', box: 2, missed: 3),
        _fact('mul:8x4', box: 3, missed: 2),
      ];
      // Act
      final List<bool> actualWild = inputFacts.map(_rule.isWild).toList();
      // Assert
      expect(actualWild, <bool>[true, true, true]);
    });
    test('leaves alone a fact missed only once', () {
      // Arrange
      final ItemProgressEntity inputFact = _fact('mul:7x8', box: 1, missed: 1);
      // Act
      final bool actualWild = _rule.isWild(inputFact);
      // Assert
      expect(actualWild, isFalse);
      expect(_rule.isTamed(inputFact), isFalse);
    });
    test('tames a monster once its fact reaches box 4', () {
      // Arrange
      final ItemProgressEntity inputTamed = _fact(
        'mul:7x8',
        box: 4,
        missed: 2,
      );
      final ItemProgressEntity inputBackToOne = inputTamed.copyWith(box: 1);
      // Act
      final bool actualTamed = _rule.isTamed(inputTamed);
      // Assert
      expect(actualTamed, isTrue);
      expect(_rule.isWild(inputTamed), isFalse);
      expect(_rule.isTamed(_fact('mul:7x8', box: 5, missed: 3)), isTrue);
      expect(_rule.isWild(inputBackToOne), isTrue);
      expect(_rule.isTamed(_fact('mul:2x2', box: 4, missed: 1)), isFalse);
    });
    test('shows at most 5 monsters, the toughest first', () {
      // Arrange
      final List<ItemProgressEntity> inputFacts = <ItemProgressEntity>[
        _fact('mul:8x4', box: 3, missed: 2),
        _fact('mul:6x9', box: 2, missed: 2),
        _fact('mul:7x8', box: 1, missed: 2),
        _fact('mul:3x7', box: 1, missed: 4),
        _fact('mul:9x6', box: 1, missed: 2, asked: 8),
        _fact('mul:4x6', box: 1, missed: 2, asked: 3),
        _fact('mul:2x9', box: 1, missed: 2, asked: 3),
        _fact('mul:5x5', box: 1, missed: 1),
      ];
      // Act
      final List<ItemProgressEntity> actualWild = _rule.wildOf(inputFacts);
      // Assert
      expect(_keysOf(actualWild), <String>[
        'mul:3x7',
        'mul:2x9',
        'mul:4x6',
        'mul:7x8',
        'mul:9x6',
      ]);
    });
  });

  group('MonsterHuntSelector', () {
    final List<ItemProgressEntity> inputMonsters = <ItemProgressEntity>[
      _fact('mul:7x8', box: 1, missed: 3),
      _fact('mul:6x9', box: 2, missed: 2),
      _fact('mul:8x4', box: 3, missed: 2),
    ];
    final List<ItemProgressEntity> inputOthers = <ItemProgressEntity>[
      for (int multiplier = 1; multiplier <= 8; multiplier++)
        _fact('mul:2x$multiplier', box: 2, missed: 1),
    ];

    test('asks each monster twice and completes to 10 questions', () {
      // Act
      final List<String> actualKeys = _keysOf(
        _hunt.select(
          progress: <ItemProgressEntity>[...inputOthers, ...inputMonsters],
          now: _now,
          count: 10,
          random: DartRandomSource(seed: 1),
        ),
      );
      // Assert
      expect(actualKeys, hasLength(10));
      for (final String monster in _keysOf(inputMonsters)) {
        expect(actualKeys.where((String key) => key == monster), hasLength(2));
      }
      final List<String> actualOthers = actualKeys
          .where((String key) => key.startsWith('mul:2x'))
          .toList();
      expect(actualOthers, hasLength(4));
      expect(actualOthers.toSet(), hasLength(4));
    });
    test('never asks the same fact twice in a row', () {
      // Arrange
      final List<ItemProgressEntity> inputFiveMonsters = <ItemProgressEntity>[
        for (int multiplier = 1; multiplier <= 5; multiplier++)
          _fact('mul:3x$multiplier', box: 1, missed: 2),
      ];
      // Act
      final List<List<String>> actualHunts = <List<String>>[
        for (int seed = 0; seed < 200; seed++) ...<List<String>>[
          _keysOf(
            _hunt.select(
              progress: inputFiveMonsters,
              now: _now,
              count: 10,
              random: DartRandomSource(seed: seed),
            ),
          ),
          _keysOf(
            _hunt.select(
              progress: <ItemProgressEntity>[
                inputMonsters.first,
                inputOthers.first,
              ],
              now: _now,
              count: 10,
              random: DartRandomSource(seed: seed),
            ),
          ),
        ],
      ];
      // Assert
      for (final List<String> actualKeys in actualHunts) {
        expect(_hasNeighbors(actualKeys), isFalse, reason: '$actualKeys');
      }
      expect(actualHunts.first, hasLength(10));
      expect(actualHunts[1], hasLength(3));
    });
    test('asks a lone monster once when nothing can sit between', () {
      // Act
      final List<ItemProgressEntity> actualHunt = _hunt.select(
        progress: <ItemProgressEntity>[inputMonsters.first],
        now: _now,
        count: 10,
        random: DartRandomSource(seed: 4),
      );
      // Assert
      expect(_keysOf(actualHunt), <String>['mul:7x8']);
    });
    test('gives the same hunt for the same seed', () {
      // Act
      List<String> huntWithSeed(int seed) => _keysOf(
        _hunt.select(
          progress: <ItemProgressEntity>[...inputMonsters, ...inputOthers],
          now: _now,
          count: 10,
          random: DartRandomSource(seed: seed),
        ),
      );
      // Assert
      expect(huntWithSeed(9), huntWithSeed(9));
    });
  });

  group('QuizItemPlanner.planMonsterHunt', () {
    test('asks each monster with the formats of its box', () {
      // Arrange
      final MultiplicationDomain domain = MultiplicationDomain();
      final List<LearningItem> inputItems = domain.findUnit('mul:7')!.items;
      final Map<String, ItemProgressEntity> inputProgress =
          <String, ItemProgressEntity>{
            'mul:7x8': _fact('mul:7x8', box: 1, missed: 2),
            'mul:7x3': _fact('mul:7x3', box: 3, missed: 2),
          };
      // Act
      final List<QuizItemPlan> actualPlans = const QuizItemPlanner()
          .planMonsterHunt(
            items: inputItems,
            progressByKey: inputProgress,
            questionTypeNatures: const <String, AnswerNature>{
              QuestionTypeIds.multipleChoice: AnswerNature.recognized,
              QuestionTypeIds.typedAnswer: AnswerNature.produced,
            },
            count: 10,
            now: _now,
            random: DartRandomSource(seed: 2),
          );
      // Assert
      expect(actualPlans, hasLength(4));
      for (final QuizItemPlan plan in actualPlans) {
        expect(
          plan.questionTypeIds,
          plan.itemKey == 'mul:7x8'
              ? <String>[QuestionTypeIds.multipleChoice]
              : <String>[QuestionTypeIds.typedAnswer],
        );
      }
    });
  });

  group('Monsters over the stored progress', () {
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

    GetMonstersUseCase getMonsters() =>
        GetMonstersUseCase(repository: repository, domains: domains);

    Future<MonsterCollectionEntity> readMonsters() async {
      return (await getMonsters()(params: _scope)).requireData;
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

    test('shows a fact missed twice as a monster', () async {
      // Arrange
      await answer('mul:7x8', isCorrect: false);
      final MonsterCollectionEntity actualAfterOne = await readMonsters();
      await answer('mul:7x8', isCorrect: false);
      // Act
      final MonsterCollectionEntity actualAfterTwo = await readMonsters();
      // Assert
      expect(actualAfterOne.hasWildMonsters, isFalse);
      expect(actualAfterTwo.wild, const <MonsterEntity>[
        MonsterEntity(itemKey: 'mul:7x8', box: 1, missCount: 2),
      ]);
      expect(actualAfterTwo.tamed, isEmpty);
    });
    test('moves a monster to the tamed ones at box 4', () async {
      // Arrange
      await answer('mul:7x8', isCorrect: false);
      await answer('mul:7x8', isCorrect: false);
      for (int right = 0; right < 3; right++) {
        await answer('mul:7x8', isCorrect: true);
      }
      await repository.saveProgress(
        progress: _fact('mul:3x2', box: 5, missed: 2),
      );
      // Act
      final MonsterCollectionEntity actualMonsters = await readMonsters();
      // Assert
      expect(actualMonsters.wild, isEmpty);
      expect(actualMonsters.tamed, const <MonsterEntity>[
        MonsterEntity(itemKey: 'mul:3x2', box: 5, missCount: 2),
        MonsterEntity(itemKey: 'mul:7x8', box: 4, missCount: 2),
      ]);
    });
    test('plans a hunt on the monsters of the player', () async {
      // Arrange
      await answer('mul:7x8', isCorrect: false);
      await answer('mul:7x8', isCorrect: false);
      await answer('mul:3x4', isCorrect: true);
      final PlanQuizUseCase planQuiz = PlanQuizUseCase(
        repository: repository,
        domains: domains,
        questionTypes: types,
        random: DartRandomSource(seed: 5),
        clock: clock,
      );
      // Act
      final List<QuizItemPlan> actualPlans = (await planQuiz(
        params: QuizPlanRequest(
          profileId: 'p1',
          domainId: 'multiplication',
          itemKeys: <String>[
            for (int table = 1; table <= 12; table++)
              for (int multiplier = 1; multiplier <= 10; multiplier++)
                'mul:${table}x$multiplier',
          ],
          questionTypeIds: const <String>[QuestionTypeIds.multipleChoice],
          questionCount: 10,
          selection: QuizSelection.monsterHunt,
        ),
      )).requireData;
      // Assert
      expect(
        actualPlans.map((QuizItemPlan plan) => plan.itemKey).toList(),
        <String>['mul:7x8', 'mul:3x4', 'mul:7x8'],
      );
    });
    test('counts the monsters through the mastery service', () async {
      // Arrange
      final MasteryServiceImpl service = MasteryServiceImpl(
        planQuiz: PlanQuizUseCase(
          repository: repository,
          domains: domains,
          questionTypes: types,
          random: DartRandomSource(seed: 1),
          clock: clock,
        ),
        recordAnswer: RecordAnswerUseCase(
          repository: repository,
          questionTypes: types,
          clock: clock,
        ),
        getGrid: GetMasteryGridUseCase(
          repository: repository,
          domains: domains,
        ),
        getReviewOverview: GetReviewOverviewUseCase(
          repository: repository,
          clock: clock,
        ),
        getMonsters: getMonsters(),
      );
      await answer('mul:7x8', isCorrect: false);
      await answer('mul:7x8', isCorrect: false);
      // Act
      final int actualCount = (await service.readMonsterCount(
        profileId: 'p1',
        domainId: 'multiplication',
      )).requireData;
      final AppException? actualFailure = (await service.readMonsterCount(
        profileId: 'p1',
        domainId: 'division',
      )).exceptionOrNull;
      // Assert
      expect(actualCount, 1);
      expect(actualFailure, isA<ValidationException>());
    });
    test('fails on an unknown domain', () async {
      // Act
      final AppException? actualException = (await getMonsters()(
        params: const MasteryScope(profileId: 'p1', domainId: 'division'),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
    test('fails when the progress cannot be read', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final AppException? actualException = (await getMonsters()(
        params: _scope,
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('MonsterCollectionEntity', () {
    test('compares by value and copies', () {
      // Arrange
      const MonsterEntity inputMonster = MonsterEntity(
        itemKey: 'mul:7x8',
        box: 1,
        missCount: 2,
      );
      final MonsterCollectionEntity inputCollection = MonsterCollectionEntity(
        wild: const <MonsterEntity>[inputMonster],
        tamed: const <MonsterEntity>[],
      );
      // Act
      final MonsterCollectionEntity actualCopy = inputCollection.copyWith(
        tamed: <MonsterEntity>[inputMonster.copyWith(box: 4)],
      );
      // Assert
      expect(inputCollection.copyWith(), inputCollection);
      expect(inputCollection.copyWith().hashCode, inputCollection.hashCode);
      expect(actualCopy, isNot(inputCollection));
      expect(actualCopy.tamed.single.box, 4);
      expect(actualCopy.toString(), contains('mul:7x8'));
    });
  });
}
