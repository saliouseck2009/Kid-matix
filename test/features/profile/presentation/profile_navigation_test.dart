import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/main.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_profile_session_service.dart';
import '../helpers/profile_fixtures.dart';

void main() {
  late FakeProfileSessionService session;
  late MockGetProfilesUseCase mockGetProfiles;

  setUp(() {
    mockGetProfiles = MockGetProfilesUseCase();
    when(mockGetProfiles.call).thenAnswer(
      (_) async => DataSuccess<List<ProfileEntity>>(<ProfileEntity>[
        buildProfile(),
      ]),
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      KidMatixApp(
        router: createAppRouter(
          session: session,
          profilePages: ProfilePages(
            getProfiles: mockGetProfiles,
            createProfile: MockCreateProfileUseCase(),
            selectProfile: MockSelectProfileUseCase(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('navigation around the active player', () {
    testWidgets('opens the creation directly on the first launch', (
      WidgetTester tester,
    ) async {
      // Arrange
      session = FakeProfileSessionService(hasProfiles: false);
      // Act
      await pumpApp(tester);
      // Assert
      expect(find.text('Ton pseudo'), findsOneWidget);
      expect(find.byTooltip('Retour'), findsNothing);
    });
    testWidgets('asks who is playing when players exist', (
      WidgetTester tester,
    ) async {
      // Arrange
      session = FakeProfileSessionService();
      // Act
      await pumpApp(tester);
      // Assert
      expect(find.text('Qui joue ?'), findsOneWidget);
      expect(find.text('Awa'), findsOneWidget);
    });
    testWidgets('goes from the new player card to the creation and back', (
      WidgetTester tester,
    ) async {
      // Arrange
      session = FakeProfileSessionService();
      await pumpApp(tester);
      // Act
      await tester.tap(find.text('Nouveau joueur'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Qui joue ?'), findsOneWidget);
    });
    testWidgets('reaches the home once a player is active', (
      WidgetTester tester,
    ) async {
      // Arrange
      session = FakeProfileSessionService();
      await pumpApp(tester);
      // Act
      session.update(hasProfiles: true, activeProfileId: 'profile-1');
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Qui joue ?'), findsNothing);
      expect(find.text('Bientôt disponible'), findsOneWidget);
    });
  });
}
