import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/boss_arena.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/math_picture_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/number_line_view.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/pump_localized.dart';
import '../../../helpers/recording_game_feedback.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

void main() {
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
    required String itemKey,
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
          domainId: NumbersDomain.domainId,
          mode: isBossFight ? QuizMode.path : QuizMode.freeTraining,
          itemKeys: <String>[itemKey],
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

  int expectedNumber(WidgetTester tester) {
    return (currentQuestion(tester).expectedAnswer as NumberAnswer).value;
  }

  Future<void> typeNumber(WidgetTester tester, int value) async {
    for (final String digit in '$value'.split('')) {
      await tester.tap(find.widgetWithText(InkWell, digit).first);
      await tester.pump();
    }
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
  }

  testWidgets('counts the mangoes drawn and picks their number', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpQuiz(
      tester,
      itemKey: 'num:count:7',
      questionTypeId: QuestionTypeIds.countObjects,
    );
    // Assert
    expect(find.byType(MathPictureView), findsOneWidget);
    expect(find.bySemanticsLabel('Combien de mangues ?'), findsWidgets);
    expect(find.text('Touche la bonne réponse'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    // Act
    await tester.tap(find.text('7'));
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Bravo !'), findsOneWidget);
  });
  testWidgets('reads bundles of ten and writes their number', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpQuiz(
      tester,
      itemKey: 'num:place:34',
      questionTypeId: QuestionTypeIds.typedAnswer,
    );
    // Assert
    expect(find.text('Quel nombre ?'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '3 paquets de dix et 4 bâtonnets : quel nombre ?',
      ),
      findsOneWidget,
    );
    expect(find.text('Valider'), findsOneWidget);
    // Act
    await typeNumber(tester, 43);
    // Assert
    expect(find.text('Presque !'), findsOneWidget);
    expect(find.text('30 + 4 = 34'), findsOneWidget);
  });
  testWidgets('compares two numbers with three signs and their words', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpQuiz(
      tester,
      itemKey: 'num:compare:34:43',
      questionTypeId: QuestionTypeIds.compare,
    );
    // Assert
    expect(find.text('Plus petit, égal ou plus grand ?'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '34 est-il plus petit, égal ou plus grand que 43 ?',
      ),
      findsOneWidget,
    );
    expect(find.text('Touche le bon signe'), findsOneWidget);
    for (final String sign in <String>['<', '=', '>']) {
      expect(find.text(sign), findsOneWidget);
    }
    expect(find.text('plus petit'), findsOneWidget);
    expect(find.bySemanticsLabel('plus grand'), findsOneWidget);
    // Act
    await tester.tap(find.text('<'));
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Bravo !'), findsOneWidget);
    expect(find.text('34 < 43'), findsOneWidget);
  });
  testWidgets('shows the comparison after a wrong sign', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpQuiz(
      tester,
      itemKey: 'num:compare:58:49',
      questionTypeId: QuestionTypeIds.compare,
    );
    // Act
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Presque !'), findsOneWidget);
    expect(find.text('58 > 49'), findsOneWidget);
  });
  testWidgets('finds the number missing on a line', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpQuiz(
      tester,
      itemKey: 'num:line:8:2',
      questionTypeId: QuestionTypeIds.numberLine,
    );
    // Assert
    expect(find.byType(NumberLineView), findsOneWidget);
    expect(find.text('Quel nombre manque ?'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Droite des nombres : 2, 4, 6, nombre caché, 10. '
        'Quel nombre manque ?',
      ),
      findsOneWidget,
    );
    expect(find.text('?'), findsOneWidget);
    // Act
    await tester.tap(find.text('${expectedNumber(tester)}'));
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Bravo !'), findsOneWidget);
  });
  testWidgets('writes the number after another in the box of the line', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpQuiz(
      tester,
      itemKey: 'num:after:39',
      questionTypeId: QuestionTypeIds.typedAnswer,
    );
    // Act
    await tester.tap(find.widgetWithText(InkWell, '4').first);
    await tester.pump();
    // Assert
    expect(
      find.descendant(
        of: find.byType(NumberLineView),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );
  });
  testWidgets('shows the drawing in a boss fight', (WidgetTester tester) async {
    // Arrange
    await pumpQuiz(
      tester,
      itemKey: 'num:tens:30',
      questionTypeId: QuestionTypeIds.tensAndOnes,
      isBossFight: true,
    );
    // Assert
    expect(find.byType(BossArena), findsOneWidget);
    expect(find.byType(MathPictureView), findsOneWidget);
    expect(
      find.bySemanticsLabel('3 paquets de dix et aucun bâtonnet'),
      findsOneWidget,
    );
  });
}
