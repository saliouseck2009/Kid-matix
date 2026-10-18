import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/addition/domain/services/addition_domain.dart';
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
    domainId: 'addition',
    unitKey: unitKey,
    stage: stage,
    bestStars: stars,
    bestScore: 10,
    completedAt: DateTime(2026, 10, 18),
  );
}

void main() {
  final AdditionDomain addition = AdditionDomain();
  final DomainRegistry domains = DomainRegistry()
    ..register(MultiplicationDomain())
    ..register(NumbersDomain())
    ..register(addition);
  const StageQuizSpecs specs = StageQuizSpecs();

  group('the path of the additions and subtractions', () {
    test('has 15 units and a review after every group of 3', () {
      // Act
      final LearningPathEntity actual = const LearningPathBuilder().build(
        domainId: 'addition',
        units: addition.path,
        progress: <StageProgressEntity>[
          _stars('addsub:add5', StageKind.writing, 2),
        ],
        isEverythingUnlocked: false,
      );
      // Assert
      expect(actual.tables, hasLength(15));
      expect(
        actual.nodes.whereType<ReviewPathNode>().map(
          (ReviewPathNode review) => review.unitKey,
        ),
        <String>[
          'review:addition:1',
          'review:addition:2',
          'review:addition:3',
          'review:addition:4',
          'review:addition:5',
        ],
      );
      expect(actual.tables[0].status, TableStatus.done);
      expect(actual.tables[1].status, TableStatus.current);
      expect(actual.tables[2].status, TableStatus.locked);
    });
    test('finds the domain of its units and of its reviews', () {
      // Arrange
      const UnitDomainResolver resolver = UnitDomainResolver();
      // Assert
      expect(
        resolver.domainOf(domains: domains, unitKey: 'addsub:carry')?.id,
        'addition',
      );
      expect(
        resolver.domainOf(domains: domains, unitKey: 'review:addition:2')?.id,
        'addition',
      );
      expect(
        ReviewKey.tryParse('review:addition:3'),
        const ReviewKey(domainId: 'addition', number: 3),
      );
    });
    test('discovers a unit with its facts in order, to pick', () {
      // Act
      final QuizSpec actual = specs.specOf(
        domain: addition,
        source: const StageSource(
          unitKey: 'addsub:add12',
          stage: StageKind.discovery,
        ),
      )!;
      // Assert
      expect(actual.domainId, 'addition');
      expect(actual.selection, QuizSelection.inOrder);
      expect(actual.itemKeys.first, 'add:2+9');
      expect(actual.itemKeys, hasLength(15));
      expect(actual.questionTypeIds, contains(QuestionTypeIds.multipleChoice));
      expect(actual.sourceKey, 'path:addsub:add12:discovery');
    });
    test('writes the answers at stage 3 and times the speed stage', () {
      // Act
      final QuizSpec actualWriting = specs.specOf(
        domain: addition,
        source: const StageSource(
          unitKey: 'addsub:borrow',
          stage: StageKind.writing,
        ),
      )!;
      final QuizSpec actualSpeed = specs.specOf(
        domain: addition,
        source: const StageSource(
          unitKey: 'addsub:borrow',
          stage: StageKind.speed,
        ),
      )!;
      // Assert
      expect(
        actualWriting.questionTypeIds,
        contains(QuestionTypeIds.typedAnswer),
      );
      expect(actualSpeed.baseTimeLimit, const Duration(seconds: 10));
    });
    test('reviews the units of its own domain only', () {
      // Act
      final QuizSpec actual = specs.specOf(
        domain: addition,
        source: const StageSource(
          unitKey: 'review:addition:1',
          stage: StageKind.review,
        ),
      )!;
      // Assert
      expect(actual.itemKeys, hasLength(10 + 14 + 9));
      expect(
        actual.itemKeys.every((String key) => key.startsWith('add:')),
        isTrue,
      );
    });
    test('fights a boss per unit, then on the units seen before', () {
      // Act
      final QuizSpec actualFirst = specs.specOf(
        domain: addition,
        source: const StageSource(
          unitKey: 'addsub:add5',
          stage: StageKind.boss,
        ),
      )!;
      final QuizSpec actualFourth = specs.specOf(
        domain: addition,
        source: const StageSource(
          unitKey: 'addsub:sub5',
          stage: StageKind.boss,
        ),
      )!;
      // Assert
      expect(actualFirst.isBossFight, isTrue);
      expect(actualFirst.baseTimeLimit, const Duration(seconds: 8));
      expect(actualFirst.followUpItemKeys, actualFirst.itemKeys);
      expect(actualFourth.followUpItemKeys.first, 'add:1+1');
      expect(actualFourth.followUpItemKeys, hasLength(10 + 14 + 9));
    });
  });
}
