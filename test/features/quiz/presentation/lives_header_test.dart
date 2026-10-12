import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/lives_header.dart';

import '../../../helpers/pump_localized.dart';

void main() {
  group('LivesHeader', () {
    testWidgets('shows a full heart per life left and an empty one per '
        'life lost', (WidgetTester tester) async {
      // Arrange
      final SemanticsHandle handle = tester.ensureSemantics();
      // Act
      await pumpLocalized(
        tester,
        Scaffold(
          body: LivesHeader(livesLeft: 2, lives: 3, score: 7, onQuit: () {}),
        ),
      );
      // Assert
      expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.bySemanticsLabel('2 vies sur 3'), findsOneWidget);
      expect(find.bySemanticsLabel('7 bonnes réponses'), findsOneWidget);
      handle.dispose();
    });
  });
}
