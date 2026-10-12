import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/match_pairs_answers.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/pump_localized.dart';
import '../../../helpers/recording_game_feedback.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

OperationAnswer _operation(int left, int right) {
  return OperationAnswer(<PromptToken>[
    NumberToken(left),
    const OperatorToken(MathOperator.multiply),
    NumberToken(right),
  ]);
}

QuestionPair _pair(int left, int right) {
  return QuestionPair(
    itemKey: 'mul:${left}x$right',
    operation: _operation(left, right),
    result: NumberAnswer(left * right),
  );
}

final List<QuestionPair> _pairs = <QuestionPair>[
  _pair(3, 4),
  _pair(3, 6),
  _pair(3, 9),
  _pair(3, 5),
];

const List<Answer> _results = <Answer>[
  NumberAnswer(15),
  NumberAnswer(12),
  NumberAnswer(27),
  NumberAnswer(18),
];

void main() {
  group('MatchPairsAnswers', () {
    late List<Answer> matched;

    setUp(() => matched = <Answer>[]);

    Future<void> pumpBoard(WidgetTester tester, {bool isJudged = false}) async {
      tester.view.physicalSize = const Size(1170, 2532);
      addTearDown(tester.view.reset);
      await pumpLocalized(
        tester,
        Scaffold(
          body: MatchPairsAnswers(
            pairs: _pairs,
            results: _results,
            onMatched: isJudged ? null : matched.add,
          ),
        ),
      );
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      await tester.tap(find.text(text));
      await tester.pump();
    }

    testWidgets('shows the operations, the results and what to do', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpBoard(tester);
      // Assert
      expect(
        find.text('Relie chaque opération à son résultat'),
        findsOneWidget,
      );
      expect(find.text('Aucune paire trouvée sur 4'), findsOneWidget);
      expect(find.text('3 × 4'), findsOneWidget);
      expect(find.text('27'), findsOneWidget);
      expect(
        find.text('Touche une opération, puis son résultat'),
        findsOneWidget,
      );
    });
    testWidgets('keeps a right pair green and counts it', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpBoard(tester);
      // Act
      await tapText(tester, '3 × 4');
      // Assert
      expect(
        find.text('Touche maintenant le résultat de 3 × 4'),
        findsOneWidget,
      );
      // Act
      await tapText(tester, '12');
      // Assert
      expect(find.text('1 paire trouvée sur 4'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      expect(find.bySemanticsLabel('3 fois 4, paire trouvée'), findsOneWidget);
      expect(matched, isEmpty);
    });
    testWidgets('starts from a result as well', (WidgetTester tester) async {
      // Arrange
      await pumpBoard(tester);
      // Act
      await tapText(tester, '18');
      // Assert
      expect(
        find.text("Touche maintenant l'opération qui donne 18"),
        findsOneWidget,
      );
      // Act
      await tapText(tester, '3 × 6');
      // Assert
      expect(find.text('1 paire trouvée sur 4'), findsOneWidget);
    });
    testWidgets('shakes a wrong pair and lets the player try again', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpBoard(tester);
      await tapText(tester, '3 × 4');
      // Act
      await tapText(tester, '15');
      // Assert
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('Aucune paire trouvée sur 4'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(
        find.text('Touche maintenant le résultat de 3 × 4'),
        findsOneWidget,
      );
      // Act
      await tapText(tester, '12');
      // Assert
      expect(find.text('1 paire trouvée sur 4'), findsOneWidget);
    });
    testWidgets('answers once every pair is found, naming the misses', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpBoard(tester);
      await tapText(tester, '15');
      await tapText(tester, '3 × 9');
      await tester.pumpAndSettle();
      // Act: 15 stays selected after the mistake.
      await tapText(tester, '3 × 5');
      for (final (String operation, String result) in <(String, String)>[
        ('3 × 4', '12'),
        ('3 × 6', '18'),
        ('3 × 9', '27'),
      ]) {
        await tapText(tester, operation);
        await tapText(tester, result);
      }
      // Assert
      expect(matched, <Answer>[
        PairsAnswer(missedItemKeys: <String>{'mul:3x9'}),
      ]);
    });
    testWidgets('answers right when no pairing failed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpBoard(tester);
      // Act
      for (final (String operation, String result) in <(String, String)>[
        ('3 × 4', '12'),
        ('3 × 6', '18'),
        ('3 × 9', '27'),
        ('3 × 5', '15'),
      ]) {
        await tapText(tester, operation);
        await tapText(tester, result);
      }
      // Assert
      expect(matched, <Answer>[PairsAnswer()]);
      expect(find.text('4 paires trouvées sur 4'), findsOneWidget);
    });
    testWidgets('changes the selection on the same side', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpBoard(tester);
      await tapText(tester, '3 × 4');
      // Act
      await tapText(tester, '3 × 6');
      // Assert
      expect(
        find.text('Touche maintenant le résultat de 3 × 6'),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('3 fois 6')),
        isSemantics(
          label: '3 fois 6',
          isButton: true,
          hasTapAction: true,
          isSelected: true,
        ),
      );
    });
    testWidgets('shows every pair found once the answer is judged', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpBoard(tester, isJudged: true);
      // Assert
      expect(find.text('4 paires trouvées sur 4'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(8));
      expect(
        find.text('Touche une opération, puis son résultat'),
        findsNothing,
      );
    });
  });

  group('QuizPage with the formats of version 1.1', () {
    late MockQuizSessionRepository mockRepository;

    setUpAll(registerQuizFallbacks);

    setUp(() {
      mockRepository = MockQuizSessionRepository();
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
      bool isBossFight = false,
    }) async {
      tester.view.physicalSize = const Size(1170, 2532);
      addTearDown(tester.view.reset);
      await pumpLocalized(
        tester,
        QuizPage(
          request: QuizRequest(
            profileId: 'profile-1',
            domainId: MultiplicationDomain.domainId,
            mode: isBossFight ? QuizMode.path : QuizMode.freeTraining,
            itemKeys: const <String>['mul:4x6', 'mul:5x8'],
            questionTypeIds: <String>[questionTypeId],
            baseTimeLimit: QuizTimeLimits.freeTraining,
            isBossFight: isBossFight,
          ),
          useCases: buildTestQuizUseCases(repository: mockRepository),
          ticker: const SilentTicker(),
          domains: buildDomainRegistry(),
          feedback: RecordingGameFeedback(),
          onCompleted: (_) {},
          onLeft: () {},
        ),
      );
      await tester.pumpAndSettle();
    }

    Question currentQuestion(WidgetTester tester) {
      return (BlocProvider.of<QuizBloc>(
                tester.element(find.byType(Scaffold)),
              ).state
              as QuizAsking)
          .turn
          .question;
    }

    testWidgets('asks which multiplication gives the result', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.findOperation);
      expect(find.text('Quelle multiplication donne'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('Touche la bonne opération'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Quelle multiplication donne 24 ?'),
        findsOneWidget,
      );
      // Act
      await tester.tap(find.text('4 × 6'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Bravo\u00a0!'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
    testWidgets('shows the fact after a wrong operation', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.findOperation);
      final Answer inputWrong = currentQuestion(tester).choices.firstWhere(
        (Answer choice) => choice != currentQuestion(tester).expectedAnswer,
      );
      final String inputLabel = (inputWrong as OperationAnswer).operation
          .map(
            (PromptToken token) =>
                token is NumberToken ? '${token.value}' : '×',
          )
          .join(' ');
      // Act
      await tester.tap(find.text(inputLabel));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Presque\u00a0!'), findsOneWidget);
      expect(find.text('4 × 6 = 24'), findsOneWidget);
    });
    testWidgets('matches the pairs, then judges the whole question', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.matchPairs);
      final List<QuestionPair> inputPairs = currentQuestion(tester).pairs;
      expect(
        find.text('Relie chaque opération à son résultat'),
        findsOneWidget,
      );
      // Act
      for (final QuestionPair pair in inputPairs) {
        await tester.tap(find.text(_labelOf(pair.operation)));
        await tester.pump();
        await tester.tap(find.text(_labelOf(pair.result)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Bravo\u00a0!'), findsOneWidget);
      expect(find.text('4 paires trouvées sur 4'), findsOneWidget);
      expect(find.text('Continuer'), findsOneWidget);
    });
    testWidgets('hits the boss once the pairs are matched', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        questionTypeId: QuestionTypeIds.matchPairs,
        isBossFight: true,
      );
      final List<QuestionPair> inputPairs = currentQuestion(tester).pairs;
      expect(find.byType(MonsterIllustration), findsNothing);
      // Act
      for (final QuestionPair pair in inputPairs) {
        await tester.tap(find.text(_labelOf(pair.operation)));
        await tester.pump();
        await tester.tap(find.text(_labelOf(pair.result)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(MonsterIllustration), findsOneWidget);
      // The silent ticker answers in no time: a critical hit.
      expect(find.text('10 / 12'), findsOneWidget);
      expect(find.text('Bravo\u00a0!'), findsOneWidget);
    });
    testWidgets('names the fact of a wrong pair in the feedback', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.matchPairs);
      final List<QuestionPair> inputPairs = currentQuestion(tester).pairs;
      await tester.tap(find.text(_labelOf(inputPairs[0].operation)));
      await tester.pump();
      await tester.tap(find.text(_labelOf(inputPairs[1].result)));
      await tester.pumpAndSettle();
      // Act
      for (final QuestionPair pair in inputPairs) {
        await tester.tap(find.text(_labelOf(pair.operation)));
        await tester.pump();
        await tester.tap(find.text(_labelOf(pair.result)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Presque\u00a0!'), findsOneWidget);
      final String expectedFact =
          '${_labelOf(inputPairs[0].operation)} = '
          '${_labelOf(inputPairs[0].result)}';
      expect(find.text(expectedFact), findsOneWidget);
    });
  });
}

String _labelOf(Answer answer) {
  return switch (answer) {
    NumberAnswer(:final int value) => '$value',
    OperationAnswer(:final List<PromptToken> operation) =>
      operation
          .map(
            (PromptToken token) =>
                token is NumberToken ? '${token.value}' : '×',
          )
          .join(' '),
    _ => '',
  };
}
