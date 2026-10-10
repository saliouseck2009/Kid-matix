import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/entities/session_rewards_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/xp_gain.dart';

/// Checks that [build] gives equal values for the same input and that
/// [other] differs.
void _expectValueEquality(Object Function() build, Object other) {
  // Arrange
  final Object inputValue = build();
  final Object expectedValue = build();
  // Act
  final bool actualIsEqual = inputValue == expectedValue;
  final bool actualIsOtherEqual = inputValue == other;
  // Assert
  expect(actualIsEqual, isTrue);
  expect(inputValue.hashCode, expectedValue.hashCode);
  expect(actualIsOtherEqual, isFalse);
}

void main() {
  test('BadgeUnlockEntity compares by value', () {
    _expectValueEquality(
      () => BadgeUnlockEntity(
        badgeKey: 'perfect',
        unlockedAt: DateTime(2026, 10, 10),
        sessionId: 's1',
      ),
      BadgeUnlockEntity(
        badgeKey: 'perfect',
        unlockedAt: DateTime(2026, 10, 10),
      ),
    );
  });

  test('StreakEntity compares by value', () {
    _expectValueEquality(
      () => StreakEntity(
        current: 3,
        best: 5,
        lastPlayedDay: DateTime(2026, 10, 10),
        jokerUsedWeek: DateTime(2026, 10, 5),
      ),
      const StreakEntity.empty(),
    );
  });

  test('StreakEntity describes itself', () {
    // Arrange
    final StreakEntity inputStreak = StreakEntity(
      current: 3,
      best: 5,
      lastPlayedDay: DateTime(2026, 10, 10),
    );
    // Act
    final String actualText = inputStreak.toString();
    // Assert
    expect(actualText, startsWith('streak 3 (best 5'));
  });

  test('XpGain compares by value and adds its parts', () {
    _expectValueEquality(
      () => const XpGain(answers: 10, lightning: 2, completion: 5, perfect: 5),
      const XpGain.none(),
    );
    expect(
      const XpGain(answers: 10, lightning: 2, completion: 5, perfect: 5).total,
      22,
    );
  });

  test('PlayerLevel compares by value', () {
    _expectValueEquality(
      () => const PlayerLevel(level: 2, xpIntoLevel: 10, xpForNextLevel: 100),
      const PlayerLevel(level: 3, xpIntoLevel: 10, xpForNextLevel: 100),
    );
  });

  test('SessionRewardsEntity.none brings no XP and no level up', () {
    // Arrange
    const PlayerLevel inputLevel = PlayerLevel(
      level: 2,
      xpIntoLevel: 10,
      xpForNextLevel: 100,
    );
    // Act
    // ignore: prefer_const_constructors, the runtime constructor is measured.
    final SessionRewardsEntity actualRewards = SessionRewardsEntity.none(
      level: inputLevel,
    );
    // Assert
    expect(actualRewards.xpEarned, 0);
    expect(actualRewards.newBadges, isEmpty);
    expect(actualRewards.isLevelUp, isFalse);
  });
}
