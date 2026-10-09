import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/usecases/abandon_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/complete_session_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/submit_answer_params.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/quiz_fixtures.dart';

void main() {
  late MockQuizSessionRepository mockRepository;
  late FakeClock clock;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    mockRepository = MockQuizSessionRepository();
    clock = FakeClock(quizStart.add(const Duration(minutes: 2)));
    when(
      () => mockRepository.saveSession(
        session: any(named: 'session'),
        answers: any(named: 'answers'),
      ),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  Future<QuizRun> play(QuizRun run, List<bool> rightAnswers) async {
    QuizRun current = run;
    for (final bool isRight in rightAnswers) {
      final Answer expected = current.currentTurn!.question.expectedAnswer;
      current = (await buildSubmitAnswerUseCase()(
        params: SubmitAnswerParams(
          run: current,
          answer: isRight ? expected : const NumberAnswer(-1),
          answerTime: const Duration(seconds: 2),
        ),
      )).requireData.run;
    }
    return current;
  }

  group('CompleteSessionUseCase', () {
    test('saves a finished quiz with its score and answers', () async {
      // Arrange
      final QuizRun inputRun = await play(
        await buildRun(<String>['mul:5x1', 'mul:5x2']),
        <bool>[true, false, true],
      );
      final CompleteSessionUseCase useCase = CompleteSessionUseCase(
        repository: mockRepository,
        clock: clock,
      );
      // Act
      final QuizSessionEntity actualSession = (await useCase(
        params: inputRun,
      )).requireData;
      // Assert
      expect(actualSession.id, 'session-1');
      expect(actualSession.status, QuizSessionStatus.completed);
      expect(actualSession.questionCount, 2);
      expect(actualSession.correctCount, 1);
      expect(actualSession.duration, const Duration(minutes: 2));
      final List<QuizAnswerEntity> actualAnswers =
          verify(
                () => mockRepository.saveSession(
                  session: actualSession,
                  answers: captureAny(named: 'answers'),
                ),
              ).captured.single
              as List<QuizAnswerEntity>;
      expect(actualAnswers, hasLength(3));
    });
    test('refuses a quiz with questions left', () async {
      // Arrange
      final QuizRun inputRun = await buildRun(tableKeys(5));
      final CompleteSessionUseCase useCase = CompleteSessionUseCase(
        repository: mockRepository,
        clock: clock,
      );
      // Act
      final AppException? actualException = (await useCase(
        params: inputRun,
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
      verifyNever(
        () => mockRepository.saveSession(
          session: any(named: 'session'),
          answers: any(named: 'answers'),
        ),
      );
    });
  });

  group('AbandonSessionUseCase', () {
    test('keeps the answers given as an abandoned session', () async {
      // Arrange
      final QuizRun inputRun = await play(await buildRun(tableKeys(5)), <bool>[
        true,
        true,
        false,
      ]);
      final AbandonSessionUseCase useCase = AbandonSessionUseCase(
        repository: mockRepository,
        clock: clock,
      );
      // Act
      await useCase(params: inputRun);
      // Assert
      final QuizSessionEntity actualSession =
          verify(
                () => mockRepository.saveSession(
                  session: captureAny(named: 'session'),
                  answers: any(named: 'answers'),
                ),
              ).captured.single
              as QuizSessionEntity;
      expect(actualSession.status, QuizSessionStatus.abandoned);
      expect(actualSession.questionCount, 3);
      expect(actualSession.correctCount, 2);
    });
    test('saves nothing before the first answer', () async {
      // Arrange
      final AbandonSessionUseCase useCase = AbandonSessionUseCase(
        repository: mockRepository,
        clock: clock,
      );
      // Act
      final DataState<void> actualState = await useCase(
        params: await buildRun(tableKeys(5)),
      );
      // Assert
      expect(actualState, isA<DataSuccess<void>>());
      verifyNever(
        () => mockRepository.saveSession(
          session: any(named: 'session'),
          answers: any(named: 'answers'),
        ),
      );
    });
  });
}
