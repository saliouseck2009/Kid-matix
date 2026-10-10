import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_quiz_specs.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

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
    test('ignores the keys of other features and broken keys', () {
      // Act & Assert
      for (final String? inputKey in <String?>[
        null,
        'path:mul:5:training',
        'training:0:timer:mul:2',
        'training:10:maybe:mul:2',
        'training:10:timer:',
        'timeAttack:',
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
    test('has no quiz for an unknown table', () {
      // Act
      final QuizSpec? actualSpec = specs.specOf(
        domain: domain,
        source: TimeAttackSource(unitKeys: const <String>['mul:99']),
      );
      // Assert
      expect(actualSpec, isNull);
    });
  });
}
