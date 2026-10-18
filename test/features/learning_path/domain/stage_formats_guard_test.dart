import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/app_question_types.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_definition.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/quiz_item_planner.dart';

import '../../quiz/helpers/quiz_fixtures.dart';

/// Guard of the stage formats, now that the question generator refuses
/// an item no allowed format fits: every stage of the learning path,
/// boss and review included, offers each item of every domain at least
/// one of its formats, and the mastery engine plans every item with one
/// at every box. A new domain or a new stage that breaks this fails here.
void main() {
  final Map<String, AnswerNature> natures = <String, AnswerNature>{
    for (final QuestionType type in appQuestionTypes)
      type.id: type.answerNature,
  };
  final List<StageDefinition> stages = <StageDefinition>[
    ...StageDefinition.tableStages,
    StageDefinition.review,
  ];
  const QuizItemPlanner planner = QuizItemPlanner();

  List<LearningItem> itemsOf(LearningDomain domain) {
    return <LearningItem>[
      for (final LearningUnit unit in domain.units) ...unit.items,
    ];
  }

  Map<String, AnswerNature> naturesOf(
    LearningDomain domain,
    StageDefinition stage,
  ) {
    return <String, AnswerNature>{
      for (final String id in stage.questionTypeIds)
        if (domain.questionTypeIds.contains(id)) id: natures[id]!,
    };
  }

  ItemProgressEntity progressOf(
    LearningDomain domain,
    LearningItem item,
    int box,
  ) {
    return ItemProgressEntity(
      profileId: 'p1',
      domainId: domain.id,
      itemKey: item.key,
      presentationCount: 3,
      correctCount: 1,
      lastAnswerTimes: const <Duration>[Duration(seconds: 4)],
      box: box,
      nextReviewAt: DateTime(2026, 10, 1),
    );
  }

  void expectFit(LearningDomain domain, List<QuizItemPlan> plans) {
    for (final QuizItemPlan plan in plans) {
      final List<String> itemTypes = domain.questionTypeIdsOf(
        domain.findItem(plan.itemKey)!,
      );
      expect(plan.questionTypeIds, isNotEmpty, reason: plan.itemKey);
      expect(
        plan.questionTypeIds.every(itemTypes.contains),
        isTrue,
        reason: '${plan.itemKey} ${plan.questionTypeIds}',
      );
    }
  }

  for (final LearningDomain domain in buildDomainRegistry().domains) {
    for (final StageDefinition stage in stages) {
      final String name = '${domain.id} ${stage.kind.name}';

      test('offers every item of $name one of its formats', () {
        for (final LearningItem item in itemsOf(domain)) {
          // Assert
          expect(
            stage.questionTypeIds.any(domain.questionTypeIdsOf(item).contains),
            isTrue,
            reason: item.key,
          );
        }
      });
      test('plans every item of $name with a format at every box', () {
        final List<LearningItem> items = itemsOf(domain);
        // Act
        final List<QuizItemPlan> actualNew = planner.plan(
          domain: domain,
          items: items,
          progressByKey: const <String, ItemProgressEntity>{},
          questionTypeNatures: naturesOf(domain, stage),
          count: items.length,
          random: DartRandomSource(seed: 1),
        );
        // Assert
        expectFit(domain, actualNew);
        for (int box = 1; box <= 5; box++) {
          // Act
          final List<QuizItemPlan> actualSeen = planner.planReview(
            domain: domain,
            items: items,
            progressByKey: <String, ItemProgressEntity>{
              for (final LearningItem item in items)
                item.key: progressOf(domain, item, box),
            },
            questionTypeNatures: naturesOf(domain, stage),
            count: items.length,
            now: DateTime(2026, 10, 18),
            random: DartRandomSource(seed: box),
          );
          // Assert
          expect(actualSeen, hasLength(items.length));
          expectFit(domain, actualSeen);
        }
      });
    }
  }
}
