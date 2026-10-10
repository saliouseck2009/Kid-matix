import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_table.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_tip.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

final class _ForeignItem implements LearningItem {
  const _ForeignItem();

  @override
  String get key => 'div:56/7';
}

const MultiplicationFact _sevenTimesEight = MultiplicationFact(
  table: 7,
  multiplier: 8,
);

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();

  Question build(String questionTypeId, {int seed = 1}) {
    return domain.buildQuestion(
      item: _sevenTimesEight,
      questionTypeId: questionTypeId,
      random: DartRandomSource(seed: seed),
    );
  }

  group('items and units', () {
    test('has 12 tables of 10 facts', () {
      // Act
      final List<LearningUnit> actualUnits = domain.units;
      // Assert
      expect(actualUnits, hasLength(12));
      for (final MultiplicationTable table in domain.tables) {
        expect(table.facts, hasLength(10));
        expect(table.facts.first.multiplier, 1);
        expect(table.facts.last.multiplier, 10);
      }
    });
    test('gives the 120 facts unique keys', () {
      // Act
      final List<String> actualKeys = <String>[
        for (final LearningUnit unit in domain.units)
          for (final LearningItem item in unit.items) item.key,
      ];
      // Assert
      expect(actualKeys, hasLength(120));
      expect(actualKeys.toSet(), hasLength(120));
    });
    test('keeps the released key format mul:<table>x<multiplier>', () {
      // Arrange
      final List<String> expectedKeys = <String>[
        for (int table = 1; table <= 12; table++)
          for (int multiplier = 1; multiplier <= 10; multiplier++)
            'mul:${table}x$multiplier',
      ];
      // Act
      final List<String> actualKeys = <String>[
        for (final LearningUnit unit in domain.units)
          for (final LearningItem item in unit.items) item.key,
      ];
      // Assert
      expect(actualKeys, expectedKeys);
      expect(domain.units.map((LearningUnit unit) => unit.key).first, 'mul:1');
    });
    test('finds a fact from its key', () {
      // Assert
      expect(domain.findItem('mul:7x8'), _sevenTimesEight);
      expect(domain.findItem('mul:7x11'), isNull);
      expect(domain.findItem('div:56/7'), isNull);
    });
    test('finds a table from its key', () {
      // Assert
      expect(domain.findUnit('mul:7')?.number, 7);
      expect(domain.findUnit('mul:13'), isNull);
    });
    test('describes a fact with its result', () {
      // Act
      final List<PromptToken> actualStatement = domain.describeItem(
        const MultiplicationFact(table: 5, multiplier: 8),
      );
      // Assert
      expect(actualStatement, const <PromptToken>[
        NumberToken(5),
        OperatorToken(MathOperator.multiply),
        NumberToken(8),
        EqualsToken(),
        NumberToken(40),
      ]);
    });
    test('orders the learning path from the simplest table', () {
      // Act
      final List<String> actualPath = domain.path
          .map((LearningUnit unit) => unit.key)
          .toList();
      // Assert
      expect(actualPath, <String>[
        'mul:1',
        'mul:2',
        'mul:10',
        'mul:5',
        'mul:3',
        'mul:4',
        'mul:6',
        'mul:9',
        'mul:7',
        'mul:8',
        'mul:11',
        'mul:12',
      ]);
    });
    test('gives every table its own tip', () {
      // Act
      final Set<MultiplicationTip> actualTips = domain.tables
          .map((MultiplicationTable table) => table.tip)
          .toSet();
      // Assert
      expect(actualTips, MultiplicationTip.values.toSet());
      expect(domain.tables[4].tip, MultiplicationTip.tableOf5);
    });
  });

  group('draw weights', () {
    test('halves the facts x 1 and x 10 outside their own tables', () {
      // Arrange
      const List<MultiplicationFact> inputFacts = <MultiplicationFact>[
        MultiplicationFact(table: 7, multiplier: 1),
        MultiplicationFact(table: 7, multiplier: 10),
        MultiplicationFact(table: 7, multiplier: 8),
        MultiplicationFact(table: 1, multiplier: 7),
        MultiplicationFact(table: 10, multiplier: 1),
        MultiplicationFact(table: 1, multiplier: 10),
      ];
      // Act
      final List<int> actualWeights = inputFacts
          .map(domain.drawWeightOf)
          .toList();
      // Assert
      expect(actualWeights, <int>[1, 1, 2, 2, 2, 2]);
    });
    test('rejects an item of another domain', () {
      // Assert
      expect(
        () => domain.drawWeightOf(const _ForeignItem()),
        throwsArgumentError,
      );
    });
  });

  group('questions', () {
    test('asks 7 x 8 with four distinct choices including 56', () {
      // Act
      final Question actualQuestion = build(QuestionTypeIds.multipleChoice);
      // Assert
      expect(actualQuestion.itemKey, 'mul:7x8');
      expect(actualQuestion.unitKey, 'mul:7');
      expect(actualQuestion.prompt, const <PromptToken>[
        NumberToken(7),
        OperatorToken(MathOperator.multiply),
        NumberToken(8),
        EqualsToken(),
        BlankToken(),
      ]);
      expect(actualQuestion.expectedAnswer, const NumberAnswer(56));
      expect(actualQuestion.choices, hasLength(4));
      expect(actualQuestion.choices.toSet(), hasLength(4));
      expect(actualQuestion.choices, contains(const NumberAnswer(56)));
    });
    test('places the right choice at a random position', () {
      // Act
      final Set<int> actualPositions = <int>{
        for (int seed = 0; seed < 40; seed++)
          build(
            QuestionTypeIds.multipleChoice,
            seed: seed,
          ).choices.indexOf(const NumberAnswer(56)),
      };
      // Assert
      expect(actualPositions, <int>{0, 1, 2, 3});
    });
    test('lets the player write 7 x 8 without choices', () {
      // Act
      final Question actualQuestion = build(QuestionTypeIds.typedAnswer);
      // Assert
      expect(actualQuestion.choices, isEmpty);
      expect(actualQuestion.expectedAnswer, const NumberAnswer(56));
      expect(actualQuestion.prompt.last, const BlankToken());
    });
    test('hides either operand of a missing number question', () {
      // Act
      final Set<Answer> actualExpected = <Answer>{
        for (int seed = 0; seed < 20; seed++)
          build(QuestionTypeIds.missingNumber, seed: seed).expectedAnswer,
      };
      final Question actualQuestion = build(QuestionTypeIds.missingNumber);
      // Assert
      expect(actualExpected, <Answer>{
        const NumberAnswer(7),
        const NumberAnswer(8),
      });
      expect(actualQuestion.prompt, contains(const BlankToken()));
      expect(actualQuestion.prompt.last, const NumberToken(56));
    });
    test('states 7 x 8 truly about one time out of two', () {
      // Arrange
      const int inputDraws = 1000;
      // Act
      final List<Question> actualQuestions = <Question>[
        for (int seed = 0; seed < inputDraws; seed++)
          build(QuestionTypeIds.trueFalse, seed: seed),
      ];
      final int actualTrueCount = actualQuestions
          .where(
            (Question question) =>
                question.expectedAnswer == const BooleanAnswer(value: true),
          )
          .length;
      // Assert
      expect(actualTrueCount, inInclusiveRange(400, 600));
    });
    test('shows the right result in a true statement only', () {
      // Act
      final List<Question> actualQuestions = <Question>[
        for (int seed = 0; seed < 100; seed++)
          build(QuestionTypeIds.trueFalse, seed: seed),
      ];
      // Assert
      for (final Question question in actualQuestions) {
        final bool isTrueStatement =
            question.expectedAnswer == const BooleanAnswer(value: true);
        final PromptToken shown = question.prompt.last;
        expect(shown == const NumberToken(56), isTrueStatement);
        expect(<PromptToken>{
          const NumberToken(56),
          const NumberToken(49),
          const NumberToken(63),
          const NumberToken(48),
          const NumberToken(64),
          const NumberToken(15),
          const NumberToken(65),
        }, contains(shown));
      }
    });
    test('refuses a question type it does not support', () {
      // Act
      Question actualBuild() => build('matchPairs');
      // Assert
      expect(actualBuild, throwsArgumentError);
    });
    test('refuses an item of another domain', () {
      // Act
      Question actualBuild() => domain.buildQuestion(
        item: const _ForeignItem(),
        questionTypeId: QuestionTypeIds.typedAnswer,
        random: DartRandomSource(seed: 1),
      );
      // Assert
      expect(actualBuild, throwsArgumentError);
    });
  });
}
