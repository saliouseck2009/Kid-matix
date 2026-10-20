import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/placement_level.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_challenge.dart';
import 'package:kid_matix/features/classroom/domain/entities/classroom_rules.dart';
import 'package:kid_matix/features/classroom/domain/entities/item_standing.dart';
import 'package:kid_matix/features/classroom/domain/entities/level_group.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_answer.dart';
import 'package:kid_matix/features/classroom/domain/entities/practice_session.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';
import 'package:kid_matix/features/classroom/domain/services/class_challenge_rule.dart';
import 'package:kid_matix/features/classroom/domain/services/item_standing_rule.dart';
import 'package:kid_matix/features/classroom/domain/services/level_group_rule.dart';

const PupilEntity _pupil = PupilEntity(
  classroomId: 'c',
  player: PlayerIdentity(
    id: 'p',
    nickname: '01',
    avatarKey: 'avatar1',
    colorKey: 'violet',
  ),
);

void main() {
  group('ClassroomRules', () {
    test('reads one nickname per line, without empty lines', () {
      // Act
      final List<String> actual = ClassroomRules.parseNicknames(
        ' Awa \r\n\nMoussa\n  \nFatou',
      );
      // Assert
      expect(actual, <String>['Awa', 'Moussa', 'Fatou']);
    });

    test('numbers pupils on two digits after the existing ones', () {
      // Act
      final List<String> actual = ClassroomRules.numberNicknames(
        count: 3,
        existingCount: 8,
      );
      // Assert
      expect(actual, <String>['09', '10', '11']);
    });

    test('accepts a 4-digit teacher code only', () {
      // Assert
      expect(ClassroomRules.isTeacherCode('0427'), isTrue);
      expect(ClassroomRules.isTeacherCode('427'), isFalse);
      expect(ClassroomRules.isTeacherCode('04a7'), isFalse);
      expect(ClassroomRules.isTeacherCode('04277'), isFalse);
    });

    test('cleans a class name and refuses an empty or long one', () {
      // Assert
      expect(ClassroomRules.cleanName('  CE1 B '), 'CE1 B');
      expect(ClassroomRules.cleanName('   '), isNull);
      expect(ClassroomRules.cleanName('x' * 25), isNull);
    });
  });

  group('ItemStandingRule', () {
    test('reads the last three answers of an item', () {
      // Assert
      expect(
        ItemStandingRule.standingOf(<bool>[false, false, true, true, true]),
        ItemStanding.acquired,
      );
      expect(
        ItemStandingRule.standingOf(<bool>[true, true, false, true, false]),
        ItemStanding.struggling,
      );
      expect(
        ItemStandingRule.standingOf(<bool>[true, true]),
        ItemStanding.learning,
      );
      expect(
        ItemStandingRule.standingOf(<bool>[false, true, true]),
        ItemStanding.learning,
      );
    });

    test('orders the sessions and leaves the second chances out', () {
      // Arrange
      final List<PracticeSession> inputSessions = <PracticeSession>[
        PracticeSession(
          id: 'late',
          pupilId: 'p',
          classroomId: 'c',
          domainId: 'addition',
          startedAt: DateTime(2026, 10, 21),
          duration: Duration.zero,
          questionCount: 1,
          correctCount: 0,
          answers: const <PracticeAnswer>[
            PracticeAnswer(position: 1, itemKey: 'k', isCorrect: false),
            PracticeAnswer(
              position: 2,
              itemKey: 'k',
              isCorrect: true,
              isRetry: true,
            ),
          ],
        ),
        PracticeSession(
          id: 'early',
          pupilId: 'p',
          classroomId: 'c',
          domainId: 'addition',
          startedAt: DateTime(2026, 10, 20),
          duration: Duration.zero,
          questionCount: 1,
          correctCount: 1,
          answers: const <PracticeAnswer>[
            PracticeAnswer(position: 1, itemKey: 'k', isCorrect: true),
          ],
        ),
      ];
      // Act
      final Map<String, List<bool>> actual = ItemStandingRule.resultsByItem(
        inputSessions,
      );
      // Assert
      expect(actual, <String, List<bool>>{
        'k': <bool>[true, false],
      });
    });
  });

  group('LevelGroupRule', () {
    test('takes the placement when it goes further than the mastery', () {
      // Arrange
      const PupilProgress inputProgress = PupilProgress(pupil: _pupil);
      // Act
      final LevelGroupKind actual = LevelGroupRule.kindOf(
        progress: inputProgress,
        classItemKeys: const <String>{'a', 'b', 'c'},
        placement: PlacementLevel(
          acquiredUnitCount: 9,
          unitCount: 12,
          takenAt: DateTime(2026, 10, 1),
        ),
      );
      // Assert
      expect(actual, LevelGroupKind.confident);
    });

    test('puts a pupil without placement nor answer apart', () {
      // Act
      final LevelGroupKind actual = LevelGroupRule.kindOf(
        progress: const PupilProgress(pupil: _pupil),
        classItemKeys: const <String>{'a'},
      );
      // Assert
      expect(actual, LevelGroupKind.notYet);
    });

    test('splits the mastery of the class items in thirds', () {
      // Arrange
      const Set<String> inputItems = <String>{'a', 'b', 'c'};
      PupilProgress progressOf(Set<String> acquired) => PupilProgress(
        pupil: _pupil,
        sessionCount: 1,
        answeredItemKeys: inputItems,
        acquiredItemKeys: acquired,
      );
      // Act
      LevelGroupKind kindOf(Set<String> acquired) => LevelGroupRule.kindOf(
        progress: progressOf(acquired),
        classItemKeys: inputItems,
      );
      // Assert
      expect(kindOf(const <String>{}), LevelGroupKind.firstSteps);
      expect(kindOf(const <String>{'a'}), LevelGroupKind.onTheWay);
      expect(kindOf(const <String>{'a', 'b'}), LevelGroupKind.confident);
    });
  });

  group('Edges', () {
    PracticeSession sessionOf(String id, DateTime start, List<bool> results) {
      return PracticeSession(
        id: id,
        pupilId: 'p',
        classroomId: 'c',
        domainId: 'multiplication',
        startedAt: start,
        duration: Duration.zero,
        questionCount: results.length,
        correctCount: results.where((bool r) => r).length,
        answers: <PracticeAnswer>[
          for (int index = 0; index < results.length; index++)
            PracticeAnswer(
              position: index + 1,
              itemKey: 'k',
              isCorrect: results[index],
            ),
        ],
      );
    }

    test('a session on Sunday 23:59 counts for the week before', () {
      // Act
      final ClassChallenge actual = ClassChallengeRule.compute(
        goal: 100,
        sessions: <PracticeSession>[
          sessionOf('sunday', DateTime(2026, 10, 25, 23, 59), <bool>[true]),
          sessionOf('monday', DateTime(2026, 10, 26), <bool>[true, true]),
        ],
        now: DateTime(2026, 10, 26, 8),
      );
      // Assert
      expect(actual.correctCount, 2);
    });

    test('two sessions started together keep the order of their ids', () {
      // Arrange
      final DateTime inputStart = DateTime(2026, 10, 21, 9);
      final List<PracticeSession> input = <PracticeSession>[
        sessionOf('b', inputStart, <bool>[true, true, true]),
        sessionOf('a', inputStart, <bool>[false, false]),
      ];
      // Act
      final Map<String, ItemStanding> actual = ItemStandingRule.standingsOf(
        input,
      );
      final Map<String, ItemStanding> actualReversed =
          ItemStandingRule.standingsOf(input.reversed);
      // Assert
      expect(actual, <String, ItemStanding>{'k': ItemStanding.acquired});
      expect(actualReversed, actual);
    });
  });

  group('ClassChallenge', () {
    test('caps the gauge at the goal', () {
      // Arrange
      final ClassChallenge input = ClassChallenge(
        goal: 500,
        correctCount: 640,
        weekStart: DateTime(2026, 10, 19),
      );
      // Assert
      expect(input.progress, 1);
      expect(input.isReached, isTrue);
    });

    test('starts the week on Monday at midnight', () {
      // Assert
      expect(
        ClassChallengeRule.weekStartOf(DateTime(2026, 10, 25, 23, 59)),
        DateTime(2026, 10, 19),
      );
      expect(
        ClassChallengeRule.weekStartOf(DateTime(2026, 10, 26)),
        DateTime(2026, 10, 26),
      );
    });
  });
}
