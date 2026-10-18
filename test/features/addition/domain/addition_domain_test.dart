import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/app_question_types.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_fact.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_unit.dart';
import 'package:kid_matix/features/addition/domain/services/addition_domain.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

/// Every key of the addition domain as released: a change here loses the
/// progress of the children.
const Map<String, List<String>> _releasedKeys = <String, List<String>>{
  'addsub:add5': <String>[
    'add:1+1',
    'add:1+2',
    'add:2+1',
    'add:1+3',
    'add:3+1',
    'add:2+2',
    'add:2+3',
    'add:3+2',
    'add:1+4',
    'add:4+1',
  ],
  'addsub:add10': <String>[
    'add:3+3',
    'add:2+4',
    'add:4+2',
    'add:1+5',
    'add:5+1',
    'add:3+4',
    'add:4+3',
    'add:2+5',
    'add:5+2',
    'add:4+4',
    'add:3+5',
    'add:5+3',
    'add:4+5',
    'add:5+4',
  ],
  'addsub:toten': <String>[
    'add:1+9',
    'add:2+8',
    'add:3+7',
    'add:4+6',
    'add:5+5',
    'add:6+4',
    'add:7+3',
    'add:8+2',
    'add:9+1',
  ],
  'addsub:sub5': <String>[
    'sub:2-1',
    'sub:3-1',
    'sub:3-2',
    'sub:4-1',
    'sub:4-3',
    'sub:4-2',
    'sub:5-2',
    'sub:5-3',
    'sub:5-1',
    'sub:5-4',
  ],
  'addsub:sub10': <String>[
    'sub:6-3',
    'sub:6-2',
    'sub:6-4',
    'sub:6-1',
    'sub:6-5',
    'sub:7-3',
    'sub:7-4',
    'sub:7-2',
    'sub:7-5',
    'sub:8-4',
    'sub:8-3',
    'sub:8-5',
    'sub:9-4',
    'sub:9-5',
  ],
  'addsub:add12': <String>[
    'add:2+9',
    'add:9+2',
    'add:3+8',
    'add:8+3',
    'add:4+7',
    'add:7+4',
    'add:5+6',
    'add:6+5',
    'add:3+9',
    'add:9+3',
    'add:4+8',
    'add:8+4',
    'add:5+7',
    'add:7+5',
    'add:6+6',
  ],
  'addsub:add14': <String>[
    'add:4+9',
    'add:9+4',
    'add:5+8',
    'add:8+5',
    'add:6+7',
    'add:7+6',
    'add:5+9',
    'add:9+5',
    'add:6+8',
    'add:8+6',
    'add:7+7',
  ],
  'addsub:add20': <String>[
    'add:6+9',
    'add:9+6',
    'add:7+8',
    'add:8+7',
    'add:7+9',
    'add:9+7',
    'add:8+8',
    'add:8+9',
    'add:9+8',
    'add:9+9',
  ],
  'addsub:sub12': <String>[
    'sub:11-2',
    'sub:11-9',
    'sub:11-3',
    'sub:11-8',
    'sub:11-4',
    'sub:11-7',
    'sub:11-5',
    'sub:11-6',
    'sub:12-3',
    'sub:12-9',
    'sub:12-4',
    'sub:12-8',
    'sub:12-5',
    'sub:12-7',
    'sub:12-6',
  ],
  'addsub:sub14': <String>[
    'sub:13-4',
    'sub:13-9',
    'sub:13-5',
    'sub:13-8',
    'sub:13-6',
    'sub:13-7',
    'sub:14-5',
    'sub:14-9',
    'sub:14-6',
    'sub:14-8',
    'sub:14-7',
  ],
  'addsub:sub20': <String>[
    'sub:15-6',
    'sub:15-9',
    'sub:15-7',
    'sub:15-8',
    'sub:16-7',
    'sub:16-9',
    'sub:16-8',
    'sub:17-8',
    'sub:17-9',
    'sub:18-9',
  ],
  'addsub:add100': <String>[
    'add:23+14',
    'add:31+25',
    'add:42+36',
    'add:15+44',
    'add:52+27',
    'add:61+38',
    'add:34+45',
    'add:71+26',
    'add:18+61',
    'add:53+32',
  ],
  'addsub:sub100': <String>[
    'sub:47-23',
    'sub:58-34',
    'sub:69-25',
    'sub:86-42',
    'sub:75-31',
    'sub:98-57',
    'sub:64-12',
    'sub:79-45',
    'sub:55-21',
    'sub:88-63',
  ],
  'addsub:carry': <String>[
    'add:27+15',
    'add:38+24',
    'add:46+37',
    'add:19+25',
    'add:58+26',
    'add:35+48',
    'add:67+18',
    'add:29+34',
    'add:75+16',
    'add:49+43',
  ],
  'addsub:borrow': <String>[
    'sub:42-17',
    'sub:63-28',
    'sub:51-26',
    'sub:74-38',
    'sub:85-49',
    'sub:92-67',
    'sub:56-29',
    'sub:81-35',
    'sub:70-43',
    'sub:64-36',
  ],
};

