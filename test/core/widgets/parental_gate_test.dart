import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/parental_gate.dart';

import '../../helpers/pump_localized.dart';

void main() {
  late bool? actualOutcome;

  Future<void> openGate(WidgetTester tester, {required int seed}) async {
    actualOutcome = null;
    await pumpLocalized(
      tester,
      Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () async {
            actualOutcome = await askAnAdult(context, random: Random(seed));
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  int numberOf(int seed) {
    return ParentalGate.minNumber +
        Random(
          seed,
        ).nextInt(ParentalGate.maxNumber - ParentalGate.minNumber + 1);
  }

  group('ParentalGate', () {
    testWidgets('lets an adult through who types the number in digits', (
      WidgetTester tester,
    ) async {
      // Arrange
      await openGate(tester, seed: 7);
      // Act
      await tester.enterText(find.byType(TextField), '${numberOf(7)}');
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      // Assert
      expect(actualOutcome, isTrue);
      expect(find.byType(ParentalGate), findsNothing);
    });

    testWidgets('shows the number in words, never in digits', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpLocalized(tester, const ParentalGate(number: 3472));
      // Assert
      expect(find.text('Demande à un adulte'), findsOneWidget);
      expect(
        find.text('trois mille quatre cent soixante-douze'),
        findsOneWidget,
      );
      expect(find.textContaining('3472'), findsNothing);
    });

    testWidgets('writes the number in the language of the interface', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpLocalized(
        tester,
        const ParentalGate(number: 3472),
        locale: const Locale('en'),
      );
      // Assert
      expect(find.text('Ask a grown-up'), findsOneWidget);
      expect(
        find.text('three thousand four hundred seventy-two'),
        findsOneWidget,
      );
    });

    testWidgets('writes it in Spanish for a Spanish interface', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpLocalized(
        tester,
        const ParentalGate(number: 3472),
        locale: const Locale('es'),
      );
      // Assert
      expect(
        find.text('tres mil cuatrocientos setenta y dos'),
        findsOneWidget,
      );
    });

    testWidgets('sends back a wrong answer', (WidgetTester tester) async {
      // Arrange
      await openGate(tester, seed: 3);
      // Act
      await tester.enterText(find.byType(TextField), '${numberOf(3) + 1}');
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      // Assert
      expect(actualOutcome, isFalse);
      expect(find.byType(ParentalGate), findsNothing);
    });

    testWidgets('keeps digits only', (WidgetTester tester) async {
      // Arrange
      await pumpLocalized(tester, const ParentalGate(number: 1234));
      // Act
      await tester.enterText(find.byType(TextField), '12a34');
      // Assert
      expect(find.text('1234'), findsOneWidget);
    });

    testWidgets('closes on the cross', (WidgetTester tester) async {
      // Arrange
      await openGate(tester, seed: 1);
      // Act
      await tester.tap(find.byTooltip('Fermer'));
      await tester.pumpAndSettle();
      // Assert
      expect(actualOutcome, isFalse);
    });
  });
}
