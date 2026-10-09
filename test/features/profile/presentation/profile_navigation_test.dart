import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/router/app_router.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/main.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_profile_session_service.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/profile_fixtures.dart';

MockWatchProfileChangesUseCase _buildQuietWatch() {
  final MockWatchProfileChangesUseCase mockWatch =
      MockWatchProfileChangesUseCase();
  when(mockWatch.call).thenAnswer((_) => const Stream<void>.empty());
  return mockWatch;
}

void main() {
  late FakeProfileSessionService session;
  late MockGetProfilesUseCase mockGetProfiles;
  late MockGetProfileUseCase mockGetProfile;
  late MockClearActiveProfileUseCase mockClearActive;

  setUp(() {
    mockGetProfiles = MockGetProfilesUseCase();
    when(mockGetProfiles.call).thenAnswer(
      (_) async => DataSuccess<List<ProfileEntity>>(<ProfileEntity>[
        buildProfile(),
      ]),
    );
    mockGetProfile = MockGetProfileUseCase();
    when(
      () => mockGetProfile.call(params: any(named: 'params')),
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(buildProfile()));
    mockClearActive = MockClearActiveProfileUseCase();
    when(
      mockClearActive.call,
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      KidMatixApp(
        router: createAppRouter(
          session: session,
          profilePages: buildProfilePages(
            getProfiles: mockGetProfiles,
            getProfile: mockGetProfile,
            tabUseCases: buildTabUseCases(
              getProfile: mockGetProfile,
              watchChanges: _buildQuietWatch(),
              clearActiveProfile: mockClearActive,
            ),
          ),
          quizPages: buildTestQuizPages(),
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
    testWidgets('shows the active player in the Profile tab', (
      WidgetTester tester,
    ) async {
      // Arrange
      session = FakeProfileSessionService(activeProfileId: 'profile-1');
      await pumpApp(tester);
      // Act
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Awa'), findsOneWidget);
      expect(find.text('Niveau 1'), findsOneWidget);
      expect(find.text('Changer de joueur'), findsOneWidget);
    });
    testWidgets('opens the edit form over the tabs and comes back', (
      WidgetTester tester,
    ) async {
      // Arrange
      session = FakeProfileSessionService(activeProfileId: 'profile-1');
      await pumpApp(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      // Act
      await tester.tap(find.text('Modifier mon profil'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Enregistrer'), findsOneWidget);
      expect(find.text('Parcours'), findsNothing);
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();
      expect(find.text('Changer de joueur'), findsOneWidget);
    });
    testWidgets('lets another child play', (WidgetTester tester) async {
      // Arrange
      session = FakeProfileSessionService(activeProfileId: 'profile-1');
      await pumpApp(tester);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      // Act
      await tester.tap(find.text('Changer de joueur'));
      await tester.pump();
      session.update(hasProfiles: true);
      await tester.pumpAndSettle();
      // Assert
      verify(mockClearActive.call).called(1);
      expect(find.text('Qui joue\u00a0?'), findsOneWidget);
    });
  });
}
