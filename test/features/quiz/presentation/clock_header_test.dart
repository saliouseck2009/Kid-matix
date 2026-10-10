import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/clock_header.dart';

import '../../../helpers/pump_localized.dart';

void main() {
  group('ClockHeader', () {
    testWidgets('shows the live score and reads the seconds left', (
      WidgetTester tester,
    ) async {
      // Arrange
      final SemanticsHandle handle = tester.ensureSemantics();
      // Act
      await pumpLocalized(
        tester,
        Scaffold(
          body: ClockHeader(
            timeLeft: const Duration(milliseconds: 41200),
            totalTime: const Duration(seconds: 60),
            score: 12,
            onQuit: () {},
          ),
        ),
      );
      // Assert
      expect(find.text('12'), findsOneWidget);
      expect(find.bySemanticsLabel('12 bonnes réponses'), findsOneWidget);
      expect(find.bySemanticsLabel('Encore 42 secondes'), findsOneWidget);
      handle.dispose();
    });
  });
}
