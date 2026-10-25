import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/frozen_question_generator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:kid_matix/core/services/seeded_random_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/code_quiz_result.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_code_codec.dart';
import 'package:kid_matix/features/challenge/domain/usecases/build_quiz_from_code_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/challenge_code_params.dart';
import 'package:kid_matix/features/challenge/domain/usecases/encode_challenge_code_use_case.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../../../helpers/data_state_test_extension.dart';

/// The app of one phone: its own domain and use cases.
final class _Phone {
  _Phone({int randomSeed = 5})
    : domains = DomainRegistry()..register(MultiplicationDomain()) {
    encode = EncodeChallengeCodeUseCase(
      domains: domains,
      random: SeededRandomSource(seed: randomSeed),
    );
    buildFromCode = BuildQuizFromCodeUseCase(domains: domains);
  }

  final DomainRegistry domains;
  late final EncodeChallengeCodeUseCase encode;
  late final BuildQuizFromCodeUseCase buildFromCode;

  /// The questions this phone asks for [code], as the quiz builds them.
  Future<List<String>> questionsOf(String code) async {
    final QuizSpec spec = switch (await buildFromCode(params: code)) {
      CodeQuizReady(:final QuizSpec spec) => spec,
      CodeQuizRejected(:final ChallengeCodeError error) => throw StateError(
        '$error',
      ),
    };
    return const FrozenQuestionGenerator()
        .generate(
          domain: domains.find(spec.domainId)!,
          itemKeys: spec.itemKeys,
          questionTypeIds: spec.questionTypeIds,
          questionCount: spec.questionCount!,
          draw: spec.seededDraw!,
        )
        .map(_describe)
        .toList();
  }
}

/// [question] in short: type, prompt, choices, pairs and answer, such as
/// `multipleChoice 3x7=? 18/10/21/14 -> 21`.
String _describe(Question question) {
  final String pairs = question.pairs
      .map(
        (QuestionPair pair) =>
            '${_answer(pair.operation)}:'
            '${_answer(pair.result)}',
      )
      .join(',');
  return <String>[
    question.questionTypeId,
    _tokens(question.prompt),
    if (question.choices.isNotEmpty) question.choices.map(_answer).join('/'),
    if (pairs.isNotEmpty) pairs,
    '-> ${_answer(question.expectedAnswer)}',
  ].join(' ');
}

String _tokens(List<PromptToken> tokens) {
  return tokens.join(' ').replaceAll(' multiply ', 'x').replaceAll(' = ', '=');
}

String _answer(Answer answer) {
  return switch (answer) {
    NumberAnswer(:final int value) => '$value',
    BooleanAnswer(:final bool value) => '$value',
    OperationAnswer(:final List<PromptToken> operation) => _tokens(operation),
    PairsAnswer() => 'pairs',
    ProblemAnswer() => 'problem',
    ComparisonAnswer(:final comparison) => comparison.name,
    WordAnswer(:final String wordKey) => wordKey,
    OperatorAnswer(:final operator) => operator.name,
  };
}

String _codeOf(ChallengeCode code) => const ChallengeCodeCodec().encode(code);

