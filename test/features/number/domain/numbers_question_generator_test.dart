import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';

void main() {
  const QuestionGenerator generator = QuestionGenerator();
  final NumbersDomain domain = NumbersDomain();
  final List<LearningItem> mixedItems = <LearningItem>[
    domain.findItem('num:count:7')!,
    domain.findItem('num:place:34')!,
    domain.findItem('num:compare:34:43')!,
    domain.findItem('num:line:8:2')!,
    domain.findItem('num:after:39')!,
  ];

  test('asks each item with the allowed types that fit it', () {
    // Act
    final List<Question> actual = generator.generate(
      domain: domain,
      items: mixedItems,
      questionTypeIds: const <String>[
        QuestionTypeIds.countObjects,
        QuestionTypeIds.tensAndOnes,
        QuestionTypeIds.numberLine,
        QuestionTypeIds.compare,
      ],
      random: DartRandomSource(seed: 3),
    );
    // Assert
    expect(actual.map((Question question) => question.questionTypeId), <String>[
      QuestionTypeIds.countObjects,
      QuestionTypeIds.tensAndOnes,
      QuestionTypeIds.compare,
      QuestionTypeIds.numberLine,
      QuestionTypeIds.numberLine,
    ]);
  });
  test('refuses an item that none of the allowed types fits', () {
    // Assert
    expect(
      () => generator.generate(
        domain: domain,
        items: mixedItems,
        questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
        random: DartRandomSource(seed: 3),
      ),
      throwsArgumentError,
    );
  });
  test('asks a planned item with the planned types that fit it', () {
    // Act
    final List<Question> actual = generator.generatePlanned(
      domain: domain,
      plans: <QuizItemPlan>[
        QuizItemPlan(
          itemKey: 'num:compare:9:6',
          questionTypeIds: const <String>[
            QuestionTypeIds.numberLine,
            QuestionTypeIds.compare,
          ],
        ),
        QuizItemPlan(
          itemKey: 'num:count:3',
          questionTypeIds: const <String>[
            QuestionTypeIds.compare,
            QuestionTypeIds.typedAnswer,
          ],
        ),
      ],
      random: DartRandomSource(seed: 3),
    );
    // Assert
    expect(actual.map((Question question) => question.questionTypeId), <String>[
      QuestionTypeIds.compare,
      QuestionTypeIds.typedAnswer,
    ]);
  });
  test('refuses types the domain never builds', () {
    // Assert
    expect(
      () => generator.generate(
        domain: domain,
        items: mixedItems,
        questionTypeIds: const <String>[QuestionTypeIds.trueFalse],
        random: DartRandomSource(seed: 3),
      ),
      throwsArgumentError,
    );
  });
}
