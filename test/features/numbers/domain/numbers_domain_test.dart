import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/comparison.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/app_question_types.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/numbers/domain/entities/number_item.dart';
import 'package:kid_matix/features/numbers/domain/services/number_distractor_generator.dart';
import 'package:kid_matix/features/numbers/domain/services/numbers_domain.dart';

/// Every key of the numbers domain as released: a change here loses the
/// progress of the children.
const Map<String, List<String>> _releasedKeys = <String, List<String>>{
  'num:count10': <String>[
    'num:count:1',
    'num:count:2',
    'num:count:3',
    'num:count:4',
    'num:count:5',
    'num:count:6',
    'num:count:7',
    'num:count:8',
    'num:count:9',
    'num:count:10',
  ],
  'num:count20': <String>[
    'num:count:11',
    'num:count:12',
    'num:count:13',
    'num:count:14',
    'num:count:15',
    'num:count:16',
    'num:count:17',
    'num:count:18',
    'num:count:19',
    'num:count:20',
  ],
  'num:count100': <String>[
    'num:tens:10',
    'num:tens:20',
    'num:tens:30',
    'num:tens:40',
    'num:tens:50',
    'num:tens:60',
    'num:tens:70',
    'num:tens:80',
    'num:tens:90',
    'num:tens:100',
  ],
  'num:tensones': <String>[
    'num:place:13',
    'num:place:21',
    'num:place:34',
    'num:place:45',
    'num:place:52',
    'num:place:59',
    'num:place:67',
    'num:place:76',
    'num:place:83',
    'num:place:98',
  ],
  'num:compare': <String>[
    'num:compare:3-8',
    'num:compare:9-6',
    'num:compare:12-21',
    'num:compare:15-15',
    'num:compare:34-43',
    'num:compare:58-49',
    'num:compare:76-67',
    'num:compare:80-80',
    'num:compare:91-19',
    'num:compare:99-100',
  ],
  'num:order': <String>[
    'num:order:8:2',
    'num:order:14:2',
    'num:order:15:5',
    'num:order:26:2',
    'num:order:30:10',
    'num:order:40:5',
    'num:order:55:5',
    'num:order:70:10',
    'num:order:85:5',
    'num:order:90:10',
  ],
  'num:beforeafter': <String>[
    'num:after:5',
    'num:before:7',
    'num:after:9',
    'num:before:10',
    'num:after:19',
    'num:before:30',
    'num:after:39',
    'num:before:61',
    'num:before:80',
    'num:after:99',
  ],
};

final class _ForeignItem implements LearningItem {
  const _ForeignItem();

  @override
  String get key => 'mul:7x8';
}

/// The number a question asks, written or picked.
int _expectedNumber(Question question) {
  return (question.expectedAnswer as NumberAnswer).value;
}

