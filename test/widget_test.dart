import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/main.dart';

void main() {
  group('App shell', () {
    testWidgets('shows the four main tabs', (WidgetTester tester) async {
      // Arrange
      const List<String> expectedTabs = <String>[
        'Parcours',
        "S'entraîner",
        'Défis',
        'Profil',
      ];
      // Act
      await tester.pumpWidget(KidMatixApp(router: createAppRouter()));
      await tester.pumpAndSettle();
      // Assert
      for (final String expectedTab in expectedTabs) {
        expect(find.text(expectedTab), findsWidgets);
      }
    });
    testWidgets('opens a tab when the player taps it', (
      WidgetTester tester,
    ) async {
      // Arrange
      const String inputTab = 'Défis';
      await tester.pumpWidget(KidMatixApp(router: createAppRouter()));
      await tester.pumpAndSettle();
      // Act
      await tester.tap(find.text(inputTab));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text(inputTab), findsNWidgets(2));
      expect(find.text('Bientôt disponible'), findsOneWidget);
    });
  });
}
