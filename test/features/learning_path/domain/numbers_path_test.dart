import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/review_key.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';
import 'package:kid_matix/features/learning_path/domain/services/stage_quiz_specs.dart';
import 'package:kid_matix/features/learning_path/domain/services/unit_domain_resolver.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/numbers/domain/services/numbers_domain.dart';

StageProgressEntity _stars(String unitKey, StageKind stage, int stars) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: 'numbers',
    unitKey: unitKey,
    stage: stage,
    bestStars: stars,
    bestScore: 10,
    completedAt: DateTime(2026, 10, 18),
  );
}

void main() {
  final NumbersDomain numbers = NumbersDomain();
  final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain())
    ..register(numbers);
  const StageQuizSpecs specs = StageQuizSpecs();

  group('ReviewKey', () {
    test('keeps the released keys of the multiplication', () {
      // Assert
      expect(
        const ReviewKey(domainId: 'multiplication', number: 2).toKey(),
        'review:2',
      );
      expect(
        ReviewKey.tryParse('review:2'),
        const ReviewKey(domainId: 'multiplication', number: 2),
      );
    });
    test('names the other domains in their keys', () {
      // Assert
      expect(
        const ReviewKey(domainId: 'numbers', number: 1).toKey(),
        'review:numbers:1',
      );
      expect(
        ReviewKey.tryParse('review:numbers:1'),
        const ReviewKey(domainId: 'numbers', number: 1),
      );
    });
    test('reads nothing from another key', () {
      // Assert
      expect(ReviewKey.tryParse('num:count10'), isNull);
      expect(ReviewKey.tryParse('review:x'), isNull);
      expect(ReviewKey.tryParse('review:a:b:1'), isNull);
    });
  });

  group('UnitDomainResolver', () {
    const UnitDomainResolver resolver = UnitDomainResolver();

    test('finds the domain of a unit or a review', () {
      // Assert
      expect(
        resolver.domainOf(domains: domains, unitKey: 'mul:5')?.id,
        'multiplication',
      );
      expect(
        resolver.domainOf(domains: domains, unitKey: 'num:compare')?.id,
        'numbers',
      );
      expect(
        resolver.domainOf(domains: domains, unitKey: 'review:3')?.id,
        'multiplication',
      );
      expect(
        resolver.domainOf(domains: domains, unitKey: 'review:numbers:2')?.id,
        'numbers',
      );
      expect(resolver.domainOf(domains: domains, unitKey: 'div:7'), isNull);
    });
  });

  group('the path of the numbers', () {
    test('has 7 units and a review after every group of 3', () {
      // Act
      final LearningPathEntity actual = const LearningPathBuilder().build(
        domainId: 'numbers',
        units: numbers.path,
        progress: <StageProgressEntity>[
          _stars('num:count10', StageKind.writing, 2),
        ],
        isEverythingUnlocked: false,
      );
      // Assert
      expect(actual.tables, hasLength(7));
      expect(
        actual.nodes.whereType<ReviewPathNode>().map(
          (ReviewPathNode review) => review.unitKey,
        ),
        <String>['review:numbers:1', 'review:numbers:2'],
      );
      expect(actual.tables[0].status, TableStatus.done);
      expect(actual.tables[1].status, TableStatus.current);
      expect(actual.tables[2].status, TableStatus.locked);
    });
    test('discovers a unit with its 10 items in order, to pick', () {
      // Act
      final QuizSpec actual = specs.specOf(
        domain: numbers,
        source: const StageSource(
          unitKey: 'num:count20',
          stage: StageKind.discovery,
        ),
      )!;
      // Assert
      expect(actual.domainId, 'numbers');
      expect(actual.selection, QuizSelection.inOrder);
      expect(actual.itemKeys.first, 'num:count:11');
      expect(actual.itemKeys, hasLength(10));
      expect(actual.questionTypeIds, contains(QuestionTypeIds.countObjects));
      expect(
        actual.questionTypeIds,
        isNot(contains(QuestionTypeIds.typedAnswer)),
      );
      expect(actual.sourceKey, 'path:num:count20:discovery');
    });
    test('asks the comparisons at every stage, written at stage 3', () {
      for (final StageKind stage in <StageKind>[
        StageKind.discovery,
        StageKind.training,
        StageKind.writing,
        StageKind.speed,
        StageKind.boss,
      ]) {
        // Act
        final QuizSpec actual = specs.specOf(
          domain: numbers,
          source: StageSource(unitKey: 'num:compare', stage: stage),
        )!;
        // Assert
        expect(actual.questionTypeIds, contains(QuestionTypeIds.compare));
      }
    });
    test('reviews the units of its own domain only', () {
      // Act
      final QuizSpec actual = specs.specOf(
        domain: numbers,
        source: const StageSource(
          unitKey: 'review:numbers:1',
          stage: StageKind.review,
        ),
      )!;
      // Assert
      expect(actual.itemKeys, hasLength(30));
      expect(actual.itemKeys.last, 'num:tens:100');
      expect(
        specs.specOf(
          domain: numbers,
          source: const StageSource(
            unitKey: 'review:1',
            stage: StageKind.review,
          ),
        ),
        isNull,
      );
    });
    test('fights a boss per unit, then on the units seen before', () {
      // Act
      final QuizSpec actualFirst = specs.specOf(
        domain: numbers,
        source: const StageSource(
          unitKey: 'num:count10',
          stage: StageKind.boss,
        ),
      )!;
      final QuizSpec actualFifth = specs.specOf(
        domain: numbers,
        source: const StageSource(
          unitKey: 'num:compare',
          stage: StageKind.boss,
        ),
      )!;
      // Assert
      expect(actualFirst.isBossFight, isTrue);
      expect(actualFirst.followUpItemKeys, actualFirst.itemKeys);
      expect(actualFifth.followUpItemKeys, hasLength(40));
      expect(actualFifth.followUpItemKeys.first, 'num:count:1');
    });
  });
}
