import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_key.dart';
import 'package:kid_matix/features/reward/domain/entities/session_reward_input.dart';
import 'package:kid_matix/features/reward/domain/entities/session_reward_outcome.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/services/session_reward_calculator.dart';

SessionRewardInput _input({
  bool isCompleted = true,
  int correct = 9,
  bool isTimeAttack = false,
}) {
  return SessionRewardInput(
    isCompleted: isCompleted,
    correctCount: correct,
    questionCount: isTimeAttack ? correct : 10,
    lightningCount: 4,
    isStage: !isTimeAttack,
    crownedUnitKey: isTimeAttack ? null : 'mul:5',
    masteredItemCount: 0,
    itemCount: 120,
    now: DateTime(2026, 10, 10, 18),
    isTimeAttack: isTimeAttack,
  );
}

void main() {
  const SessionRewardCalculator calculator = SessionRewardCalculator();

  group('SessionRewardCalculator', () {
    test('adds the XP, the streak, the counters and the badges', () {
      // Act
      final SessionRewardOutcome actualOutcome = calculator.calculate(
        input: _input(),
        totalXp: 250,
        streak: const StreakEntity.empty(),
        lightningAnswers: 17,
        unlocked: <String>{BadgeKey.firstStep},
      );
      // Assert
      expect(actualOutcome.xp.total, 90 + 20 + 20);
      expect(actualOutcome.totalXp, 380);
      expect(actualOutcome.level.level, 3);
      expect(actualOutcome.streak.current, 1);
      expect(actualOutcome.lightningAnswers, 21);
      expect(actualOutcome.newBadges, <String>[
        BadgeKey.lightning,
        'tamer:mul:5',
      ]);
    });
    test('changes nothing for an abandoned quiz', () {
      // Arrange
      const StreakEntity inputStreak = StreakEntity(current: 3, best: 3);
      // Act
      final SessionRewardOutcome actualOutcome = calculator.calculate(
        input: _input(isCompleted: false),
        totalXp: 250,
        streak: inputStreak,
        lightningAnswers: 17,
        unlocked: const <String>{},
      );
      // Assert
      expect(actualOutcome.xp.total, 0);
      expect(actualOutcome.totalXp, 250);
      expect(actualOutcome.streak, inputStreak);
      expect(actualOutcome.lightningAnswers, 17);
      expect(actualOutcome.newBadges, isEmpty);
    });
    test('unlocks Sprinter with 20 right answers in a time attack', () {
      // Act
      final List<String> actualBadges = <String>[
        for (final int inputScore in <int>[19, 20])
          ...calculator
              .calculate(
                input: _input(correct: inputScore, isTimeAttack: true),
                totalXp: 0,
                streak: const StreakEntity.empty(),
                lightningAnswers: 0,
                unlocked: const <String>{},
              )
              .newBadges,
      ];
      // Assert
      expect(actualBadges, <String>[BadgeKey.sprinter]);
    });
    test('gives no Sprinter for 20 right answers outside a time attack', () {
      // Act
      final SessionRewardOutcome actualOutcome = calculator.calculate(
        input: _input(correct: 20),
        totalXp: 0,
        streak: const StreakEntity.empty(),
        lightningAnswers: 0,
        unlocked: const <String>{},
      );
      // Assert
      expect(actualOutcome.newBadges, isNot(contains(BadgeKey.sprinter)));
    });
  });
}
