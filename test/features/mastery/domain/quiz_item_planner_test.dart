import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/quiz_item_planner.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

const QuizItemPlanner _planner = QuizItemPlanner();
const Map<String, AnswerNature> _allTypes = <String, AnswerNature>{
  QuestionTypeIds.multipleChoice: AnswerNature.recognized,
  QuestionTypeIds.typedAnswer: AnswerNature.produced,
  QuestionTypeIds.missingNumber: AnswerNature.produced,
  QuestionTypeIds.trueFalse: AnswerNature.recognized,
};

ItemProgressEntity _progress(String itemKey, int box) {
  return ItemProgressEntity.notSeen(
    profileId: 'p1',
    domainId: 'multiplication',
    itemKey: itemKey,
  ).copyWith(box: box);
}

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();
  final List<LearningItem> tableOfSeven = domain.findUnit('mul:7')!.items;

  Map<String, int> countDraws(
    Map<String, ItemProgressEntity> progressByKey, {
    int count = 6000,
  }) {
    final List<QuizItemPlan> plans = _planner.plan(
      domain: domain,
      items: tableOfSeven,
      progressByKey: progressByKey,
      questionTypeNatures: _allTypes,
      count: count,
      random: DartRandomSource(seed: 7),
    );
    final Map<String, int> counts = <String, int>{};
    for (final QuizItemPlan plan in plans) {
      counts.update(plan.itemKey, (int value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  group('QuizItemPlanner.plan', () {
    test('gives the same plan for the same seed', () {
      // Act
      List<QuizItemPlan> planWithSeed(int seed) => _planner.plan(
        domain: domain,
        items: tableOfSeven,
        progressByKey: const <String, ItemProgressEntity>{},
        questionTypeNatures: _allTypes,
        count: 10,
        random: DartRandomSource(seed: seed),
      );
      final List<QuizItemPlan> actualFirst = planWithSeed(3);
      final List<QuizItemPlan> actualSecond = planWithSeed(3);
      // Assert
      expect(actualFirst, hasLength(10));
      expect(actualSecond, actualFirst);
    });
    test('draws the items of low boxes more often', () {
      // Arrange
      final Map<String, ItemProgressEntity> inputProgress =
          <String, ItemProgressEntity>{
            for (final LearningItem item in tableOfSeven)
              item.key: _progress(item.key, 5),
            'mul:7x8': _progress('mul:7x8', 1),
          };
      // Act
      final Map<String, int> actualCounts = countDraws(inputProgress);
      // Assert: box 1 weighs 5 times box 5.
      final double actualRatio =
          actualCounts['mul:7x8']! / actualCounts['mul:7x6']!;
      expect(actualRatio, closeTo(5, 1));
    });
    test('draws the facts x 1 and x 10 half as often', () {
      // Act
      final Map<String, int> actualCounts = countDraws(
        const <String, ItemProgressEntity>{},
      );
      // Assert
      final double actualRatio =
          actualCounts['mul:7x1']! / actualCounts['mul:7x8']!;
      expect(actualRatio, closeTo(0.5, 0.1));
      expect(actualCounts['mul:7x10']! / actualCounts['mul:7x8']!, lessThan(1));
    });
    test('plans nothing without items', () {
      // Act
      final List<QuizItemPlan> actualPlans = _planner.plan(
        domain: domain,
        items: const <LearningItem>[],
        progressByKey: const <String, ItemProgressEntity>{},
        questionTypeNatures: _allTypes,
        count: 10,
        random: DartRandomSource(seed: 1),
      );
      // Assert
      expect(actualPlans, isEmpty);
    });
    test('asks a new item with answers to pick and a box 4 one written', () {
      // Arrange
      final Map<String, ItemProgressEntity> inputProgress =
          <String, ItemProgressEntity>{
            for (final LearningItem item in tableOfSeven)
              item.key: _progress(item.key, 4),
          };
      // Act
      final List<QuizItemPlan> actualNew = _planner.plan(
        domain: domain,
        items: tableOfSeven,
        progressByKey: const <String, ItemProgressEntity>{},
        questionTypeNatures: _allTypes,
        count: 3,
        random: DartRandomSource(seed: 1),
      );
      final List<QuizItemPlan> actualKnown = _planner.plan(
        domain: domain,
        items: tableOfSeven,
        progressByKey: inputProgress,
        questionTypeNatures: _allTypes,
        count: 3,
        random: DartRandomSource(seed: 1),
      );
      // Assert
      for (final QuizItemPlan plan in actualNew) {
        expect(plan.questionTypeIds, <String>[
          QuestionTypeIds.multipleChoice,
          QuestionTypeIds.trueFalse,
        ]);
      }
      for (final QuizItemPlan plan in actualKnown) {
        expect(plan.questionTypeIds, <String>[
          QuestionTypeIds.typedAnswer,
          QuestionTypeIds.missingNumber,
        ]);
      }
    });
  });

  group('QuizItemPlanner.questionTypesFor', () {
    test('picks answers up to box 2 and writes them from box 3', () {
      // Act
      final List<List<String>> actualTypes = <int>[0, 1, 2, 3, 5]
          .map(
            (int box) => _planner.questionTypesFor(
              box: box,
              questionTypeNatures: _allTypes,
            ),
          )
          .toList();
      // Assert
      const List<String> expectedPicked = <String>[
        QuestionTypeIds.multipleChoice,
        QuestionTypeIds.trueFalse,
      ];
      const List<String> expectedWritten = <String>[
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
      ];
      expect(actualTypes, <List<String>>[
        expectedPicked,
        expectedPicked,
        expectedPicked,
        expectedWritten,
        expectedWritten,
      ]);
    });
    test('falls back to every allowed type when none fits the box', () {
      // Arrange
      const Map<String, AnswerNature> inputTypes = <String, AnswerNature>{
        QuestionTypeIds.multipleChoice: AnswerNature.recognized,
      };
      // Act
      final List<String> actualTypes = _planner.questionTypesFor(
        box: 4,
        questionTypeNatures: inputTypes,
      );
      // Assert
      expect(actualTypes, <String>[QuestionTypeIds.multipleChoice]);
    });
  });
}
