import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../helpers/quiz_fixtures.dart';

/// A quiz that mixes the items of every domain, such as the daily review.
void main() {
  const List<String> itemKeys = <String>[
    'mul:7x8',
    'mul:6x9',
    'num:count:7',
    'num:compare:34:43',
    'add:7+8',
    'sub:15-7',
  ];
  const List<String> typeIds = <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.countObjects,
    QuestionTypeIds.compare,
  ];

  BuildQuizParams paramsOf({
    List<String> keys = itemKeys,
    int? questionCount = 6,
    SeededDraw? seededDraw,
  }) {
    return BuildQuizParams(
      profileId: 'profile-1',
      domainId: LearningDomainIds.mixed,
      mode: QuizMode.dailyReview,
      itemKeys: keys,
      questionTypeIds: typeIds,
      selection: QuizSelection.review,
      questionCount: questionCount,
      seededDraw: seededDraw,
    );
  }

  group('BuildQuizUseCase for a mixed quiz', () {
    test(
      'plans every domain at once and builds each question by its domain',
      () async {
        // Arrange
        final FakeMasteryService inputMastery = FakeMasteryService();
        // Act
        final QuizRun actualRun =
            (await buildQuizUseCase(mastery: inputMastery)(
              params: paramsOf(),
            )).requireData;
        // Assert
        expect(actualRun.domainId, LearningDomainIds.mixed);
        expect(inputMastery.planRequests, hasLength(1));
        expect(inputMastery.planRequests.single.domainId, 'mixed');
        expect(inputMastery.planRequests.single.itemKeys, itemKeys);
        final Set<String> askedKeys = actualRun.queue
            .map((turn) => turn.question.itemKey)
            .toSet();
        expect(askedKeys, containsAll(<String>['mul:7x8', 'add:7+8']));
        for (final turn in actualRun.queue) {
          final Question question = turn.question;
          expect(question.itemKey, isIn(itemKeys));
        }
      },
    );
    test('builds as many questions as the plan holds', () async {
      // Act
      final QuizRun actualRun = (await buildQuizUseCase()(
        params: paramsOf(questionCount: 3),
      )).requireData;
      // Assert
      expect(actualRun.queue, hasLength(3));
    });
    test('fails for an item no domain teaches', () async {
      // Act
      final AppException? actualException = (await buildQuizUseCase()(
        params: paramsOf(keys: <String>['mul:7x8', 'xyz:1']),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
    test('refuses a seeded draw', () async {
      // Act
      final AppException? actualException = (await buildQuizUseCase()(
        params: paramsOf(
          seededDraw: const SeededDraw(seed: 1, version: 1),
        ),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
    test('fails without any item', () async {
      // Act
      final AppException? actualException = (await buildQuizUseCase()(
        params: paramsOf(keys: <String>[]),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
  });

  group('SubmitAnswerUseCase for a mixed quiz', () {
    Future<QuizSubmission> missFirstQuestion(
      QuizRun run,
      FakeMasteryService mastery,
    ) async {
      return (await buildSubmitAnswerUseCase(mastery: mastery)(
        params: SubmitAnswerParams(
          run: run,
          answer: const NumberAnswer(9999),
          answerTime: const Duration(seconds: 3),
        ),
      )).requireData;
    }

    test('records the answer in the domain of its item', () async {
      // Arrange
      final FakeMasteryService inputMastery = FakeMasteryService();
      final QuizRun inputRun = (await buildQuizUseCase()(
        params: paramsOf(questionCount: 6),
      )).requireData;
      QuizRun run = inputRun;
      final Map<String, String> domainOfItem = <String, String>{};
      // Act
      for (int turn = 0; turn < 3; turn++) {
        final String itemKey = run.currentTurn!.question.itemKey;
        final QuizSubmission submission = await missFirstQuestion(
          run,
          inputMastery,
        );
        domainOfItem[itemKey] = inputMastery.recordedAnswers.last.domainId;
        run = submission.run;
      }
      // Assert
      for (final MapEntry<String, String> entry in domainOfItem.entries) {
        final String expectedDomain = switch (entry.key.split(':').first) {
          'mul' => 'multiplication',
          'num' => 'numbers',
          _ => 'addition',
        };
        expect(entry.value, expectedDomain, reason: entry.key);
      }
    });
    test('puts a second chance of the missed fact back in the queue', () async {
      // Arrange
      final QuizRun inputRun = (await buildQuizUseCase()(
        params: paramsOf(keys: <String>['add:7+8'], questionCount: 1),
      )).requireData;
      // Act
      final QuizSubmission actual = await missFirstQuestion(
        inputRun,
        FakeMasteryService(),
      );
      // Assert
      expect(actual.run.queue, hasLength(1));
      expect(actual.run.queue.single.isRetry, isTrue);
      expect(actual.run.queue.single.question.itemKey, 'add:7+8');
    });
  });

  group('QuizLabels in a mixed quiz', () {
    final QuizLabels labels = QuizLabels(
      domains: buildDomainRegistry(),
      l10n: AppLocalizationsFr(),
    );
    const String mixed = LearningDomainIds.mixed;

    test('names the fact of each domain', () {
      // Assert
      expect(labels.describeItem('mul:7x8', mixed), '7 × 8 = 56');
      expect(labels.describeItem('add:7+8', mixed), '7 + 8 = 15');
      expect(labels.describeItem('sub:15-7', mixed), '15 − 7 = 8');
      expect(labels.describeItem('num:compare:34:43', mixed), '34 < 43');
    });
    test('recalls the other fact of the family after a mistake', () {
      // Assert
      expect(labels.describeMirror('add:7+8', mixed), '8 + 7 = 15');
      expect(labels.describeMirror('sub:15-7', mixed), '15 − 8 = 7');
      expect(labels.describeMirror('mul:7x8', mixed), '8 × 7 = 56');
    });
    test('gives the help card and the unit name of the item domain', () {
      // Assert
      expect(labels.helpOf('add:7+8', mixed), isNotNull);
      expect(labels.helpOf('mul:7x8', mixed)?.dotGrid, isNotNull);
      final Question question = Question(
        itemKey: 'add:7+8',
        unitKey: 'addsub:add20',
        questionTypeId: QuestionTypeIds.multipleChoice,
        prompt: const <PromptToken>[],
        expectedAnswer: const NumberAnswer(15),
      );
      expect(labels.describeUnitOf(question, mixed), 'Additions jusqu\'à 20');
    });
  });
}
