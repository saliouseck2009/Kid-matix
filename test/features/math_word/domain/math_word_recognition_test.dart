import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/recognition_cap.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';
import 'package:kid_matix/features/mastery/domain/usecases/record_answer_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/test_mastery_pages.dart';
import '../../mastery/helpers/mastery_fixtures.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

/// How far a recognized answer takes an item: the multiplication and the
/// numbers keep the default cap, the words have none; a sentence touched
/// is only a presentation.
void main() {
  late InMemoryItemProgressRepository repository;
  late RecordAnswerUseCase recordAnswer;

  setUp(() {
    repository = InMemoryItemProgressRepository();
    recordAnswer = RecordAnswerUseCase(
      repository: repository,
      questionTypes: buildQuestionTypeRegistry(),
      clock: StoppedClock(DateTime(2026, 10, 18)),
      domains: buildDomainRegistry(),
    );
  });

  /// Answers [times] times right, saving each one, and returns the last
  /// progress.
  Future<ItemProgressEntity> answerRight({
    required String domainId,
    required String itemKey,
    required String questionTypeId,
    int times = 8,
    bool isPresentation = false,
  }) async {
    late ItemProgressEntity progress;
    for (int index = 0; index < times; index++) {
      progress = (await recordAnswer(
        params: ItemAnswer(
          profileId: 'p1',
          domainId: domainId,
          itemKey: itemKey,
          questionTypeId: questionTypeId,
          isCorrect: true,
          answerTime: const Duration(seconds: 2),
          isPresentation: isPresentation,
        ),
      )).requireData;
      repository.progress
        ..removeWhere((ItemProgressEntity item) => item.itemKey == itemKey)
        ..add(progress);
    }
    return progress;
  }

  test('keeps the default cap of 3 for the multiplication', () async {
    // Act
    final ItemProgressEntity actual = await answerRight(
      domainId: 'multiplication',
      itemKey: 'mul:7x8',
      questionTypeId: QuestionTypeIds.multipleChoice,
    );
    // Assert
    expect(defaultRecognizedBoxCap, MasteryPolicy.recognizedBoxCap);
    expect(actual.box, 3);
  });

  test('keeps the default cap for the numbers', () async {
    // Act
    final ItemProgressEntity actual = await answerRight(
      domainId: 'numbers',
      itemKey: 'num:count:7',
      questionTypeId: QuestionTypeIds.countObjects,
    );
    // Assert
    expect(actual.box, 3);
  });

  test('lets a word climb to the last box by recognition', () async {
    // Act
    final ItemProgressEntity actual = await answerRight(
      domainId: 'math_words',
      itemKey: 'word:total',
      questionTypeId: QuestionTypeIds.listenAndTouch,
    );
    // Assert
    expect(actual.box, MasteryPolicy.lastBox);
  });

  test('still needs a right answer for each step, a miss goes back', () async {
    // Arrange
    await answerRight(
      domainId: 'math_words',
      itemKey: 'word:total',
      questionTypeId: QuestionTypeIds.listenAndTouch,
      times: 2,
    );
    // Act
    final ItemProgressEntity actual = (await recordAnswer(
      params: const ItemAnswer(
        profileId: 'p1',
        domainId: 'math_words',
        itemKey: 'word:total',
        questionTypeId: QuestionTypeIds.listenAndTouch,
        isCorrect: false,
        answerTime: Duration(seconds: 2),
      ),
    )).requireData;
    // Assert
    expect(actual.box, MasteryPolicy.firstBox);
  });

  test('records a sentence touched as presented, never as answered', () async {
    // Act
    final ItemProgressEntity actual = await answerRight(
      domainId: 'math_words',
      itemKey: 'word:il_reste',
      questionTypeId: QuestionTypeIds.touchToUnderstand,
      times: 3,
      isPresentation: true,
    );
    // Assert
    expect(actual.presentationCount, 3);
    expect(actual.correctCount, 0);
    expect(actual.box, 0);
    expect(actual.nextReviewAt, isNull);
    expect(actual.lastAnswerTimes, isEmpty);
  });

  test('does not move a word already learned when it is only shown', () async {
    // Arrange
    final ItemProgressEntity learned = await answerRight(
      domainId: 'math_words',
      itemKey: 'word:il_reste',
      questionTypeId: QuestionTypeIds.listenAndTouch,
      times: 3,
    );
    // Act
    final ItemProgressEntity actual = await answerRight(
      domainId: 'math_words',
      itemKey: 'word:il_reste',
      questionTypeId: QuestionTypeIds.touchToUnderstand,
      times: 1,
      isPresentation: true,
    );
    // Assert
    expect(actual.box, learned.box);
    expect(actual.nextReviewAt, learned.nextReviewAt);
    expect(actual.correctCount, learned.correctCount);
    expect(actual.presentationCount, learned.presentationCount + 1);
  });
}
