import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/question_card.dart';

import '../../../helpers/pump_localized.dart';

void main() {
  const List<PromptToken> inputPrompt = <PromptToken>[
    NumberToken(5),
    OperatorToken(MathOperator.multiply),
    NumberToken(7),
    EqualsToken(),
    BlankToken(),
  ];

  Future<void> pumpCard(
    WidgetTester tester, {
    String? spokenText,
    bool asksOperation = false,
  }) async {
    await pumpLocalized(
      tester,
      Scaffold(
        body: SizedBox(
          width: 360,
          height: 360,
          child: QuestionCard(
            label: 'Table de 5',
            prompt: inputPrompt,
            asksOperation: asksOperation,
            spokenText: spokenText,
          ),
        ),
      ),
    );
  }

  group('QuestionCard semantics', () {
    testWidgets('keeps the label of a plain operation for a screen reader', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpCard(tester, spokenText: '5 fois 7 égale combien');
      // Assert
      expect(find.bySemanticsLabel('Table de 5'), findsOneWidget);
      expect(find.bySemanticsLabel('5 fois 7 égale combien'), findsOneWidget);
    });
    testWidgets('says a question that asks the operation as one sentence', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpCard(
        tester,
        asksOperation: true,
        spokenText: 'Quelle multiplication donne 35',
      );
      // Assert
      expect(
        find.bySemanticsLabel('Quelle multiplication donne 35'),
        findsOneWidget,
      );
    });
  });
}
