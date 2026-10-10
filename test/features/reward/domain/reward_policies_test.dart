import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_facts.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_key.dart';
import 'package:kid_matix/features/reward/domain/entities/player_level.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/xp_gain.dart';
import 'package:kid_matix/features/reward/domain/services/badge_evaluator.dart';
import 'package:kid_matix/features/reward/domain/services/level_policy.dart';
import 'package:kid_matix/features/reward/domain/services/streak_policy.dart';
import 'package:kid_matix/features/reward/domain/services/xp_policy.dart';

const XpPolicy _xp = XpPolicy();
const LevelPolicy _levels = LevelPolicy();
const StreakPolicy _streaks = StreakPolicy();
const BadgeEvaluator _badges = BadgeEvaluator();

/// Saturday 10 October 2026, evening.
final DateTime _saturday = DateTime(2026, 10, 10, 18);

StreakEntity _streak(int current, DateTime lastPlayed, {DateTime? jokerWeek}) {
  return StreakEntity(
    current: current,
    best: current,
    lastPlayedDay: StreakPolicy.dayOf(lastPlayed),
    jokerUsedWeek: jokerWeek,
  );
}

BadgeFacts _facts({
  bool isStageCompleted = false,
  bool isPerfectStage = false,
  int lightning = 0,
  int streak = 0,
  Set<String> crowned = const <String>{},
  int mastered = 0,
}) {
  return BadgeFacts(
    isStageCompleted: isStageCompleted,
    isPerfectStage: isPerfectStage,
    lightningAnswerCount: lightning,
    streak: streak,
    crownedUnitKeys: crowned,
    masteredItemCount: mastered,
    itemCount: 120,
  );
}