void main() {
  group('EncodeChallengeCodeUseCase', () {
    test('codes a free training with a new seed and its score', () async {
      // Arrange
      final _Phone phone = _Phone();
      final String inputSource = TrainingSource(
        unitKeys: const <String>['mul:5', 'mul:2'],
        questionCount: 20,
        hasTimer: true,
      ).toKey();
      // Act
      final String actualCode = (await phone.encode(
        params: ChallengeCodeParams(sourceKey: inputSource, score: 17),
      )).requireData;
      // Assert
      final CodeQuizReady actualQuiz =
          await phone.buildFromCode(params: actualCode) as CodeQuizReady;
      expect(actualQuiz.code.tables, <int>[2, 5]);
      expect(actualQuiz.code.mode, ChallengeCodeMode.timedTraining);
      expect(actualQuiz.code.questionCount, 20);
      expect(actualQuiz.code.scoreToBeat, 17);
      expect(
        actualQuiz.code.generatorVersion,
        FrozenQuestionGenerator.currentVersion,
      );
    });
    test('codes a time attack and a training without timer', () async {
      // Arrange
      final _Phone phone = _Phone();
      final Map<String, ChallengeCodeMode> inputSources =
          <String, ChallengeCodeMode>{
            TimeAttackSource(unitKeys: const <String>['mul:1']).toKey():
                ChallengeCodeMode.timeAttack,
            TrainingSource(
              unitKeys: const <String>['mul:9'],
              questionCount: 10,
              hasTimer: false,
            ).toKey(): ChallengeCodeMode.training,
          };
      for (final MapEntry<String, ChallengeCodeMode> input
          in inputSources.entries) {
        // Act
        final String actualCode = (await phone.encode(
          params: ChallengeCodeParams(sourceKey: input.key, score: 4),
        )).requireData;
        // Assert
        final CodeQuizReady actualQuiz =
            await phone.buildFromCode(params: actualCode) as CodeQuizReady;
        expect(actualQuiz.code.mode, input.value);
      }
    });
    test('a code sent back keeps the seed with the new score', () async {
      // Arrange
      final _Phone phone = _Phone();
      final ChallengeCode inputCode = ChallengeCode(
        tables: const <int>[3],
        mode: ChallengeCodeMode.training,
        questionCount: 10,
        seed: 777,
        scoreToBeat: 6,
        generatorVersion: 1,
      );
      // Act
      final String actualCode = (await phone.encode(
        params: ChallengeCodeParams(
          sourceKey: CodeChallengeSource(code: inputCode).toKey(),
          score: 9,
        ),
      )).requireData;
      // Assert
      expect(actualCode, _codeOf(inputCode.copyWith(scoreToBeat: 9)));
    });
    test('refuses a game that cannot be coded', () async {
      // Arrange
      final _Phone phone = _Phone();
      final List<ChallengeCodeParams> inputParams = <ChallengeCodeParams>[
        ChallengeCodeParams(sourceKey: DailyReviewSource().toKey(), score: 3),
        ChallengeCodeParams(
          sourceKey: SurvivalSource(unitKeys: const <String>['mul:1']).toKey(),
          score: 3,
        ),
        const ChallengeCodeParams(sourceKey: 'path:mul:5:training', score: 3),
        ChallengeCodeParams(
          sourceKey: TimeAttackSource(
            unitKeys: const <String>['mul:99'],
          ).toKey(),
          score: 3,
        ),
        ChallengeCodeParams(
          sourceKey: TrainingSource(
            unitKeys: const <String>['mul:2'],
            questionCount: 10,
            hasTimer: true,
          ).toKey(),
          score: 11,
        ),
      ];
      for (final ChallengeCodeParams input in inputParams) {
        // Act
        final AppException? actualError = (await phone.encode(
          params: input,
        )).exceptionOrNull;
        // Assert
        expect(
          actualError,
          isA<ValidationException>(),
          reason: input.sourceKey,
        );
      }
    });
  });

  group('BuildQuizFromCodeUseCase', () {
    test('a time attack code keeps the rules of the time attack', () async {
      // Arrange
      final String inputCode = _codeOf(
        ChallengeCode(
          tables: const <int>[2, 5],
          mode: ChallengeCodeMode.timeAttack,
          questionCount: 80,
          seed: 4242,
          scoreToBeat: 18,
          generatorVersion: 1,
        ),
      );
      // Act
      final CodeQuizResult actualResult = await _Phone().buildFromCode(
        params: inputCode,
      );
      // Assert
      final QuizSpec actualSpec = (actualResult as CodeQuizReady).spec;
      expect(actualSpec.mode, QuizMode.timeAttack);
      expect(actualSpec.itemKeys, hasLength(20));
      expect(actualSpec.itemKeys.first, 'mul:2x1');
      expect(actualSpec.questionTypeIds, <String>[
        QuestionTypeIds.multipleChoice,
      ]);
      expect(actualSpec.questionCount, 80);
      expect(actualSpec.totalTimeLimit, const Duration(seconds: 60));
      expect(actualSpec.baseTimeLimit, isNull);
      expect(actualSpec.sourceKey, 'code:$inputCode');
      expect(actualSpec.seededDraw, const SeededDraw(seed: 4242, version: 1));
    });
    test(
      'a training code keeps its count, its timer and six formats',
      () async {
        // Arrange
        final String inputCode = _codeOf(
          ChallengeCode(
            tables: const <int>[7],
            mode: ChallengeCodeMode.timedTraining,
            questionCount: 30,
            seed: 1,
            scoreToBeat: 0,
            generatorVersion: 1,
          ),
        );
        // Act
        final CodeQuizReady actualResult =
            await _Phone().buildFromCode(params: inputCode) as CodeQuizReady;
        // Assert
        final QuizSpec actualSpec = actualResult.spec;
        expect(actualSpec.mode, QuizMode.freeTraining);
        expect(actualSpec.questionCount, 30);
        expect(actualSpec.baseTimeLimit, const Duration(seconds: 10));
        expect(actualSpec.keepsTimer, isTrue);
        expect(actualSpec.totalTimeLimit, isNull);
        expect(actualSpec.questionTypeIds, hasLength(6));
      },
    );
    test('refuses an altered, unknown or empty code with its reason', () async {
      // Arrange
      final _Phone phone = _Phone();
      final String inputCode = _codeOf(
        ChallengeCode(
          tables: const <int>[7],
          mode: ChallengeCodeMode.training,
          questionCount: 10,
          seed: 1,
          scoreToBeat: 0,
          generatorVersion: 1,
        ),
      );
      final String inputAltered =
          '${inputCode.substring(0, 9)}'
          '${inputCode[9] == 'A' ? 'B' : 'A'}';
      // Act
      final CodeQuizResult actualAltered = await phone.buildFromCode(
        params: inputAltered,
      );
      final CodeQuizResult actualEmpty = await phone.buildFromCode(params: '');
      // Assert
      expect(
        (actualAltered as CodeQuizRejected).error,
        ChallengeCodeError.altered,
      );
      expect(
        (actualEmpty as CodeQuizRejected).error,
        ChallengeCodeError.malformed,
      );
    });
    test('refuses a valid code when the domain is missing', () async {
      // Arrange
      final BuildQuizFromCodeUseCase inputUseCase = BuildQuizFromCodeUseCase(
        domains: DomainRegistry(),
      );
      // Act
      final CodeQuizResult actualResult = await inputUseCase(
        params: '2PQJTF5MPR',
      );
      // Assert
      expect(
        (actualResult as CodeQuizRejected).error,
        ChallengeCodeError.malformed,
      );
    });
  });

  group('Same code, same questions (generator version 1)', () {
    test('a code made on one phone asks the same on a second one', () async {
      // Arrange
      final _Phone inputFirstPhone = _Phone(randomSeed: 1);
      final _Phone inputSecondPhone = _Phone(randomSeed: 2);
      final String inputCode = (await inputFirstPhone.encode(
        params: ChallengeCodeParams(
          sourceKey: TrainingSource(
            unitKeys: const <String>['mul:4', 'mul:8'],
            questionCount: 20,
            hasTimer: true,
          ).toKey(),
          score: 15,
        ),
      )).requireData;
      // Act
      final List<String> actualFirst = await inputFirstPhone.questionsOf(
        inputCode,
      );
      final List<String> actualSecond = await inputSecondPhone.questionsOf(
        inputCode,
      );
      // Assert
      expect(actualFirst, hasLength(20));
      expect(actualSecond, actualFirst);
    });
    test('golden list of a training code', () async {
      // Act
      final List<String> actualQuestions = await _Phone().questionsOf(
        _codeOf(
          ChallengeCode(
            tables: const <int>[3, 7],
            mode: ChallengeCodeMode.timedTraining,
            questionCount: 20,
            seed: 2026,
            scoreToBeat: 8,
            generatorVersion: 1,
          ),
        ),
      );
      // Assert
      expect(actualQuestions, <String>[
        'multipleChoice 3x7=? 18/10/21/14 -> 21',
        'typedAnswer 3x8=? -> 24',
        'trueFalse 7x6=13 -> false',
        'typedAnswer 3x5=? -> 15',
        'findOperation ?=27 3x8/2x9/4x8/3x9 -> 3x9',
        'trueFalse 3x2=6 -> true',
        'trueFalse 7x4=24 -> false',
        'missingNumber ?x8=56 -> 7',
        'findOperation ?=63 5x9/7x10/7x9/8x9 -> 7x9',
        'typedAnswer 7x3=? -> 21',
        'missingNumber 3x?=3 -> 1',
        'matchPairs  49/14/21/35 7x2:14,7x7:49,7x3:21,7x5:35 -> pairs',
        'matchPairs  35/42/21/49 7x6:42,7x5:35,7x3:21,7x7:49 -> pairs',
        'trueFalse 7x10=80 -> false',
        'multipleChoice 3x4=? 21/7/15/12 -> 12',
        'matchPairs  21/9/27/6 3x2:6,3x7:21,3x3:9,3x9:27 -> pairs',
        'matchPairs  28/7/70/35 7x4:28,7x10:70,7x5:35,7x1:7 -> pairs',
        'typedAnswer 7x2=? -> 14',
        'missingNumber ?x6=18 -> 3',
        'findOperation ?=30 3x9/3x10/1x10/2x10 -> 3x10',
      ]);
    });
    test('golden list of a time attack code', () async {
      // Act
      final List<String> actualQuestions = await _Phone().questionsOf(
        '2PQJTF5MPR',
      );
      // Assert
      expect(actualQuestions.take(12).toList(), <String>[
        'multipleChoice 5x3=? 12/18/51/15 -> 15',
        'multipleChoice 2x2=? 5/4/6/2 -> 4',
        'multipleChoice 2x1=? 2/1/3/4 -> 2',
        'multipleChoice 2x10=? 20/12/10/18 -> 20',
        'multipleChoice 5x4=? 20/25/24/9 -> 20',
        'multipleChoice 2x3=? 3/6/9/5 -> 6',
        'multipleChoice 5x8=? 40/13/32/45 -> 40',
        'multipleChoice 5x2=? 8/15/12/10 -> 10',
        'multipleChoice 5x6=? 36/30/35/24 -> 30',
        'multipleChoice 2x8=? 24/8/10/16 -> 16',
        'multipleChoice 2x7=? 12/21/16/14 -> 14',
        'multipleChoice 5x5=? 10/52/30/25 -> 25',
      ]);
    });
  });
}
