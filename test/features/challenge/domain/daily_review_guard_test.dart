import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/app_question_types.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/quiz_item_planner.dart';

import '../../quiz/helpers/quiz_fixtures.dart';

/// Guards of the mixed daily review: a new domain that cannot be reviewed,
/// or that reuses an item key, fails here.
void main() {
  final List<LearningDomain> domains = buildDomainRegistry().domains;
  final Map<String, AnswerNature> natures = <String, AnswerNature>{
    for (final QuestionType type in appQuestionTypes)
      if (ChallengeRules.dailyReviewQuestionTypeIds.contains(type.id))
        type.id: type.answerNature,
  };

  test('has no item key shared by two domains', () {
    // Arrange
    final List<String> keys = <String>[
      for (final LearningDomain domain in domains)
        for (final LearningUnit unit in domain.units)
          for (final LearningItem item in unit.items) item.key,
    ];
    // Assert
    expect(keys.toSet(), hasLength(keys.length));
  });
  for (final LearningDomain domain in domains) {
    test('can review every item of ${domain.id} at every box', () {
      for (final LearningUnit unit in domain.units) {
        for (final LearningItem item in unit.items) {
          // Assert
          final Map<String, AnswerNature> fit = <String, AnswerNature>{
            for (final String id in domain.questionTypeIdsOf(item))
              if (natures.containsKey(id)) id: natures[id]!,
          };
          expect(fit, isNotEmpty, reason: item.key);
          for (int box = 1; box <= 5; box++) {
            const QuizItemPlanner planner = QuizItemPlanner();
            final QuizItemPlan plan = planner.planItem(
              domain: domain,
              progress: ItemProgressEntity(
                profileId: 'p1',
                domainId: domain.id,
                itemKey: item.key,
                presentationCount: 3,
                correctCount: 1,
                lastAnswerTimes: const <Duration>[Duration(seconds: 3)],
                box: box,
              ),
              questionTypeNatures: natures,
            );
            expect(plan.questionTypeIds, isNotEmpty, reason: item.key);
            expect(
              plan.questionTypeIds.every(fit.containsKey),
              isTrue,
              reason: '${item.key} box $box',
            );
          }
        }
      }
    });
  }
}
