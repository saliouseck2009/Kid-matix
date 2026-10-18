import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/division/domain/services/division_domain.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/review_key.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';
import 'package:kid_matix/features/learning_path/domain/services/stage_quiz_specs.dart';
import 'package:kid_matix/features/learning_path/domain/services/unit_domain_resolver.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';

StageProgressEntity _stars(String unitKey, StageKind stage, int stars) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: 'division',
    unitKey: unitKey,
    stage: stage,
    bestStars: stars,
    bestScore: 10,
    completedAt: DateTime(2026, 10, 18),
  );
}

void main() {
  final DivisionDomain division = DivisionDomain();
  final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain())
    ..register(NumbersDomain())
    ..register(division);
  const StageQuizSpecs specs = StageQuizSpecs();

  List<String> typesOf(QuizSpec spec) {
    return <String>[
      for (final Question question in const QuestionGenerator().generate(
        domain: division,
        items: spec.itemKeys
            .map((String key) => division.findItem(key)!)
            .toList(),
        questionTypeIds: spec.questionTypeIds,
        random: DartRandomSource(seed: 4),
      ))
        question.questionTypeId,
    ];
  }

  test('names the review of the division in its own key', () {
    // Assert
    expect(
      const ReviewKey(domainId: 'division', number: 1).toKey(),
      'review:division:1',
    );
    expect(
      ReviewKey.tryParse('review:division:1'),
      const ReviewKey(domainId: 'division', number: 1),
    );
    expect(ReviewKey.isValidDomainId('division'), isTrue);
  });
  test('finds the division from its units and its reviews', () {
    // Arrange
    const UnitDomainResolver inputResolver = UnitDomainResolver();
    // Assert
    expect(
      inputResolver.domainOf(domains: domains, unitKey: 'div:7')?.id,
      'division',
    );
    expect(
      inputResolver
          .domainOf(domains: domains, unitKey: 'review:division:2')
          ?.id,
      'division',
    );
    expect(
      inputResolver.domainOf(domains: domains, unitKey: 'mul:7')?.id,
      'multiplication',
    );
  });

  group('the path of the division', () {
    final LearningPathEntity path = const LearningPathBuilder().build(
      domainId: 'division',
      units: division.path,
      progress: <StageProgressEntity>[
        _stars('div:1', StageKind.writing, 2),
        _stars('div:2', StageKind.writing, 3),
        _stars('div:2', StageKind.boss, 3),
      ],
      isEverythingUnlocked: false,
    );

    test('has 12 units, in the order of the multiplication tables', () {
      // Assert
      expect(path.tables, hasLength(12));
      expect(
        path.tables.map((TablePathNode node) => node.unitKey),
        <String>[
          for (final int divisor in <int>[
            1,
            2,
            10,
            5,
            3,
            4,
            6,
            9,
            7,
            8,
            11,
            12,
          ])
            'div:$divisor',
        ],
      );
    });
    test('puts a review after every group of 3 units', () {
      // Assert
      expect(
        path.nodes.whereType<ReviewPathNode>().map(
          (ReviewPathNode review) => review.unitKey,
        ),
        <String>[
          'review:division:1',
          'review:division:2',
          'review:division:3',
          'review:division:4',
        ],
      );
    });
    test('opens the next unit once the previous one is done', () {
      // Assert
      expect(path.tables[0].status, TableStatus.done);
      expect(path.tables[1].status, TableStatus.done);
      expect(path.tables[2].status, TableStatus.current);
      expect(path.tables[3].status, TableStatus.locked);
    });
    test('crowns a unit whose boss is beaten with three stars', () {
      // Assert
      expect(path.tables[1].crown, isNot(TableCrown.none));
      expect(path.tables[2].crown, TableCrown.none);
    });
  });

  group('the stages of the division', () {
    QuizSpec specOf(String unitKey, StageKind stage) {
      return specs.specOf(
        domain: division,
        source: StageSource(unitKey: unitKey, stage: stage),
      )!;
    }

    test('discovers the divisions by 2 in order, to pick', () {
      // Act
      final QuizSpec actual = specOf('div:2', StageKind.discovery);
      // Assert
      expect(actual.domainId, 'division');
      expect(actual.selection, QuizSelection.inOrder);
      expect(actual.itemKeys.first, 'div:2/2');
      expect(actual.itemKeys.last, 'div:20/2');
      expect(actual.itemKeys, hasLength(10));
      expect(actual.sourceKey, 'path:div:2:discovery');
      expect(typesOf(actual).toSet(), <String>{QuestionTypeIds.multipleChoice});
    });
    test('trains by picking or saying true or false', () {
      // Act
      final QuizSpec actual = specOf('div:2', StageKind.training);
      // Assert
      expect(typesOf(actual).toSet(), <String>{
        QuestionTypeIds.multipleChoice,
        QuestionTypeIds.trueFalse,
      });
    });
    test('writes the result or the missing number at stage 3', () {
      // Act
      final QuizSpec actual = specOf('div:2', StageKind.writing);
      // Assert
      expect(typesOf(actual).toSet(), <String>{
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
      });
    });
    test('races against the clock and fights a boss on any format', () {
      for (final StageKind stage in <StageKind>[
        StageKind.speed,
        StageKind.boss,
      ]) {
        // Act
        final QuizSpec actual = specOf('div:7', stage);
        // Assert
        expect(actual.baseTimeLimit, isNotNull, reason: stage.name);
        expect(typesOf(actual), hasLength(10), reason: stage.name);
      }
    });
    test('fights a boss per unit, then on the units seen before', () {
      // Act
      final QuizSpec actualFirst = specOf('div:1', StageKind.boss);
      final QuizSpec actualFourth = specOf('div:5', StageKind.boss);
      // Assert
      expect(actualFirst.isBossFight, isTrue);
      expect(actualFirst.followUpItemKeys, actualFirst.itemKeys);
      expect(actualFourth.followUpItemKeys, hasLength(30));
      expect(actualFourth.followUpItemKeys.first, 'div:1/1');
      expect(actualFourth.followUpItemKeys.last, 'div:100/10');
    });
    test('reviews the units of its own domain only', () {
      // Act
      final QuizSpec actual = specOf('review:division:1', StageKind.review);
      // Assert
      expect(actual.itemKeys, hasLength(30));
      expect(actual.itemKeys.last, 'div:100/10');
      expect(
        specs.specOf(
          domain: division,
          source: const StageSource(
            unitKey: 'review:1',
            stage: StageKind.review,
          ),
        ),
        isNull,
      );
    });
    test('keeps every unit on the path with its own stages', () {
      for (final LearningUnit unit in division.path) {
        for (final StageKind stage in <StageKind>[
          StageKind.discovery,
          StageKind.training,
          StageKind.writing,
          StageKind.speed,
          StageKind.boss,
        ]) {
          // Assert
          expect(specOf(unit.key, stage).itemKeys, hasLength(10));
        }
      }
    });
  });
}
