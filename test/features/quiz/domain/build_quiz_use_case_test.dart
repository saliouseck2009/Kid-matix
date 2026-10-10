import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_plan_request.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';

import 'package:mocktail/mocktail.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../helpers/quiz_fixtures.dart';

final class _MockMasteryService extends Mock implements MasteryService {}

void main() {
  setUpAll(
    () => registerFallbackValue(
      QuizPlanRequest(
        profileId: '',
        domainId: '',
        itemKeys: const <String>[],
        questionTypeIds: const <String>[],
        questionCount: 0,
      ),
    ),
  );

  group('BuildQuizUseCase', () {
    test('builds one scored question per planned item, in order', () async {
      // Arrange
      final List<String> inputKeys = tableKeys(5);
      // Act
      final QuizRun actualRun = (await buildQuizUseCase()(
        params: buildParams(itemKeys: inputKeys),
      )).requireData;
      // Assert
      expect(actualRun.sessionId, 'session-1');
      expect(actualRun.startedAt, quizStart);
      expect(actualRun.scoredQuestionCount, 10);
      expect(actualRun.timeLimit, const Duration(seconds: 10));
      expect(
        actualRun.queue.map((QuizTurn turn) => turn.question.itemKey),
        inputKeys,
      );
      expect(actualRun.queue.every((QuizTurn turn) => !turn.isRetry), isTrue);
      expect(actualRun.currentTurn, actualRun.queue.first);
    });
    test('draws the questions among the allowed types', () async {
      // Arrange
      const List<String> inputTypes = <String>[
        QuestionTypeIds.multipleChoice,
        QuestionTypeIds.trueFalse,
      ];
      // Act
      final QuizRun actualRun = (await buildQuizUseCase()(
        params: buildParams(
          itemKeys: tableKeys(5),
          questionTypeIds: inputTypes,
        ),
      )).requireData;
      // Assert
      expect(
        actualRun.queue
            .map((QuizTurn turn) => turn.question.questionTypeId)
            .toSet(),
        inputTypes.toSet(),
      );
    });
    test('can build a quiz without a timer', () async {
      // Act
      final QuizRun actualRun = (await buildQuizUseCase()(
        params: buildParams(itemKeys: tableKeys(2), timeLimit: null),
      )).requireData;
      // Assert
      expect(actualRun.timeLimit, isNull);
    });
    final Map<String, BuildQuizParams> inputInvalidParams =
        <String, BuildQuizParams>{
          'an unknown domain': const BuildQuizParams(
            profileId: 'p',
            domainId: 'division',
            mode: QuizMode.freeTraining,
            itemKeys: <String>['mul:7x8'],
            questionTypeIds: <String>[QuestionTypeIds.typedAnswer],
          ),
          'an unknown item': buildParams(itemKeys: <String>['mul:7x11']),
          'no item': buildParams(itemKeys: <String>[]),
          'no supported type': buildParams(
            itemKeys: <String>['mul:7x8'],
            questionTypeIds: <String>['matchPairs'],
          ),
        };
    for (final MapEntry<String, BuildQuizParams> entry
        in inputInvalidParams.entries) {
      test('refuses ${entry.key}', () async {
        // Act
        final DataState<QuizRun> actualState = await buildQuizUseCase()(
          params: entry.value,
        );
        // Assert
        expect(actualState.exceptionOrNull, isA<ValidationException>());
      });
    }
    test('asks the mastery engine for the requested number', () async {
      // Arrange
      final _MockMasteryService mockMastery = _MockMasteryService();
      when(
        () => mockMastery.planQuiz(request: any(named: 'request')),
      ).thenAnswer(
        (_) async => DataSuccess<List<QuizItemPlan>>(<QuizItemPlan>[
          QuizItemPlan(
            itemKey: 'mul:5x3',
            questionTypeIds: const <String>[QuestionTypeIds.trueFalse],
          ),
          QuizItemPlan(
            itemKey: 'mul:5x7',
            questionTypeIds: const <String>[QuestionTypeIds.multipleChoice],
          ),
        ]),
      );
      // Act
      final QuizRun actualRun = (await buildQuizUseCase(mastery: mockMastery)(
        params: BuildQuizParams(
          profileId: 'profile-1',
          domainId: 'multiplication',
          mode: QuizMode.freeTraining,
          itemKeys: tableKeys(5),
          questionCount: 2,
          questionTypeIds: const <String>[
            QuestionTypeIds.trueFalse,
            QuestionTypeIds.multipleChoice,
          ],
        ),
      )).requireData;
      // Assert
      final QuizPlanRequest actualRequest =
          verify(
                () => mockMastery.planQuiz(
                  request: captureAny(named: 'request'),
                ),
              ).captured.single
              as QuizPlanRequest;
      expect(actualRequest.questionCount, 2);
      expect(actualRequest.itemKeys, tableKeys(5));
      expect(actualRun.scoredQuestionCount, 2);
      expect(
        actualRun.queue.map(
          (QuizTurn turn) =>
              '${turn.question.itemKey} ${turn.question.questionTypeId}',
        ),
        <String>['mul:5x3 trueFalse', 'mul:5x7 multipleChoice'],
      );
    });
    test('fails when the mastery engine cannot plan the quiz', () async {
      // Act
      final DataState<QuizRun> actualState = await buildQuizUseCase(
        mastery: FakeMasteryService(failure: const CacheException()),
      )(params: buildParams(itemKeys: tableKeys(5)));
      // Assert
      expect(actualState.exceptionOrNull, isA<CacheException>());
    });
  });
}
