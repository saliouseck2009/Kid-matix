import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/features/mascot/presentation/mascot_pages.dart';
import 'package:kid_matix/main.dart';

import 'features/profile/helpers/profile_fixtures.dart';
import 'helpers/fake_profile_session_service.dart';
import 'helpers/test_path_pages.dart';
import 'helpers/test_quiz_pages.dart';
import 'helpers/test_reward_pages.dart';
import 'helpers/test_mascot_pages.dart';

/// Mascot of the test player.
final MascotPages mascotPages = buildTestMascotPages();

/// Router of an app where a player is already active.
GoRouter _createPlayingRouter() {
  return createAppRouter(
    session: FakeProfileSessionService(activeProfileId: 'p-1'),
    profilePages: buildProfilePages(),
    quizPages: buildTestQuizPages(),
    pathPages: buildTestPathPages(),
    rewardPages: buildTestRewardPages(),
    mascotPages: mascotPages,
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
      await tester.pumpWidget(
        KidMatixApp(
          router: _createPlayingRouter(),
          scope: testMascotScope(mascotPages),
        ),
      );
      await tester.pumpAndSettle();
      // Assert
      for (final String expectedTab in expectedTabs) {
        expect(find.text(expectedTab), findsWidgets);
      }
    });
    testWidgets('opens on the learning path above the tab bar', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        KidMatixApp(
          router: _createPlayingRouter(),
          scope: testMascotScope(mascotPages),
        ),
      );
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Table de 1').hitTestable(), findsOneWidget);
      expect(find.text('Jouer').hitTestable(), findsOneWidget);
    });
    testWidgets('opens a tab when the player taps it', (
      WidgetTester tester,
    ) async {
      // Arrange
      const String inputTab = 'Défis';
      await tester.pumpWidget(
        KidMatixApp(
          router: _createPlayingRouter(),
          scope: testMascotScope(mascotPages),
        ),
      );
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