final class _ForeignItem implements LearningItem {
  const _ForeignItem();

  @override
  String get key => 'mul:7x8';
}

int _expectedNumber(Question question) {
  return (question.expectedAnswer as NumberAnswer).value;
}

void main() {
  final AdditionDomain domain = AdditionDomain();
  final List<ArithmeticFact> allFacts = <ArithmeticFact>[
    for (final LearningUnit unit in domain.units)
      ...unit.items.cast<ArithmeticFact>(),
  ];
  final Map<String, QuestionType> types = <String, QuestionType>{
    for (final QuestionType type in appQuestionTypes) type.id: type,
  };

  group('AdditionDomain keys', () {
    test('keeps every released unit and fact key', () {
      // Assert
      expect(domain.units.map((LearningUnit unit) => unit.key), <String>[
        'addsub:add5',
        'addsub:add10',
        'addsub:toten',
        'addsub:sub5',
        'addsub:sub10',
        'addsub:add12',
        'addsub:add14',
        'addsub:add20',
        'addsub:sub12',
        'addsub:sub14',
        'addsub:sub20',
        'addsub:add100',
        'addsub:sub100',
        'addsub:carry',
        'addsub:borrow',
      ]);
      for (final MapEntry<String, List<String>> unit in _releasedKeys.entries) {
        expect(
          domain
              .findUnit(unit.key)!
              .items
              .map((LearningItem item) => item.key)
              .toList(),
          unit.value,
          reason: unit.key,
        );
      }
    });
    test('has unique keys, one unit per fact, and numbers units from 1', () {
      // Assert
      expect(
        allFacts.map((ArithmeticFact fact) => fact.key).toSet(),
        hasLength(allFacts.length),
      );
      expect(domain.units.map((LearningUnit unit) => unit.number), <int>[
        for (int number = 1; number <= 15; number++) number,
      ]);
      expect(domain.path, domain.units);
    });
    test('writes additions as add:7+8 and subtractions as sub:15-7', () {
      // Assert
      expect(const ArithmeticFact.add(7, 8).key, 'add:7+8');
      expect(const ArithmeticFact.subtract(15, 7).key, 'sub:15-7');
      expect(domain.findItem('add:7+8'), const ArithmeticFact.add(7, 8));
      expect(domain.findItem('add:1+8'), isNull);
      expect(domain.findUnit('addsub:nope'), isNull);
    });
    test('teaches only subtractions that stay positive', () {
      for (final ArithmeticFact fact in allFacts) {
        // Assert
        expect(fact.result, greaterThan(0), reason: fact.key);
        expect(fact.left, greaterThanOrEqualTo(0));
        expect(fact.right, greaterThanOrEqualTo(0));
        expect(fact.result, lessThanOrEqualTo(99), reason: fact.key);
      }
    });
    test('puts the carry and the borrow in their own units only', () {
      for (final ArithmeticFact fact
          in domain.findUnit('addsub:add100')!.items.cast<ArithmeticFact>()) {
        expect(fact.crossesTen, isFalse, reason: fact.key);
      }
      for (final ArithmeticFact fact
          in domain.findUnit('addsub:sub100')!.items.cast<ArithmeticFact>()) {
        expect(fact.crossesTen, isFalse, reason: fact.key);
      }
      for (final String slug in <String>['carry', 'borrow']) {
        for (final ArithmeticFact fact
            in domain.findUnit('addsub:$slug')!.items.cast<ArithmeticFact>()) {
          expect(fact.crossesTen, isTrue, reason: fact.key);
        }
      }
    });
    test('keeps the complements to 10 in their unit', () {
      for (final ArithmeticFact fact
          in domain.findUnit('addsub:toten')!.items.cast<ArithmeticFact>()) {
        // Assert
        expect(fact.result, 10, reason: fact.key);
      }
    });
  });

  group('AdditionDomain questions', () {
    test('supports the four formats of the multiplication for every fact', () {
      for (final ArithmeticFact fact in allFacts) {
        // Assert
        expect(domain.questionTypeIdsOf(fact), domain.questionTypeIds);
      }
      expect(domain.questionTypeIds, <String>[
        QuestionTypeIds.multipleChoice,
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
        QuestionTypeIds.trueFalse,
      ]);
    });
    test('builds a multiple choice with the result and 3 other numbers', () {
      for (final ArithmeticFact fact in allFacts) {
        for (int seed = 0; seed < 4; seed++) {
          // Act
          final Question actual = domain.buildQuestion(
            item: fact,
            questionTypeId: QuestionTypeIds.multipleChoice,
            random: DartRandomSource(seed: seed),
          );
          final List<int> values = actual.choices
              .map((answer) => (answer as NumberAnswer).value)
              .toList();
          // Assert
          expect(values, hasLength(4), reason: fact.key);
          expect(values.toSet(), hasLength(4), reason: fact.key);
          expect(values, contains(fact.result));
          expect(values.every((int value) => value >= 0), isTrue);
          expect(actual.itemKey, fact.key);
          expect(actual.prompt.last, const BlankToken());
          expect(
            types[actual.questionTypeId]!.isCorrect(
              question: actual,
              answer: NumberAnswer(fact.result),
            ),
            isTrue,
          );
        }
      }
    });
    test('writes the operation with its blank for a typed answer', () {
      // Act
      final Question actual = domain.buildQuestion(
        item: domain.findItem('sub:15-7')!,
        questionTypeId: QuestionTypeIds.typedAnswer,
        random: DartRandomSource(seed: 1),
      );
      // Assert
      expect(actual.prompt, const <PromptToken>[
        NumberToken(15),
        OperatorToken(MathOperator.subtract),
        NumberToken(7),
        EqualsToken(),
        BlankToken(),
      ]);
      expect(actual.prompt.toDisplayText(), '15 − 7 = ?');
      expect(actual.unitKey, 'addsub:sub20');
      expect(actual.choices, isEmpty);
      expect(_expectedNumber(actual), 8);
    });
    test('hides either number of a missing number question', () {
      final Set<String> shown = <String>{};
      for (int seed = 0; seed < 12; seed++) {
        // Act
        final Question actual = domain.buildQuestion(
          item: domain.findItem('add:7+8')!,
          questionTypeId: QuestionTypeIds.missingNumber,
          random: DartRandomSource(seed: seed),
        );
        shown.add(actual.prompt.toDisplayText());
        // Assert
        expect(actual.prompt.whereType<BlankToken>(), hasLength(1));
        final bool hidesLeft = actual.prompt.first is BlankToken;
        expect(_expectedNumber(actual), hidesLeft ? 7 : 8);
      }
      expect(shown, <String>{'? + 8 = 15', '7 + ? = 15'});
    });
    test('hides the second number of a complement to 10', () {
      for (int seed = 0; seed < 8; seed++) {
        // Act
        final Question actual = domain.buildQuestion(
          item: domain.findItem('add:7+3')!,
          questionTypeId: QuestionTypeIds.missingNumber,
          random: DartRandomSource(seed: seed),
        );
        // Assert
        expect(actual.prompt.toDisplayText(), '7 + ? = 10');
        expect(_expectedNumber(actual), 3);
      }
    });
    test('shows a true or a false statement', () {
      final Set<bool> answers = <bool>{};
      for (int seed = 0; seed < 12; seed++) {
        // Act
        final Question actual = domain.buildQuestion(
          item: domain.findItem('add:27+15')!,
          questionTypeId: QuestionTypeIds.trueFalse,
          random: DartRandomSource(seed: seed),
        );
        final bool isTrue = (actual.expectedAnswer as BooleanAnswer).value;
        final int shown = (actual.prompt.last as NumberToken).value;
        answers.add(isTrue);
        // Assert
        expect(shown == 42, isTrue == true);
      }
      expect(answers, <bool>{true, false});
    });
    test('varies the wrong result and never shows 0', () {
      final Set<int> wrong = <int>{};
      for (int seed = 0; seed < 40; seed++) {
        for (final String key in <String>['add:7+8', 'add:7+3']) {
          // Act
          final Question actual = domain.buildQuestion(
            item: domain.findItem(key)!,
            questionTypeId: QuestionTypeIds.trueFalse,
            random: DartRandomSource(seed: seed),
          );
          final int shown = (actual.prompt.last as NumberToken).value;
          // Assert
          expect(shown, isNot(0));
          if (key == 'add:7+8' && shown != 15) wrong.add(shown);
        }
      }
      expect(wrong.length, greaterThan(2));
    });
    test('refuses an unknown format or a foreign item', () {
      // Assert
      expect(
        () => domain.buildQuestion(
          item: domain.findItem('add:7+8')!,
          questionTypeId: QuestionTypeIds.countObjects,
          random: DartRandomSource(seed: 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => domain.buildQuestion(
          item: const _ForeignItem(),
          questionTypeId: QuestionTypeIds.multipleChoice,
          random: DartRandomSource(seed: 1),
        ),
        throwsArgumentError,
      );
      expect(() => domain.mirrorOf(const _ForeignItem()), throwsArgumentError);
    });
    test('says the operation with its words for a screen reader', () {
      // Arrange
      final AppLocalizationsFr l10n = AppLocalizationsFr();
      // Act
      final String actual = domain
          .describeItem(domain.findItem('sub:15-7')!)
          .toSpokenText(l10n);
      // Assert
      expect(actual, '15 moins 7 égale 8');
    });
  });

  group('AdditionDomain fact families', () {
    test('links 7 + 8, 8 + 7, 15 - 8 and 15 - 7', () {
      // Act
      final List<String> actual = domain
          .familyOf(domain.findItem('add:7+8')!)
          .map((ArithmeticFact fact) => fact.key)
          .toList();
      // Assert
      expect(actual, <String>['add:7+8', 'add:8+7', 'sub:15-7', 'sub:15-8']);
      expect(
        domain
            .familyOf(domain.findItem('sub:15-8')!)
            .map((ArithmeticFact fact) => fact.key)
            .toSet(),
        actual.toSet(),
      );
    });
    test('recalls the other order after a mistake', () {
      // Assert
      expect(domain.mirrorOf(domain.findItem('add:7+8')!)?.key, 'add:8+7');
      expect(domain.mirrorOf(domain.findItem('add:8+7')!)?.key, 'add:7+8');
      expect(domain.mirrorOf(domain.findItem('sub:15-7')!)?.key, 'sub:15-8');
      expect(domain.mirrorOf(domain.findItem('sub:15-8')!)?.key, 'sub:15-7');
    });
    test('recalls nothing for equal numbers or a partner not taught', () {
      // Assert
      expect(domain.mirrorOf(domain.findItem('add:5+5')!), isNull);
      expect(domain.mirrorOf(domain.findItem('add:23+14')!), isNull);
      expect(domain.mirrorOf(domain.findItem('sub:47-23')!), isNull);
    });
    test('gives every fact up to 20 a family inside its own unit', () {
      for (final String slug in <String>[
        'add5',
        'add10',
        'sub5',
        'sub10',
        'add12',
        'add14',
        'add20',
        'sub12',
        'sub14',
        'sub20',
      ]) {
        final ArithmeticUnit unit = domain.findUnit('addsub:$slug')!;
        for (final ArithmeticFact fact in unit.facts) {
          // Assert
          final ArithmeticFact? mirror = domain.mirrorOf(fact);
          if (fact.family.length == 2) {
            expect(mirror, isNull, reason: fact.key);
            continue;
          }
          expect(mirror, isNotNull, reason: fact.key);
          expect(unit.facts, contains(mirror), reason: fact.key);
        }
      }
    });
    test('teaches the subtractions of the additions of the same size', () {
      for (final (String add, String sub) in <(String, String)>[
        ('add5', 'sub5'),
        ('add10', 'sub10'),
        ('add12', 'sub12'),
        ('add14', 'sub14'),
        ('add20', 'sub20'),
      ]) {
        final Set<String> subtractions = domain
            .findUnit('addsub:$sub')!
            .items
            .map((LearningItem item) => item.key)
            .toSet();
        for (final ArithmeticFact fact
            in domain.findUnit('addsub:$add')!.items.cast<ArithmeticFact>()) {
          // Assert
          for (final ArithmeticFact member in fact.family) {
            if (!member.isAddition) {
              expect(subtractions, contains(member.key), reason: add);
            }
          }
        }
      }
    });
    test('holds every crossing of the ten and the doubles up to 9 + 9', () {
      final Set<String> keys = <String>{
        for (final String slug in <String>['add12', 'add14', 'add20'])
          ...domain
              .findUnit('addsub:$slug')!
              .items
              .map(
                (LearningItem item) => item.key,
              ),
      };
      for (int left = 2; left <= 9; left++) {
        for (int right = 2; right <= 9; right++) {
          // Assert
          final String key = 'add:$left+$right';
          expect(
            keys.contains(key),
            left + right >= 11,
            reason: key,
          );
        }
      }
      for (int double = 1; double <= 4; double++) {
        expect(domain.findItem('add:$double+$double'), isNotNull);
      }
    });
    test('keeps every unit to about 14 facts', () {
      for (final LearningUnit unit in domain.units) {
        // Assert
        expect(unit.items.length, inInclusiveRange(9, 15), reason: unit.key);
      }
    });
  });

  group('AdditionDomain help', () {
    test('lists the facts of the unit and highlights the asked one', () {
      // Act
      final ItemHelp actual = domain.helpOf(domain.findItem('add:7+8')!);
      // Assert
      expect(actual.unitFacts, hasLength(10));
      expect(actual.itemIndex, 2);
      expect(actual.unitFacts[2].toDisplayText(), '7 + 8 = 15');
    });
    test('draws a line through the ten when the addition crosses it', () {
      // Act
      final ItemHelp actual = domain.helpOf(domain.findItem('add:7+8')!);
      // Assert
      expect(
        actual.picture,
        NumberLinePicture(values: <int>[7, 10, 15], highlightIndex: 2),
      );
    });
    test('draws the line of a subtraction up to the number taken from', () {
      // Assert
      expect(
        domain.helpOf(domain.findItem('sub:15-7')!).picture,
        NumberLinePicture(values: <int>[8, 10, 15], highlightIndex: 0),
      );
      expect(
        domain.helpOf(domain.findItem('sub:7-3')!).picture,
        NumberLinePicture(values: <int>[4, 7], highlightIndex: 0),
      );
      expect(
        domain.helpOf(domain.findItem('sub:17-8')!).picture,
        NumberLinePicture(values: <int>[9, 10, 17], highlightIndex: 0),
      );
    });
    test('draws the gap to 10 for a complement', () {
      // Assert
      expect(
        domain.helpOf(domain.findItem('add:7+3')!).picture,
        NumberLinePicture(values: <int>[7, 10], highlightIndex: 1),
      );
    });
    test('draws the bundles of the result for the numbers up to 100', () {
      // Assert
      expect(
        domain.helpOf(domain.findItem('add:27+15')!).picture,
        const TenBundlesPicture(tens: 4, ones: 2),
      );
      expect(
        domain.helpOf(domain.findItem('sub:42-17')!).picture,
        const TenBundlesPicture(tens: 2, ones: 5),
      );
    });
    test('gives every fact a picture', () {
      for (final ArithmeticFact fact in allFacts) {
        // Assert
        expect(domain.helpOf(fact).picture, isNotNull, reason: fact.key);
      }
    });
  });
}