void main() {
  group('XpPolicy', () {
    test('gives 10 per right answer, 5 more per lightning, 20 per quiz', () {
      // Act
      final XpGain actualGain = _xp.gainOf(
        isCompleted: true,
        correctCount: 8,
        lightningCount: 3,
        questionCount: 10,
      );
      // Assert
      expect(actualGain.answers, 80);
      expect(actualGain.lightning, 15);
      expect(actualGain.completion, 20);
      expect(actualGain.perfect, 0);
      expect(actualGain.total, 115);
    });
    test('adds 50 for a perfect quiz', () {
      // Act
      final XpGain actualGain = _xp.gainOf(
        isCompleted: true,
        correctCount: 10,
        lightningCount: 0,
        questionCount: 10,
      );
      // Assert
      expect(actualGain.total, 100 + 20 + 50);
    });
    test('gives nothing to an abandoned quiz', () {
      // Act
      final XpGain actualGain = _xp.gainOf(
        isCompleted: false,
        correctCount: 5,
        lightningCount: 2,
        questionCount: 5,
      );
      // Assert
      expect(actualGain, const XpGain.none());
      expect(XpPolicy.version, 1);
    });
  });

  group('LevelPolicy', () {
    final Map<int, PlayerLevel> expectedLevels = <int, PlayerLevel>{
      0: const PlayerLevel(level: 1, xpIntoLevel: 0, xpForNextLevel: 100),
      99: const PlayerLevel(level: 1, xpIntoLevel: 99, xpForNextLevel: 100),
      100: const PlayerLevel(level: 2, xpIntoLevel: 0, xpForNextLevel: 200),
      299: const PlayerLevel(level: 2, xpIntoLevel: 199, xpForNextLevel: 200),
      300: const PlayerLevel(level: 3, xpIntoLevel: 0, xpForNextLevel: 300),
      930: const PlayerLevel(level: 4, xpIntoLevel: 330, xpForNextLevel: 400),
      1000: const PlayerLevel(level: 5, xpIntoLevel: 0, xpForNextLevel: 500),
    };
    for (final MapEntry<int, PlayerLevel> entry in expectedLevels.entries) {
      test('puts ${entry.key} XP at ${entry.value}', () {
        // Act
        final PlayerLevel actualLevel = _levels.levelOf(entry.key);
        // Assert
        expect(actualLevel, entry.value);
      });
    }
    test('tells the XP missing for the next level', () {
      // Act
      final PlayerLevel actualLevel = _levels.levelOf(930);
      // Assert
      expect(actualLevel.xpToNextLevel, 70);
      expect(actualLevel.progress, closeTo(0.825, 0.001));
    });
  });

  group('StreakPolicy', () {
    test('starts at 1 with the first completed quiz', () {
      // Act
      final StreakEntity actualStreak = _streaks.afterQuiz(
        streak: const StreakEntity.empty(),
        now: _saturday,
      );
      // Assert
      expect(actualStreak.current, 1);
      expect(actualStreak.best, 1);
      expect(actualStreak.lastPlayedDay, DateTime(2026, 10, 10));
    });
    test('adds a day the next day, nothing the same day', () {
      // Arrange
      final StreakEntity inputStreak = _streak(3, DateTime(2026, 10, 9, 8));
      // Act
      final StreakEntity actualNextDay = _streaks.afterQuiz(
        streak: inputStreak,
        now: _saturday,
      );
      final StreakEntity actualSameDay = _streaks.afterQuiz(
        streak: actualNextDay,
        now: _saturday.add(const Duration(hours: 2)),
      );
      // Assert
      expect(actualNextDay.current, 4);
      expect(actualSameDay, actualNextDay);
    });
    test('saves the streak with the joker after one missed day', () {
      // Arrange
      final StreakEntity inputStreak = _streak(5, DateTime(2026, 10, 8));
      // Act
      final StreakEntity actualStreak = _streaks.afterQuiz(
        streak: inputStreak,
        now: _saturday,
      );
      // Assert
      expect(actualStreak.current, 6);
      expect(actualStreak.jokerUsedWeek, DateTime(2026, 10, 5));
    });
    test('loses the streak after a missed day once the joker is used', () {
      // Arrange
      final StreakEntity inputStreak = _streak(
        5,
        DateTime(2026, 10, 8),
        jokerWeek: DateTime(2026, 10, 5),
      );
      // Act
      final StreakEntity actualStreak = _streaks.afterQuiz(
        streak: inputStreak,
        now: _saturday,
      );
      // Assert
      expect(actualStreak.current, 1);
      expect(actualStreak.best, 5);
    });
    test('gives a new joker on Monday', () {
      // Arrange
      final StreakEntity inputStreak = _streak(
        5,
        DateTime(2026, 10, 10),
        jokerWeek: DateTime(2026, 10, 5),
      );
      // Act
      final StreakEntity actualStreak = _streaks.afterQuiz(
        streak: inputStreak,
        now: DateTime(2026, 10, 12, 17),
      );
      // Assert
      expect(actualStreak.current, 6);
      expect(actualStreak.jokerUsedWeek, DateTime(2026, 10, 12));
    });
    test('loses the streak after two missed days', () {
      // Arrange
      final StreakEntity inputStreak = _streak(9, DateTime(2026, 10, 7));
      // Act
      final StreakEntity actualStreak = _streaks.afterQuiz(
        streak: inputStreak,
        now: _saturday,
      );
      // Assert
      expect(actualStreak.current, 1);
      expect(actualStreak.best, 9);
    });
    test('changes nothing when the date goes back', () {
      // Arrange
      final StreakEntity inputStreak = _streak(4, DateTime(2026, 10, 10));
      // Act
      final StreakEntity actualStreak = _streaks.afterQuiz(
        streak: inputStreak,
        now: DateTime(2026, 10, 6, 9),
      );
      // Assert
      expect(actualStreak, inputStreak);
    });
    test('shows a streak still alive, and 0 once lost', () {
      // Arrange
      final StreakEntity inputStreak = _streak(
        4,
        DateTime(2026, 10, 7),
        jokerWeek: DateTime(2026, 10, 5),
      );
      // Act
      final int actualYesterday = _streaks.currentAt(
        streak: _streak(4, DateTime(2026, 10, 9)),
        now: _saturday,
      );
      final int actualSavable = _streaks.currentAt(
        streak: _streak(4, DateTime(2026, 10, 8)),
        now: _saturday,
      );
      final int actualLost = _streaks.currentAt(
        streak: inputStreak,
        now: _saturday,
      );
      // Assert
      expect(actualYesterday, 4);
      expect(actualSavable, 4);
      expect(actualLost, 0);
      expect(
        _streaks.isJokerAvailable(streak: inputStreak, now: _saturday),
        isFalse,
      );
    });
    test('finds the Monday of a week', () {
      // Assert
      expect(
        StreakPolicy.mondayOf(DateTime(2026, 10, 11)),
        DateTime(2026, 10, 5),
      );
      expect(
        StreakPolicy.mondayOf(DateTime(2026, 10, 12)),
        DateTime(2026, 10, 12),
      );
      expect(
        StreakPolicy.mondayOf(DateTime(2026, 11, 1)),
        DateTime(2026, 10, 26),
      );
    });
  });

  group('BadgeEvaluator', () {
    final Map<String, (BadgeFacts, String)> inputCases =
        <String, (BadgeFacts, String)>{
          'Premier pas': (_facts(isStageCompleted: true), BadgeKey.firstStep),
          'Sans-faute': (
            _facts(isStageCompleted: true, isPerfectStage: true),
            BadgeKey.perfect,
          ),
          'Éclair': (_facts(lightning: 20), BadgeKey.lightning),
          'Régulier': (_facts(streak: 7), BadgeKey.regular),
          'Dompteur de la table de 7': (
            _facts(crowned: <String>{'mul:7'}),
            'tamer:mul:7',
          ),
          'Les 120': (_facts(mastered: 120), BadgeKey.allFacts),
        };
    for (final MapEntry<String, (BadgeFacts, String)> entry
        in inputCases.entries) {
      test('unlocks ${entry.key}', () {
        // Act
        final List<String> actualBadges = _badges.newBadges(
          facts: entry.value.$1,
          unlocked: const <String>{},
        );
        // Assert
        expect(actualBadges, contains(entry.value.$2));
      });
    }
    test('unlocks nothing below the thresholds', () {
      // Act
      final List<String> actualBadges = _badges.newBadges(
        facts: _facts(lightning: 19, streak: 6, mastered: 119),
        unlocked: const <String>{},
      );
      // Assert
      expect(actualBadges, isEmpty);
    });
    test('never unlocks a badge twice', () {
      // Act
      final List<String> actualBadges = _badges.newBadges(
        facts: _facts(isStageCompleted: true, crowned: <String>{'mul:1'}),
        unlocked: <String>{BadgeKey.firstStep, 'tamer:mul:1'},
      );
      // Assert
      expect(actualBadges, isEmpty);
    });
    test('reads the unit of a tamer badge', () {
      // Assert
      expect(BadgeKey.unitOfTamer('tamer:mul:7'), 'mul:7');
      expect(BadgeKey.unitOfTamer(BadgeKey.regular), isNull);
    });
  });
}
