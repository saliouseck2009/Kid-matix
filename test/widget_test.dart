import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/main.dart';

import 'features/profile/helpers/profile_fixtures.dart';
import 'helpers/fake_profile_session_service.dart';

/// Router of an app where a player is already active.
GoRouter _createPlayingRouter() {
  return createAppRouter(
    session: FakeProfileSessionService(activeProfileId: 'p-1'),
    profilePages: buildProfilePages(),
  );
}

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
      await tester.pumpWidget(KidMatixApp(router: _createPlayingRouter()));
      await tester.pumpAndSettle();
      // Assert
      for (final String expectedTab in expectedTabs) {
        expect(find.text(expectedTab), findsWidgets);
      }
    });
    testWidgets('keeps the page visible above the tab bar', (
      WidgetTester tester,
    ) async {
      // Arrange
      const String expectedMessage = 'Bientôt disponible';
      // Act
      await tester.pumpWidget(KidMatixApp(router: _createPlayingRouter()));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text(expectedMessage).hitTestable(), findsOneWidget);
    });
    testWidgets('opens a tab when the player taps it', (
      WidgetTester tester,
    ) async {
      // Arrange
      const String inputTab = 'Défis';
      await tester.pumpWidget(KidMatixApp(router: _createPlayingRouter()));
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
