import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_quiz_specs.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../../quiz/helpers/quiz_fixtures.dart';

void main() {
  final LearningDomain domain = MultiplicationDomain();

  group('ChallengeSource', () {
    test('writes and reads a free training', () {
      // Arrange
      final TrainingSource inputSource = TrainingSource(
        unitKeys: const <String>['mul:2', 'mul:5'],
        questionCount: 20,
        hasTimer: true,
      );
      // Act
      final String actualKey = inputSource.toKey();
      final ChallengeSource? actualSource = ChallengeSource.tryParse(actualKey);
      // Assert
      expect(actualKey, 'training:20:timer:mul:2+mul:5');
      expect(actualSource, inputSource);
    });
    test('reads a training without timer', () {
      // Act
      final ChallengeSource? actualSource = ChallengeSource.tryParse(
        'training:10:free:mul:7',
      );
      // Assert
      expect(
        actualSource,
        TrainingSource(
          unitKeys: const <String>['mul:7'],
          questionCount: 10,
          hasTimer: false,
        ),
      );
    });
    test('writes and reads a time attack', () {
      // Arrange
      final TimeAttackSource inputSource = TimeAttackSource(
        unitKeys: const <String>['mul:1', 'mul:2'],
      );
      // Act
      final String actualKey = inputSource.toKey();
      // Assert
      expect(actualKey, 'timeAttack:mul:1+mul:2');
      expect(ChallengeSource.tryParse(actualKey), inputSource);
    });
    test('writes and reads a survival game', () {
      // Arrange
      final SurvivalSource inputSource = SurvivalSource(
        unitKeys: const <String>['mul:1', 'mul:2'],
      );
      // Act
      final String actualKey = inputSource.toKey();
      // Assert
      expect(actualKey, 'survival:mul:1+mul:2');
      expect(ChallengeSource.tryParse(actualKey), inputSource);
      expect(
        ChallengeSource.tryParse(actualKey).hashCode,
        inputSource.hashCode,
      );
      expect(
        inputSource,
        isNot(TimeAttackSource(unitKeys: inputSource.unitKeys)),
      );
    });
    test('writes and reads the daily review', () {
      // Act
      final String actualKey = DailyReviewSource().toKey();
      final ChallengeSource? actualSource = ChallengeSource.tryParse(actualKey);
      // Assert
      expect(actualKey, 'dailyReview');
      expect(actualSource, DailyReviewSource());
      expect(actualSource.hashCode, DailyReviewSource().hashCode);
      expect(actualSource!.unitKeys, isEmpty);
    });
    test('writes and reads the monster hunt', () {
      // Act
      final String actualKey = MonsterHuntSource().toKey();
      final ChallengeSource? actualSource = ChallengeSource.tryParse(actualKey);
      // Assert
      expect(actualKey, 'monsterHunt');
      expect(actualSource, MonsterHuntSource());
      expect(actualSource, isNot(DailyReviewSource()));
      expect(actualSource.hashCode, MonsterHuntSource().hashCode);
      expect(actualSource!.unitKeys, isEmpty);
    });
    test('ignores the keys of other features and broken keys', () {
      // Act & Assert
      for (final String? inputKey in <String?>[
        null,
        'path:mul:5:training',
        'training:0:timer:mul:2',
        'training:10:maybe:mul:2',
        'training:10:timer:',
        'timeAttack:',
        'survival:',
        'survival:mul:1++mul:2',
        'dailyReview:mul:2',
        'monsterHunt:mul:2',
      ]) {
        expect(ChallengeSource.tryParse(inputKey), isNull, reason: inputKey);
      }
    });
  });

  group('ChallengeQuizSpecs', () {
    const ChallengeQuizSpecs specs = ChallengeQuizSpecs();

    test('draws a training from the facts of its tables', () {
      // Arrange
      final TrainingSource inputSource = TrainingSource(
        unitKeys: const <String>['mul:2', 'mul:5'],
        questionCount: 30,
        hasTimer: true,
      );
      // Act
      final QuizSpec actualSpec = specs.specOf(
        domain: domain,
        source: inputSource,
      )!;
      // Assert
      expect(actualSpec.mode, QuizMode.freeTraining);
      expect(
        actualSpec.questionTypeIds,
        containsAll(<String>[
          QuestionTypeIds.findOperation,
          QuestionTypeIds.matchPairs,
        ]),
      );
      expect(actualSpec.itemKeys, hasLength(20));
      expect(actualSpec.itemKeys, containsAll(<String>['mul:2x3', 'mul:5x9']));
      expect(actualSpec.questionCount, 30);
      expect(actualSpec.baseTimeLimit, ChallengeRules.trainingTimeLimit);
      expect(actualSpec.keepsTimer, isTrue);
      expect(actualSpec.totalTimeLimit, isNull);
      expect(actualSpec.sourceKey, inputSource.toKey());
    });
    test('gives a training without timer no time per question', () {
      // Act
      final QuizSpec actualSpec = specs.specOf(
        domain: domain,
        source: TrainingSource(
          unitKeys: const <String>['mul:3'],
          questionCount: 10,
          hasTimer: false,
        ),
      )!;
      // Assert
      expect(actualSpec.baseTimeLimit, isNull);
      expect(actualSpec.keepsTimer, isFalse);
    });
    test('plays a time attack for 60 seconds with answers to pick', () {
      // Act
      final QuizSpec actualSpec = specs.specOf(
        domain: domain,
        source: TimeAttackSource(unitKeys: const <String>['mul:1', 'mul:2']),
      )!;
      // Assert
      expect(actualSpec.mode, QuizMode.timeAttack);
      expect(actualSpec.totalTimeLimit, const Duration(seconds: 60));
      expect(actualSpec.baseTimeLimit, isNull);
      expect(actualSpec.questionTypeIds, <String>[
        QuestionTypeIds.multipleChoice,
      ]);
      expect(actualSpec.itemKeys, hasLength(20));
    });
    test('plays survival with 3 lives and a shrinking time', () {
      // Act
      final QuizSpec actualSpec = specs.specOf(
        domain: domain,
        source: SurvivalSource(unitKeys: const <String>['mul:1', 'mul:2']),
      )!;
      // Assert
      expect(actualSpec.mode, QuizMode.survival);
      expect(actualSpec.lives, 3);
      expect(actualSpec.baseTimeLimit, const Duration(seconds: 10));
      expect(actualSpec.timeSchedule, ChallengeRules.survivalTimeSchedule);
      expect(actualSpec.keepsTimer, isTrue);
      expect(actualSpec.totalTimeLimit, isNull);
      expect(actualSpec.questionCount, ChallengeRules.survivalQuestionCount);
      expect(actualSpec.questionTypeIds, <String>[
        QuestionTypeIds.multipleChoice,
      ]);
      expect(actualSpec.itemKeys, hasLength(20));
      expect(actualSpec.sourceKey, 'survival:mul:1+mul:2');
    });
    test('loses half a second every 5 right answers, down to 4', () {
      // Arrange
      const QuizTimeSchedule inputSchedule =
          ChallengeRules.survivalTimeSchedule;
      // Act & Assert
      expect(inputSchedule.limitAfter(0), const Duration(seconds: 10));
      expect(inputSchedule.limitAfter(5), const Duration(milliseconds: 9500));
      expect(inputSchedule.limitAfter(59), const Duration(milliseconds: 4500));
      expect(inputSchedule.limitAfter(60), const Duration(seconds: 4));
      expect(inputSchedule.limitAfter(90), const Duration(seconds: 4));
    });
    test('has no quiz for an unknown table', () {
      // Act
      final QuizSpec? actualSpec = specs.specOf(
        domain: domain,
        source: TimeAttackSource(unitKeys: const <String>['mul:99']),
      );
      // Assert
      expect(actualSpec, isNull);
    });
    test('reviews 10 facts of every table without timer', () {
      // Act
      final QuizSpec actualSpec = specs.specOf(
        domain: domain,
        source: DailyReviewSource(),
      )!;
      // Assert
      expect(actualSpec.mode, QuizMode.dailyReview);
      expect(actualSpec.domainId, LearningDomainIds.mixed);
      expect(actualSpec.selection, QuizSelection.review);
      expect(actualSpec.questionCount, 10);
      expect(actualSpec.itemKeys, hasLength(120));
      expect(actualSpec.baseTimeLimit, isNull);
      expect(actualSpec.totalTimeLimit, isNull);
      expect(actualSpec.keepsTimer, isFalse);
      expect(
        actualSpec.questionTypeIds,
        containsAll(ChallengeRules.versionOneQuestionTypeIds),
      );
      expect(actualSpec.sourceKey, 'dailyReview');
    });
    test('mixes the items of every domain in the daily review', () {
      // Arrange
      final List<LearningDomain> inputDomains = buildDomainRegistry().domains;
      // Act
      final QuizSpec actualSpec = specs.dailyReviewOf(inputDomains)!;
      // Assert
      expect(actualSpec.domainId, LearningDomainIds.mixed);
      expect(
        actualSpec.itemKeys,
        containsAll(<String>[
          'mul:7x8',
          'num:count:7',
          'num:compare:34:43',
          'add:7+8',
          'sub:15-7',
          'div:56/7',
          'word:il_reste',
        ]),
      );
      expect(
        actualSpec.itemKeys.map((String key) => key.split(':').first).toSet(),
        <String>{'mul', 'num', 'add', 'sub', 'div', 'word'},
      );
      expect(actualSpec.sourceKey, 'dailyReview');
      expect(specs.dailyReviewOf(const <LearningDomain>[]), isNull);
    });
    test('hunts the monsters in 10 questions without timer', () {
      // Act
      final QuizSpec actualSpec = specs.specOf(
        domain: domain,
        source: MonsterHuntSource(),
      )!;
      // Assert
      expect(actualSpec.mode, QuizMode.monsterHunt);
      expect(actualSpec.selection, QuizSelection.monsterHunt);
      expect(actualSpec.questionCount, 10);
      expect(actualSpec.itemKeys, hasLength(120));
      expect(actualSpec.baseTimeLimit, isNull);
      expect(actualSpec.totalTimeLimit, isNull);
      expect(actualSpec.lives, isNull);
      expect(
        actualSpec.questionTypeIds,
        ChallengeRules.versionOneQuestionTypeIds,
      );
      expect(actualSpec.sourceKey, 'monsterHunt');
    });
  });
}
