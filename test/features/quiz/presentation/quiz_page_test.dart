import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/pump_localized.dart';
import '../../../helpers/recording_game_feedback.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

void main() {
  late MockQuizSessionRepository mockRepository;
  late bool isLeft;
  late String? completedSessionId;
  late RecordingGameFeedback feedback;
  late HandTicker ticker;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    feedback = RecordingGameFeedback();
    ticker = HandTicker();
    mockRepository = MockQuizSessionRepository();
    isLeft = false;
    completedSessionId = null;
    when(
      () => mockRepository.saveSession(
        session: any(named: 'session'),
        answers: any(named: 'answers'),
      ),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  Future<void> pumpQuiz(
    WidgetTester tester, {
    required String questionTypeId,
    List<String> itemKeys = const <String>['mul:5x7', 'mul:5x8'],
    bool usesScreenReader = false,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(accessibleNavigation: usesScreenReader),
          child: QuizPage(
            request: QuizRequest(
              profileId: 'profile-1',
              domainId: MultiplicationDomain.domainId,
              mode: QuizMode.freeTraining,
              itemKeys: itemKeys,
              questionTypeIds: <String>[questionTypeId],
              baseTimeLimit: QuizTimeLimits.freeTraining,
            ),
            useCases: buildTestQuizUseCases(repository: mockRepository),
            ticker: ticker,
            domains: buildDomainRegistry(),
            feedback: feedback,
            onCompleted: (String sessionId) => completedSessionId = sessionId,
            onLeft: () => isLeft = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  QuizAsking askingState(WidgetTester tester) {
    return BlocProvider.of<QuizBloc>(
          tester.element(find.byType(Scaffold)),
        ).state
        as QuizAsking;
  }

  int expectedNumber(WidgetTester tester) {
    return (askingState(tester).turn.question.expectedAnswer as NumberAnswer)
        .value;
  }

  Future<void> typeNumber(WidgetTester tester, int value) async {
    for (final String digit in '$value'.split('')) {
      await tester.tap(find.widgetWithText(InkWell, digit).first);
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  group('QuizPage', () {
    testWidgets('asks a multiple choice question and praises the answer', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.multipleChoice);
      expect(find.text('Table de 5'), findsOneWidget);
      expect(find.text('Touche la bonne réponse'), findsOneWidget);
      expect(find.bySemanticsLabel('5 fois 7 égale combien'), findsOneWidget);
      // Act
      await tester.tap(find.text('35'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Bravo !'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('Continuer'), findsNothing);
      expect(feedback.played, <GameFeedback>[GameFeedback.rightAnswer]);
      // Act: the pause of a right answer goes by.
      await passRightAnswerPause(tester, ticker);
      // Assert: the next question came by itself.
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(askingState(tester).answeredCount, 1);
    });
    testWidgets('keeps "Continuer" after a right answer for a screen reader', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        questionTypeId: QuestionTypeIds.multipleChoice,
        usesScreenReader: true,
      );
      // Act
      await tester.tap(find.text('35'));
      await tester.pumpAndSettle();
      await passRightAnswerPause(tester, ticker);
      // Assert
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('Continuer'), findsOneWidget);
    });
    testWidgets('shows the whole operation after a mistake', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.multipleChoice);
      final String inputWrong = askingState(tester).turn.question.choices
          .whereType<NumberAnswer>()
          .firstWhere((NumberAnswer choice) => choice.value != 35)
          .value
          .toString();
      // Act
      await tester.tap(find.text(inputWrong));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Presque !'), findsOneWidget);
      expect(find.text('5 × 7 = 35'), findsOneWidget);
      expect(find.text('Retiens aussi : 7 × 5 = 35'), findsOneWidget);
      expect(find.text('Pas grave, tu vas y arriver !'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsWidgets);
      expect(feedback.played, <GameFeedback>[GameFeedback.wrongAnswer]);
      // Act: a mistake waits for the child, however long.
      ticker.send(50);
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Continuer'), findsOneWidget);
    });
    testWidgets('shows the help card after two mistakes on a fact', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        questionTypeId: QuestionTypeIds.typedAnswer,
        itemKeys: const <String>['mul:5x7'],
      );
      await typeNumber(tester, 34);
      expect(find.text("Fiche d'aide · Table de 5"), findsNothing);
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      // Act
      await typeNumber(tester, 34);
      // Assert
      expect(find.text("Fiche d'aide · Table de 5"), findsOneWidget);
      expect(find.text('5 × 1 = 5'), findsOneWidget);
      expect(find.text('5 × 10 = 50'), findsOneWidget);
      expect(find.text('5 rangées de 7 points'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('5 fois 7 égale 35')),
        matchesSemantics(
          label: '5 fois 7 égale 35',
          hasSelectedState: true,
          isSelected: true,
        ),
      );
    });
    testWidgets('asks a true or false question', (WidgetTester tester) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.trueFalse);
      final bool isTrue =
          askingState(tester).turn.question.expectedAnswer ==
          const BooleanAnswer(value: true);
      expect(find.text('Vrai ou faux ?'), findsOneWidget);
      expect(find.text('Ce calcul est-il juste ?'), findsOneWidget);
      // Act
      await tester.tap(find.text(isTrue ? 'Vrai' : 'Faux'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Bravo !'), findsOneWidget);
    });
    testWidgets('lets the player type the result on the keypad', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.typedAnswer);
      expect(find.text('Valider'), findsNothing);
      // Act: the last digit sends the number.
      await typeNumber(tester, expectedNumber(tester));
      // Assert
      expect(find.text('Bravo !'), findsOneWidget);
    });
    testWidgets('lets the player write the missing number', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.missingNumber);
      expect(find.bySemanticsLabel(RegExp('combien')), findsOneWidget);
      // Act
      await typeNumber(tester, expectedNumber(tester));
      // Assert
      expect(find.text('Bravo !'), findsOneWidget);
    });
    testWidgets('celebrates a combo of 3 right answers', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        questionTypeId: QuestionTypeIds.typedAnswer,
        itemKeys: const <String>['mul:5x2', 'mul:5x3', 'mul:5x4', 'mul:5x5'],
      );
      // Act
      for (int index = 0; index < 3; index++) {
        await typeNumber(tester, expectedNumber(tester));
        if (index < 2) await passRightAnswerPause(tester, ticker);
      }
      // Assert
      expect(find.text('Combo de 3 !'), findsOneWidget);
      expect(find.text("Bravo, 3 d'affilée !"), findsOneWidget);
      expect(find.bySemanticsLabel('Combo de 3'), findsOneWidget);
    });
    testWidgets('opens the results after the last question', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        questionTypeId: QuestionTypeIds.typedAnswer,
        itemKeys: const <String>['mul:5x7'],
      );
      await typeNumber(tester, 35);
      // Act: the pause of the last right answer goes by.
      ticker.send(10);
      await tester.pump();
      await tester.pump();
      // Assert
      expect(completedSessionId, 'session-1');
    });
    testWidgets('asks before leaving, then leaves', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.multipleChoice);
      // Act
      await tester.tap(find.byTooltip('Quitter le quiz'));
      await tester.pumpAndSettle();
      expect(find.text('Quitter le quiz ?'), findsOneWidget);
      await tester.tap(find.text('Quitter'));
      await tester.pump();
      await tester.pump();
      // Assert
      expect(isLeft, isTrue);
    });
    testWidgets('stays in the quiz when the player keeps playing', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.multipleChoice);
      // Act
      await tester.tap(find.byTooltip('Quitter le quiz'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuer à jouer'));
      await tester.pumpAndSettle();
      // Assert
      expect(isLeft, isFalse);
      expect(find.text('Touche la bonne réponse'), findsOneWidget);
    });
  });
}
