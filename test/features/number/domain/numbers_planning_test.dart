import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_generator.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/app_question_types.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/learning_path/domain/entities/review_key.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/stage_quiz_specs.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/quiz_item_planner.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';

/// The mastery engine plans every item of the numbers, at every box, in
/// every planned stage, with formats the generator can ask: no item is
/// ever left without a format.
void main() {
  final NumbersDomain domain = NumbersDomain();
  final Map<String, AnswerNature> natures = <String, AnswerNature>{
    for (final QuestionType type in appQuestionTypes)
      type.id: type.answerNature,
  };
  final List<LearningItem> items = <LearningItem>[
    for (final LearningUnit unit in domain.units) ...unit.items,
  ];
  const QuizItemPlanner planner = QuizItemPlanner();
  const QuestionGenerator generator = QuestionGenerator();

  Map<String, AnswerNature> naturesOf(QuizSpec spec) {
    return <String, AnswerNature>{
      for (final String id in spec.questionTypeIds)
        if (domain.questionTypeIds.contains(id)) id: natures[id]!,
    };
  }

  ItemProgressEntity progressOf(LearningItem item, int box) {
    return ItemProgressEntity(
      profileId: 'p1',
      domainId: 'numbers',
      itemKey: item.key,
      presentationCount: 3,
      correctCount: 1,
      lastAnswerTimes: const <Duration>[Duration(seconds: 4)],
      box: box,
      nextReviewAt: DateTime(2026, 10, 1),
    );
  }

  final List<QuizSpec> plannedSpecs = <QuizSpec>[
    const StageQuizSpecs().specOf(
      domain: domain,
      source: StageSource(
        unitKey: const ReviewKey(domainId: 'numbers', number: 2).toKey(),
        stage: StageKind.review,
      ),
    )!,
    const StageQuizSpecs().specOf(
      domain: domain,
      source: const StageSource(
        unitKey: 'num:beforeafter',
        stage: StageKind.boss,
      ),
    )!,
  ];

  for (final QuizSpec spec in plannedSpecs) {
    test('plans every item at every box in ${spec.sourceKey}', () {
      for (int box = 1; box <= 5; box++) {
        // Act
        final List<QuizItemPlan> actualPlans = planner.planReview(
          domain: domain,
          items: items,
          progressByKey: <String, ItemProgressEntity>{
            for (final LearningItem item in items)
              item.key: progressOf(item, box),
          },
          questionTypeNatures: naturesOf(spec),
          count: items.length,
          now: DateTime(2026, 10, 18),
          random: DartRandomSource(seed: box),
        );
        final List<Question> actualQuestions = generator.generatePlanned(
          domain: domain,
          plans: actualPlans,
          random: DartRandomSource(seed: box),
        );
        // Assert
        expect(actualQuestions, hasLength(items.length));
        for (final QuizItemPlan plan in actualPlans) {
          final List<String> itemTypes = domain.questionTypeIdsOf(
            domain.findItem(plan.itemKey)!,
          );
          expect(plan.questionTypeIds.every(itemTypes.contains), isTrue);
        }
      }
    });
  }
  test('plans the new items of a boss with formats that fit them', () {
    // Act
    final List<QuizItemPlan> actual = planner.plan(
      domain: domain,
      items: items,
      progressByKey: <String, ItemProgressEntity>{},
      questionTypeNatures: naturesOf(plannedSpecs.last),
      count: 200,
      random: DartRandomSource(seed: 3),
    );
    // Assert
    expect(
      generator.generatePlanned(
        domain: domain,
        plans: actual,
        random: DartRandomSource(seed: 3),
      ),
      hasLength(200),
    );
  });
  test('asks a comparison of a low box with its signs', () {
    // Act
    final List<QuizItemPlan> actual = planner.plan(
      domain: domain,
      items: <LearningItem>[domain.findItem('num:compare:3:8')!],
      progressByKey: <String, ItemProgressEntity>{},
      questionTypeNatures: natures,
      count: 1,
      random: DartRandomSource(seed: 1),
    );
    // Assert
    expect(actual.single.questionTypeIds, <String>['compare']);
  });
}
