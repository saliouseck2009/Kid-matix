import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/pages/results_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/quiz_fixtures.dart';

QuizAnswerEntity _answer(String itemKey, {bool isCorrect = true}) {
  return QuizAnswerEntity(
    itemKey: itemKey,
    questionTypeId: 'typedAnswer',
    isCorrect: isCorrect,
    isTimedOut: false,
    isRetry: false,
    answerTime: const Duration(milliseconds: 2400),
  );
}

QuizResultEntity _buildResult({required bool hasMistake}) {
  return QuizResultEntity(
    session: QuizSessionEntity(
      id: 's1',
      profileId: 'p1',
      domainId: 'multiplication',
      mode: QuizMode.freeTraining,
      status: QuizSessionStatus.completed,
      startedAt: quizStart,
      duration: const Duration(minutes: 1),
      questionCount: 10,
      correctCount: hasMistake ? 9 : 10,
    ),
    answers: <QuizAnswerEntity>[
      for (int multiplier = 1; multiplier <= 10; multiplier++)
        _answer(
          'mul:5x$multiplier',
          isCorrect: !hasMistake || multiplier != 8,
        ),
    ],
  );
}

void main() {
  late MockQuizSessionRepository mockRepository;
  late bool isContinued;
  late String? replayedUnit;

  setUp(() {
    mockRepository = MockQuizSessionRepository();
    isContinued = false;
    replayedUnit = null;
  });

  Future<void> pumpResults(
    WidgetTester tester,
    DataState<QuizResultEntity> state,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    when(
      () => mockRepository.getResult(sessionId: any(named: 'sessionId')),
    ).thenAnswer((_) async => state);
    await pumpLocalized(
      tester,
      ResultsPage(
        sessionId: 's1',
        getResult: GetQuizResultUseCase(repository: mockRepository),
        domains: buildDomainRegistry(),
        onContinue: () => isContinued = true,
        onReplay: (String unitKey) => replayedUnit = unitKey,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ResultsPage', () {
    testWidgets('shows the score, the average time and the facts to review', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpResults(
        tester,
        DataSuccess<QuizResultEntity>(_buildResult(hasMistake: true)),
      );
      // Assert
      expect(find.text('Partie terminée !'), findsOneWidget);
      expect(find.text('Table de 5 · Entraînement libre'), findsOneWidget);
      expect(find.text('9 / 10'), findsOneWidget);
      expect(find.text('réussies'), findsOneWidget);
      expect(find.text('2,4\u00a0s'), findsOneWidget);
      expect(find.text('5 × 8 = 40'), findsOneWidget);
    });
    testWidgets('congratulates a quiz without mistakes', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpResults(
        tester,
        DataSuccess<QuizResultEntity>(_buildResult(hasMistake: false)),
      );
      // Assert
      expect(find.text('Aucune erreur, bravo !'), findsOneWidget);
    });
    testWidgets('continues or replays the same table', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpResults(
        tester,
        DataSuccess<QuizResultEntity>(_buildResult(hasMistake: true)),
      );
      // Act
      await tester.tap(find.text('Rejouer'));
      await tester.tap(find.text('Continuer'));
      // Assert
      expect(replayedUnit, 'mul:5');
      expect(isContinued, isTrue);
    });
    testWidgets('explains a session that cannot be read', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpResults(
        tester,
        const DataFailed<QuizResultEntity>(CacheException()),
      );
      // Assert
      expect(
        find.text("Oups, on n'a pas pu lire ou enregistrer tes données."),
        findsOneWidget,
      );
    });
  });
}