void main() {
  final NumbersDomain domain = NumbersDomain();
  final List<NumberItem> allItems = <NumberItem>[
    for (final LearningUnit unit in domain.units)
      for (final LearningItem item in unit.items) item as NumberItem,
  ];

  Question build(LearningItem item, String questionTypeId, {int seed = 1}) {
    return domain.buildQuestion(
      item: item,
      questionTypeId: questionTypeId,
      random: DartRandomSource(seed: seed),
    );
  }

  group('items and units', () {
    test('keeps the released unit and item keys, in path order', () {
      // Act
      final Map<String, List<String>> actualKeys = <String, List<String>>{
        for (final LearningUnit unit in domain.path)
          unit.key: <String>[
            for (final LearningItem item in unit.items) item.key,
          ],
      };
      // Assert
      expect(actualKeys, _releasedKeys);
      expect(
        domain.path.map((LearningUnit unit) => unit.number),
        <int>[1, 2, 3, 4, 5, 6, 7],
      );
    });
    test('gives every item a unique key that no other domain uses', () {
      // Arrange
      final Set<String> multiplicationKeys = <String>{
        for (final LearningUnit unit in MultiplicationDomain().units)
          for (final LearningItem item in unit.items) item.key,
      };
      // Act
      final List<String> actualKeys = allItems
          .map((NumberItem item) => item.key)
          .toList();
      // Assert
      expect(actualKeys, hasLength(70));
      expect(actualKeys.toSet(), hasLength(70));
      expect(actualKeys.every((String key) => key.startsWith('num:')), isTrue);
      expect(actualKeys.toSet().intersection(multiplicationKeys), isEmpty);
    });
    test('finds an item and a unit from its key', () {
      // Assert
      expect(domain.id, 'numbers');
      expect(domain.findItem('num:place:34'), const TensOnesItem(34));
      expect(domain.findItem('num:count:21'), isNull);
      expect(domain.findUnit('num:compare')?.number, 5);
      expect(domain.findUnit('mul:5'), isNull);
    });
    test('draws every item alike and has no mirror', () {
      // Assert
      for (final NumberItem item in allItems) {
        expect(domain.drawWeightOf(item), NumbersDomain.drawWeight);
        expect(domain.mirrorOf(item), isNull);
      }
    });
    test('refuses an item of another domain', () {
      // Assert
      expect(() => domain.helpOf(const _ForeignItem()), throwsArgumentError);
      expect(
        () => domain.questionTypeIdsOf(const _ForeignItem()),
        throwsArgumentError,
      );
    });
    test('gives every item a format to pick and one to write', () {
      // Arrange
      final Map<String, QuestionType> types = <String, QuestionType>{
        for (final QuestionType type in appQuestionTypes) type.id: type,
      };
      // Assert
      for (final NumberItem item in allItems) {
        final List<String> typeIds = domain.questionTypeIdsOf(item);
        expect(typeIds, isNotEmpty);
        expect(typeIds.every(domain.questionTypeIds.contains), isTrue);
        expect(
          typeIds.any(
            (String id) => types[id]!.answerNature.name == 'produced',
          ),
          isTrue,
          reason: '${item.key} must be masterable',
        );
      }
    });
  });

  group('questions', () {
    test('build every format of every item without ambiguity', () {
      for (final NumberItem item in allItems) {
        for (final String typeId in domain.questionTypeIdsOf(item)) {
          for (int seed = 0; seed < 5; seed++) {
            // Act
            final Question actual = build(item, typeId, seed: seed);
            // Assert
            expect(actual.itemKey, item.key);
            expect(actual.questionTypeId, typeId);
            expect(domain.findUnit(actual.unitKey), isNotNull);
            expect(actual.choices.toSet(), hasLength(actual.choices.length));
            if (actual.choices.isNotEmpty) {
              expect(
                actual.choices.where(
                  (Answer choice) => choice == actual.expectedAnswer,
                ),
                hasLength(1),
                reason: '${item.key} $typeId',
              );
            }
          }
        }
      }
    });
    test('offer four plausible numbers to pick, in range', () {
      for (final PictureNumberItem item
          in allItems.whereType<PictureNumberItem>()) {
        // Act
        final Question actual = build(item, item.questionTypeIds.first);
        // Assert
        expect(actual.choices, hasLength(4));
        for (final Answer choice in actual.choices) {
          final int value = (choice as NumberAnswer).value;
          expect(
            value,
            greaterThanOrEqualTo(NumberDistractorGenerator.smallest),
          );
          expect(value, lessThanOrEqualTo(NumberDistractorGenerator.largest));
        }
        expect(_expectedNumber(actual), item.answer);
        expect(actual.picture, item.picture);
      }
    });
    test('count the objects drawn, picked or written', () {
      // Act
      final Question actualPicked = build(
        const CountItem(7),
        QuestionTypeIds.countObjects,
      );
      final Question actualWritten = build(
        const CountItem(7),
        QuestionTypeIds.typedAnswer,
      );
      // Assert
      expect(actualPicked.picture, const ObjectsPicture(count: 7));
      expect(actualPicked.prompt, const <PromptToken>[BlankToken()]);
      expect(_expectedNumber(actualPicked), 7);
      expect(actualWritten.choices, isEmpty);
      expect(actualWritten.picture, const ObjectsPicture(count: 7));
      expect(_expectedNumber(actualWritten), 7);
    });
    test('always offer the swapped digits of a number', () {
      for (int seed = 0; seed < 20; seed++) {
        // Act
        final Question actual = build(
          const TensOnesItem(34),
          QuestionTypeIds.tensAndOnes,
          seed: seed,
        );
        // Assert
        expect(actual.picture, const TenBundlesPicture(tens: 3, ones: 4));
        expect(actual.choices, contains(const NumberAnswer(43)));
      }
    });
    test('hide one number of a line in its drawing', () {
      // Act
      final Question actual = build(
        domain.findItem('num:order:8:2')!,
        QuestionTypeIds.numberLine,
      );
      // Assert
      expect(actual.prompt, isEmpty);
      expect(
        actual.picture,
        NumberLinePicture(values: const <int>[2, 4, 6, 8, 10], blankIndex: 3),
      );
      expect(_expectedNumber(actual), 8);
    });
    test('ask the number just before or after, across the ten', () {
      // Act
      final Question actualAfter = build(
        domain.findItem('num:after:39')!,
        QuestionTypeIds.numberLine,
      );
      final Question actualBefore = build(
        domain.findItem('num:before:30')!,
        QuestionTypeIds.typedAnswer,
      );
      // Assert
      expect(_expectedNumber(actualAfter), 40);
      expect(
        actualAfter.picture,
        NumberLinePicture(
          values: const <int>[38, 39, 40],
          blankIndex: 2,
          highlightIndex: 1,
        ),
      );
      expect(_expectedNumber(actualBefore), 29);
    });
    test('compare two numbers with three signs', () {
      // Act
      final Question actualLess = build(
        domain.findItem('num:compare:34-43')!,
        QuestionTypeIds.compare,
      );
      final Question actualEqual = build(
        domain.findItem('num:compare:15-15')!,
        QuestionTypeIds.compare,
      );
      final Question actualGreater = build(
        domain.findItem('num:compare:58-49')!,
        QuestionTypeIds.compare,
      );
      // Assert
      expect(actualLess.prompt, const <PromptToken>[
        NumberToken(34),
        BlankToken(),
        NumberToken(43),
      ]);
      expect(actualLess.choices, ComparisonAnswer.all);
      expect(
        actualLess.expectedAnswer,
        const ComparisonAnswer(Comparison.less),
      );
      expect(
        actualEqual.expectedAnswer,
        const ComparisonAnswer(Comparison.equal),
      );
      expect(
        actualGreater.expectedAnswer,
        const ComparisonAnswer(Comparison.greater),
      );
    });
    test('refuse a format the item does not fit', () {
      // Assert
      expect(
        () => build(const CountItem(3), QuestionTypeIds.compare),
        throwsArgumentError,
      );
      expect(
        () => build(
          domain.findItem('num:compare:3-8')!,
          QuestionTypeIds.typedAnswer,
        ),
        throwsArgumentError,
      );
    });
    test('are judged by their question type', () {
      // Arrange
      final Map<String, QuestionType> types = <String, QuestionType>{
        for (final QuestionType type in appQuestionTypes) type.id: type,
      };
      for (final NumberItem item in allItems) {
        for (final String typeId in domain.questionTypeIdsOf(item)) {
          final Question question = build(item, typeId);
          final Answer wrong = question.choices.isEmpty
              ? NumberAnswer(_expectedNumber(question) + 1)
              : question.choices.firstWhere(
                  (Answer choice) => choice != question.expectedAnswer,
                );
          // Act & Assert
          expect(
            types[typeId]!.isCorrect(
              question: question,
              answer: question.expectedAnswer,
            ),
            isTrue,
          );
          expect(
            types[typeId]!.isCorrect(question: question, answer: wrong),
            isFalse,
          );
        }
      }
    });
  });

  group('facts and help', () {
    test('describe each item with its answer', () {
      // Assert
      expect(
        domain.describeItem(const TensOnesItem(34)).toDisplayText(),
        '30 + 4 = 34',
      );
      expect(
        domain
            .describeItem(const TensOnesItem(30, isWholeTens: true))
            .toDisplayText(),
        '30',
      );
      expect(
        domain
            .describeItem(domain.findItem('num:compare:34-43')!)
            .toDisplayText(),
        '34 < 43',
      );
      expect(
        domain
            .describeItem(domain.findItem('num:compare:58-49')!)
            .toDisplayText(),
        '58 > 49',
      );
      expect(
        domain
            .describeItem(domain.findItem('num:compare:15-15')!)
            .toDisplayText(),
        '15 = 15',
      );
      expect(
        domain.describeItem(domain.findItem('num:order:8:2')!).toDisplayText(),
        '2 4 6 8 10',
      );
      expect(
        domain.describeItem(domain.findItem('num:after:39')!).toDisplayText(),
        '38 39 40',
      );
      expect(domain.describeItem(const CountItem(7)).toDisplayText(), '7');
    });
    test('help with the whole unit and the drawing of the answer', () {
      // Act
      final ItemHelp actual = domain.helpOf(domain.findItem('num:place:34')!);
      // Assert
      expect(actual.unitFacts, hasLength(10));
      expect(actual.itemIndex, 2);
      expect(actual.picture, const TenBundlesPicture(tens: 3, ones: 4));
      expect(actual.dotGrid, isNull);
    });
    test('help a comparison with a line, the greater on the right', () {
      // Act
      final ItemHelp actualGreater = domain.helpOf(
        domain.findItem('num:compare:58-49')!,
      );
      final ItemHelp actualEqual = domain.helpOf(
        domain.findItem('num:compare:15-15')!,
      );
      // Assert
      expect(
        actualGreater.picture,
        NumberLinePicture(values: const <int>[49, 58], highlightIndex: 1),
      );
      expect(actualEqual.picture, isNull);
    });
    test('help a line with every number shown', () {
      // Act
      final ItemHelp actual = domain.helpOf(domain.findItem('num:before:30')!);
      // Assert
      expect(
        actual.picture,
        NumberLinePicture(values: const <int>[29, 30, 31], highlightIndex: 0),
      );
    });
  });
}
