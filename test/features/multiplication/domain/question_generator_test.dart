import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

const QuestionGenerator _generator = QuestionGenerator();

final MultiplicationDomain _domain = MultiplicationDomain();

List<LearningItem> _tableOf(int number) => _domain.tables[number - 1].facts;

List<Question> _generate({
  required List<LearningItem> items,
  int seed = 7,
  List<String> questionTypeIds = const <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
    QuestionTypeIds.trueFalse,
  ],
}) {
  return _generator.generate(
    domain: _domain,
    items: items,
    questionTypeIds: questionTypeIds,
    random: DartRandomSource(seed: seed),
  );
}

void main() {
  group('QuestionGenerator', () {
    test('asks one question per item, in the given order', () {
      // Arrange
      final List<LearningItem> inputItems = _tableOf(7);
      // Act
      final List<Question> actualQuestions = _generate(items: inputItems);
      // Assert
      expect(
        actualQuestions.map((Question question) => question.itemKey),
        inputItems.map((LearningItem item) => item.key),
      );
    });
    test('gives the same questions with the same seed', () {
      // Arrange
      final List<LearningItem> inputItems = <LearningItem>[
        ..._tableOf(7),
        ..._tableOf(8),
      ];
      // Act
      final List<Question> actualFirst = _generate(items: inputItems);
      final List<Question> actualSecond = _generate(items: inputItems);
      // Assert
      expect(actualFirst, actualSecond);
    });
    test('gives other questions with another seed', () {
      // Arrange
      final List<LearningItem> inputItems = _tableOf(7);
      // Act
      final List<Question> actualFirst = _generate(items: inputItems);
      final List<Question> actualSecond = _generate(
        items: inputItems,
        seed: 8,
      );
      // Assert
      expect(actualFirst, isNot(actualSecond));
    });
    test('never asks the same fact twice in a row', () {
      // Arrange
      const MultiplicationFact inputA = MultiplicationFact(
        table: 7,
        multiplier: 8,
      );
      const MultiplicationFact inputB = MultiplicationFact(
        table: 6,
        multiplier: 9,
      );
      const MultiplicationFact inputC = MultiplicationFact(
        table: 3,
        multiplier: 4,
      );
      // Act
      final List<String> actualKeys = _generate(
        items: const <LearningItem>[inputA, inputA, inputB, inputB, inputC],
      ).map((Question question) => question.itemKey).toList();
      // Assert
      expect(actualKeys, <String>[
        'mul:7x8',
        'mul:6x9',
        'mul:7x8',
        'mul:6x9',
        'mul:3x4',
      ]);
    });
    test('uses only the allowed question types, all of them in time', () {
      // Arrange
      const List<String> inputTypes = <String>[
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
      ];
      // Act
      final Set<String> actualTypes = _generate(
        items: <LearningItem>[..._tableOf(3), ..._tableOf(4)],
        questionTypeIds: inputTypes,
      ).map((Question question) => question.questionTypeId).toSet();
      // Assert
      expect(actualTypes, inputTypes.toSet());
    });
    test('ignores the types the domain does not support', () {
      // Act
      final Set<String> actualTypes = _generate(
        items: _tableOf(2),
        questionTypeIds: const <String>[
          'matchPairs',
          QuestionTypeIds.multipleChoice,
        ],
      ).map((Question question) => question.questionTypeId).toSet();
      // Assert
      expect(actualTypes, <String>{QuestionTypeIds.multipleChoice});
    });
    test('refuses when no allowed type is supported', () {
      // Act
      List<Question> actualGenerate() => _generate(
        items: _tableOf(2),
        questionTypeIds: const <String>['matchPairs'],
      );
      // Assert
      expect(actualGenerate, throwsArgumentError);
    });
    test('asks nothing for no item', () {
      // Act
      final List<Question> actualQuestions = _generate(
        items: const <LearningItem>[],
      );
      // Assert
      expect(actualQuestions, isEmpty);
    });
  });
}
