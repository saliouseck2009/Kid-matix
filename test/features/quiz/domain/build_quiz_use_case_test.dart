import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_mode.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/quiz_fixtures.dart';

void main() {
  group('BuildQuizUseCase', () {
    test('builds one scored question per item, in order', () async {
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
  });
}
