import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/question_types/app_question_types.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_answer.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';
import 'package:kid_matix/features/mastery/domain/services/quiz_item_planner.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';

import '../helpers/math_word_fixtures.dart';

/// The words follow the spaced repetition like any other item.
void main() {
  final MathWordDomain domain = buildMathWordDomain();
  const MasteryPolicy policy = MasteryPolicy();
  const QuizItemPlanner planner = QuizItemPlanner();
  final DateTime now = DateTime(2026, 10, 18);
  final Map<String, AnswerNature> natures = <String, AnswerNature>{
    for (final type in appQuestionTypes) type.id: type.answerNature,
  };

  ItemProgressEntity answer(
    ItemProgressEntity progress, {
    required bool isCorrect,
    required AnswerNature nature,
  }) {
    return policy.apply(
      progress: progress,
      answer: MasteryAnswer(
        isCorrect: isCorrect,
        answerNature: nature,
        answerTime: const Duration(seconds: 2),
      ),
      now: now,
    );
  }

  ItemProgressEntity notSeen(MathWord word) {
    return ItemProgressEntity.notSeen(
      profileId: 'p1',
      domainId: domain.id,
      itemKey: word.key,
    );
  }

  test('puts a word right at first in box 2, and sends a miss to box 1', () {
    // Arrange
    final MathWord word = domain.catalog.wordOf('il_reste')!;
    // Act
    final ItemProgressEntity right = answer(
      notSeen(word),
      isCorrect: true,
      nature: AnswerNature.recognized,
    );
    final ItemProgressEntity missed = answer(
      right,
      isCorrect: false,
      nature: AnswerNature.recognized,
    );
    // Assert
    expect(right.box, MasteryPolicy.firstRightBox);
    expect(right.nextReviewAt, DateTime(2026, 10, 20));
    expect(missed.box, MasteryPolicy.firstBox);
    expect(missed.nextReviewAt, DateTime(2026, 10, 19));
  });

  test('keeps a word picked among drawings below the acquired boxes', () {
    // Arrange
    ItemProgressEntity progress = notSeen(domain.catalog.wordOf('total')!);
    // Act
    for (int index = 0; index < 8; index++) {
      progress = answer(
        progress,
        isCorrect: true,
        nature: AnswerNature.recognized,
      );
    }
    // Assert
    expect(progress.box, MasteryPolicy.recognizedBoxCap);
    expect(
      domain.questionTypeIdsOf(domain.catalog.wordOf('total')!),
      isNot(contains(QuestionTypeIds.whichOperation)),
    );
  });

  test('lets the operation of a statement take a word to the last box', () {
    // Arrange
    ItemProgressEntity progress = notSeen(domain.catalog.wordOf('il_reste')!);
    // Act
    for (int index = 0; index < 8; index++) {
      progress = answer(
        progress,
        isCorrect: true,
        nature: AnswerNature.produced,
      );
    }
    // Assert
    expect(progress.box, MasteryPolicy.lastBox);
  });

  test('asks a word of a high box the operation, when it has one', () {
    // Arrange
    final MathWord word = domain.catalog.wordOf('il_reste')!;
    final ItemProgressEntity progress = ItemProgressEntity(
      profileId: 'p1',
      domainId: domain.id,
      itemKey: word.key,
      presentationCount: 5,
      correctCount: 4,
      lastAnswerTimes: const <Duration>[Duration(seconds: 3)],
      box: 4,
      nextReviewAt: DateTime(2026, 10, 1),
    );
    // Act
    final List<QuizItemPlan> actualPlans = planner.planReview(
      domain: domain,
      items: <MathWord>[word],
      progressByKey: <String, ItemProgressEntity>{word.key: progress},
      questionTypeNatures: <String, AnswerNature>{
        for (final String id in domain.questionTypeIdsOf(word))
          id: natures[id]!,
      },
      count: 1,
      now: now,
      random: DartRandomSource(seed: 1),
    );
    // Assert
    expect(actualPlans.single.questionTypeIds, <String>[
      QuestionTypeIds.whichOperation,
    ]);
  });

  test('asks a word with no statement still, whatever its box', () {
    // Arrange
    final MathWord word = domain.catalog.wordOf('total')!;
    final ItemProgressEntity progress = ItemProgressEntity(
      profileId: 'p1',
      domainId: domain.id,
      itemKey: word.key,
      presentationCount: 5,
      correctCount: 4,
      lastAnswerTimes: const <Duration>[Duration(seconds: 3)],
      box: 5,
      nextReviewAt: DateTime(2026, 10, 1),
    );
    // Act
    final List<QuizItemPlan> actualPlans = planner.planReview(
      domain: domain,
      items: <MathWord>[word],
      progressByKey: <String, ItemProgressEntity>{word.key: progress},
      questionTypeNatures: <String, AnswerNature>{
        for (final String id in domain.questionTypeIdsOf(word))
          id: natures[id]!,
      },
      count: 1,
      now: now,
      random: DartRandomSource(seed: 1),
    );
    // Assert
    expect(actualPlans.single.questionTypeIds, isNotEmpty);
    expect(
      actualPlans.single.questionTypeIds.every(
        domain.questionTypeIdsOf(word).contains,
      ),
      isTrue,
    );
  });
}
