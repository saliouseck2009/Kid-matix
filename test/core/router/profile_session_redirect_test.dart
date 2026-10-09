import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/router/profile_session_redirect.dart';

import '../../helpers/fake_profile_session_service.dart';

void main() {
  String? redirect(FakeProfileSessionService session, String location) {
    return redirectForProfileSession(session: session, location: location);
  }

  group('redirectForProfileSession', () {
    test('opens the creation on the first launch', () {
      // Arrange
      final FakeProfileSessionService inputSession = FakeProfileSessionService(
        hasProfiles: false,
      );
      // Act
      final String? actualHome = redirect(inputSession, AppRoutes.learningPath);
      final String? actualSelection = redirect(
        inputSession,
        AppRoutes.whoIsPlaying,
      );
      final String? actualCreation = redirect(
        inputSession,
        AppRoutes.profileCreation,
      );
      // Assert
      expect(actualHome, AppRoutes.profileCreation);
      expect(actualSelection, AppRoutes.profileCreation);
      expect(actualCreation, isNull);
    });
    test('keeps the player selection while nobody plays', () {
      // Arrange
      final FakeProfileSessionService inputSession =
          FakeProfileSessionService();
      // Act
      final String? actualHome = redirect(inputSession, AppRoutes.learningPath);
      final String? actualTab = redirect(inputSession, AppRoutes.profile);
      final String? actualSelection = redirect(
        inputSession,
        AppRoutes.whoIsPlaying,
      );
      final String? actualCreation = redirect(
        inputSession,
        AppRoutes.profileCreation,
      );
      // Assert
      expect(actualHome, AppRoutes.whoIsPlaying);
      expect(actualTab, AppRoutes.whoIsPlaying);
      expect(actualSelection, isNull);
      expect(actualCreation, isNull);
    });
    test('sends an active player from the selection to the home', () {
      // Arrange
      final FakeProfileSessionService inputSession = FakeProfileSessionService(
        activeProfileId: 'p-1',
      );
      // Act
      final String? actualSelection = redirect(
        inputSession,
        AppRoutes.whoIsPlaying,
      );
      final String? actualCreation = redirect(
        inputSession,
        AppRoutes.profileCreation,
      );
      final String? actualTab = redirect(inputSession, AppRoutes.training);
      // Assert
      expect(actualSelection, AppRoutes.learningPath);
      expect(actualCreation, AppRoutes.learningPath);
      expect(actualTab, isNull);
    });
  });
}
