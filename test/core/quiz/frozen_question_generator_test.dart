import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/frozen_question_generator.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();
  final List<String> table2 = <String>[
    for (int multiplier = 1; multiplier <= 10; multiplier++)
      'mul:2x$multiplier',
  ];
  const FrozenQuestionGenerator generator = FrozenQuestionGenerator();

  List<Question> generate({
    List<String>? itemKeys,
    List<String> types = const <String>[QuestionTypeIds.multipleChoice],
    int count = 25,
    SeededDraw draw = const SeededDraw(seed: 42, version: 1),
  }) {
    return generator.generate(
      domain: domain,
      itemKeys: itemKeys ?? table2,
      questionTypeIds: types,
      questionCount: count,
      draw: draw,
    );
  }

  group('FrozenQuestionGenerator', () {
    test('the same draw gives the same questions', () {
      // Act
      final List<Question> actualFirst = generate();
      final List<Question> actualSecond = generate();
      // Assert
      expect(actualFirst, actualSecond);
      expect(actualFirst, hasLength(25));
    });
    test('another seed gives other questions', () {
      // Act
      final List<Question> actualFirst = generate();
      final List<Question> actualOther = generate(
        draw: const SeededDraw(seed: 43, version: 1),
      );
      // Assert
      expect(actualFirst, isNot(actualOther));
    });
    test('deals every item once per deck, never twice in a row', () {
      // Act
      final List<String> actualKeys = generate(
        count: 30,
      ).map((Question question) => question.itemKey).toList();
      // Assert
      for (int deck = 0; deck < 3; deck++) {
        expect(
          actualKeys.sublist(deck * 10, deck * 10 + 10).toSet(),
          table2.toSet(),
        );
      }
      for (int index = 1; index < actualKeys.length; index++) {
        expect(actualKeys[index], isNot(actualKeys[index - 1]));
      }
    });
    test('keeps only the question types of the domain', () {
      // Act
      final List<Question> actualQuestions = generate(
        types: <String>['unknown', QuestionTypeIds.trueFalse],
      );
      // Assert
      expect(
        actualQuestions.map((Question question) => question.questionTypeId),
        everyElement(QuestionTypeIds.trueFalse),
      );
    });
    test('refuses an unknown version, item or type set', () {
      // Act & Assert
      expect(FrozenQuestionGenerator.supports(1), isTrue);
      expect(FrozenQuestionGenerator.supports(2), isFalse);
      expect(
        () => generate(draw: const SeededDraw(seed: 1, version: 2)),
        throwsArgumentError,
      );
      expect(
        () => generate(itemKeys: <String>['mul:99x1']),
        throwsArgumentError,
      );
      expect(() => generate(itemKeys: <String>[]), throwsArgumentError);
      expect(() => generate(types: <String>['unknown']), throwsArgumentError);
    });
    test('a single item can be asked again and again', () {
      // Act
      final List<Question> actualQuestions = generate(
        itemKeys: <String>['mul:3x4'],
        count: 3,
      );
      // Assert
      expect(actualQuestions, hasLength(3));
    });
  });

  group('SeededDraw', () {
    test('compares by value', () {
      // Assert
      expect(
        const SeededDraw(seed: 1, version: 1),
        const SeededDraw(seed: 1, version: 1),
      );
      expect(
        const SeededDraw(seed: 1, version: 1).hashCode,
        const SeededDraw(seed: 1, version: 1).hashCode,
      );
      expect(
        const SeededDraw(seed: 1, version: 1),
        isNot(const SeededDraw(seed: 2, version: 1)),
      );
    });
  });
}
