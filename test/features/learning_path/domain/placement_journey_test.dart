import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_journey.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_level.dart';

/// Answers each question of [journey] with the next value of [answers],
/// right when `true`, until the answers or the journey run out.
PlacementJourney play(PlacementJourney journey, List<bool> answers) {
  PlacementJourney current = journey;
  for (final bool isCorrect in answers) {
    if (current.isOver) break;
    current = current.answered(isCorrect: isCorrect);
  }
  return current;
}

DomainLevel levelOf(PlacementOutcome outcome, String domainId) {
  return outcome.domains.singleWhere((DomainLevel l) => l.domainId == domainId);
}

void main() {
  group('PlacementJourney', () {
    test('starts with the easy typical question of the numbers', () {
      // Act
      final PlacementJourney actualJourney = PlacementJourney.start();
      // Assert
      expect(actualJourney.skill!.id, SkillId.numbers);
      expect(actualJourney.probeUnitKey, 'num:count20');
      expect(actualJourney.unitKeysToOpen, <String>[
        'num:count10',
        'num:count20',
      ]);
      expect(actualJourney.isOver, isFalse);
      expect(actualJourney.answeredCount, 0);
      expect(actualJourney.maxQuestionCount, 15);
    });

    test('climbs to every skill while all the answers are right', () {
      // Act
      final PlacementJourney actualJourney = play(
        PlacementJourney.start(),
        List<bool>.filled(15, true),
      );
      // Assert
      expect(actualJourney.isOver, isTrue);
      expect(actualJourney.answeredCount, 15);
      expect(actualJourney.skill, isNull);
      final PlacementOutcome actualOutcome = actualJourney.outcome;
      expect(actualOutcome.isEverythingAcquired, isTrue);
      expect(actualOutcome.recommendedUnitKey, isNull);
      expect(
        actualOutcome.domains.map((DomainLevel l) => l.level),
        <int>[1, 2, 1, 1],
      );
      expect(
        actualOutcome.domains.every((DomainLevel l) => l.isComplete),
        isTrue,
      );
    });

    test('stops at the first skill not acquired and asks nothing after', () {
      // Act: the numbers are right, then two wrong answers on the addition,
      // then answers the journey must not ask for.
      final PlacementJourney actualJourney = play(
        PlacementJourney.start(),
        <bool>[true, true, true, false, false, true, true, true, true],
      );
      // Assert
      expect(actualJourney.isOver, isTrue);
      expect(actualJourney.answeredCount, 5);
      final PlacementOutcome actualOutcome = actualJourney.outcome;
      expect(actualOutcome.skills.map((SkillResult r) => r.skillId), <SkillId>[
        SkillId.numbers,
        SkillId.addition,
      ]);
      expect(actualOutcome.skills.last.isAcquired, isFalse);
      expect(levelOf(actualOutcome, 'multiplication').level, isNull);
      expect(levelOf(actualOutcome, 'division').level, isNull);
      expect(levelOf(actualOutcome, 'multiplication').isChecked, isFalse);
      expect(levelOf(actualOutcome, 'addition').isChecked, isTrue);
    });

    test('starts a child who counts but cannot add on the first addition', () {
      // Act
      final PlacementOutcome actualOutcome = play(
        PlacementJourney.start(),
        <bool>[true, true, true, false, false],
      ).outcome;
      // Assert
      expect(levelOf(actualOutcome, 'numbers').level, 1);
      expect(levelOf(actualOutcome, 'addition').level, 0);
      expect(actualOutcome.recommendedDomainId, 'addition');
      expect(actualOutcome.recommendedUnitKey, 'addsub:add5');
      expect(
        levelOf(actualOutcome, 'addition').openedUnitKeys,
        isEmpty,
      );
      expect(
        levelOf(actualOutcome, 'numbers').openedUnitKeys,
        containsAll(<String>['num:count10', 'num:order']),
      );
    });

    test('asks the third question only when the skill is still open', () {
      // Act
      final PlacementJourney afterOneMiss = play(
        PlacementJourney.start(),
        <bool>[false],
      );
      final PlacementJourney afterTwoMisses = afterOneMiss.answered(
        isCorrect: false,
      );
      // Assert
      expect(afterOneMiss.probeUnitKey, 'num:tensones');
      expect(afterTwoMisses.isOver, isTrue);
      expect(afterTwoMisses.answeredCount, 2);
    });

    test('forgives one slip: wrong, right, right still climbs', () {
      // Act
      final PlacementJourney actualJourney = play(
        PlacementJourney.start(),
        <bool>[false, true, true],
      );
      // Assert
      expect(actualJourney.isOver, isFalse);
      expect(actualJourney.skill!.id, SkillId.addition);
      expect(actualJourney.results.single.isAcquired, isTrue);
      expect(actualJourney.results.single.rightCount, 2);
      expect(actualJourney.results.single.wrongCount, 1);
    });

    test('opens the units up to the hardest question answered right', () {
      // Act: the numbers are right, then the easy and the medium additions
      // right and the hard one wrong, so the addition is acquired.
      final PlacementOutcome actualOutcome = play(
        PlacementJourney.start(),
        <bool>[true, true, true, true, true, false, false, false],
      ).outcome;
      // Assert
      expect(levelOf(actualOutcome, 'addition').level, 1);
      expect(levelOf(actualOutcome, 'addition').openedUnitKeys, <String>[
        'addsub:add5',
        'addsub:add7',
        'addsub:add9',
        'addsub:toten',
      ]);
      expect(actualOutcome.recommendedDomainId, 'addition');
      expect(actualOutcome.recommendedUnitKey, 'addsub:sub5');
    });

    test('recommends the first unit not opened of the skill missed', () {
      // Act: the numbers and the addition are right, the easy subtraction
      // is right, the next two are wrong.
      final PlacementOutcome actualOutcome = play(
        PlacementJourney.start(),
        <bool>[true, true, true, true, true, true, true, false, false],
      ).outcome;
      // Assert
      expect(actualOutcome.skills.last.skillId, SkillId.subtraction);
      expect(actualOutcome.recommendedDomainId, 'addition');
      expect(actualOutcome.recommendedUnitKey, 'addsub:sub7');
    });

    test('ignores an answer once it is over', () {
      // Arrange
      final PlacementJourney inputJourney = play(
        PlacementJourney.start(),
        <bool>[false, false],
      );
      // Act
      final PlacementJourney actualJourney = inputJourney.answered(
        isCorrect: true,
      );
      // Assert
      expect(identical(actualJourney, inputJourney), isTrue);
      expect(inputJourney.unitKeysToOpen, isEmpty);
      expect(inputJourney.probeUnitKey, isNull);
    });

    test('right, wrong, wrong misses the skill and keeps the first units', () {
      // Act
      final PlacementJourney actualJourney = play(
        PlacementJourney.start(),
        <bool>[true, false, false],
      );
      // Assert
      expect(actualJourney.isOver, isTrue);
      expect(actualJourney.results.single.isAcquired, isFalse);
      expect(actualJourney.openedUnitKeys, <String>[
        'num:count10',
        'num:count20',
      ]);
      expect(actualJourney.outcome.recommendedUnitKey, 'num:count100');
    });

    test('right, right still asks the third question', () {
      // Act
      final PlacementJourney actualJourney = play(
        PlacementJourney.start(),
        <bool>[true, true],
      );
      // Assert
      expect(actualJourney.isOver, isFalse);
      expect(actualJourney.probeUnitKey, 'num:order');
      expect(actualJourney.unitKeysToOpen, <String>[
        'num:count10',
        'num:count20',
        'num:count100',
        'num:tensones',
        'num:compare',
        'num:order',
      ]);
    });

    test('a right answer after a slip opens its own unit only', () {
      // Act
      final PlacementJourney actualJourney = play(
        PlacementJourney.start(),
        <bool>[false, true],
      );
      // Assert
      expect(actualJourney.probeUnitKey, 'num:order');
      expect(actualJourney.unitKeysToOpen, <String>['num:order']);
      expect(
        actualJourney.answered(isCorrect: true).openedUnitKeys,
        <String>['num:tensones', 'num:order'],
      );
    });
  });
}
