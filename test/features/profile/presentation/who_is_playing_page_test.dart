import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/pages/who_is_playing_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

void main() {
  late MockGetProfilesUseCase mockGetProfiles;
  late MockSelectProfileUseCase mockSelectProfile;

  setUp(() {
    mockGetProfiles = MockGetProfilesUseCase();
    mockSelectProfile = MockSelectProfileUseCase();
    when(
      () => mockSelectProfile.call(params: any(named: 'params')),
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(buildProfile()));
  });

  void stubProfiles(List<ProfileEntity> profiles) {
    when(mockGetProfiles.call).thenAnswer(
      (_) async => DataSuccess<List<ProfileEntity>>(profiles),
    );
  }

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 4200);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      WhoIsPlayingPage(
        getProfiles: mockGetProfiles,
        selectProfile: mockSelectProfile,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('WhoIsPlayingPage', () {
    testWidgets('shows a card per player and the new player card', (
      WidgetTester tester,
    ) async {
      // Arrange
      stubProfiles(<ProfileEntity>[
        buildProfile(id: 'p-1', nickname: 'Awa'),
        buildProfile(id: 'p-2', nickname: 'Moussa').copyWith(level: 7),
      ]);
      // Act
      await pumpPage(tester);
      // Assert
      expect(find.text('Qui joue ?'), findsOneWidget);
      expect(find.text('Awa'), findsOneWidget);
      expect(find.text('Moussa'), findsOneWidget);
      expect(find.text('Niveau 7'), findsOneWidget);
      expect(find.text('Nouveau joueur'), findsOneWidget);
      expect(
        find.text("Jusqu'à 10 joueurs sur ce téléphone."),
        findsOneWidget,
      );
    });
    testWidgets('opens the session of the tapped player', (
      WidgetTester tester,
    ) async {
      // Arrange
      stubProfiles(<ProfileEntity>[buildProfile(id: 'p-1', nickname: 'Awa')]);
      await pumpPage(tester);
      // Act
      await tester.tap(find.text('Awa'));
      await tester.pump();
      // Assert
      verify(() => mockSelectProfile.call(params: 'p-1')).called(1);
    });
    testWidgets('hides the new player card once ten players exist', (
      WidgetTester tester,
    ) async {
      // Arrange
      stubProfiles(
        List<ProfileEntity>.generate(
          10,
          (int index) => buildProfile(id: 'p-$index', nickname: 'J$index'),
        ),
      );
      // Act
      await pumpPage(tester);
      // Assert
      expect(find.text('J9'), findsOneWidget);
      expect(find.text('Nouveau joueur'), findsNothing);
    });
    testWidgets('offers to try again when the players cannot be read', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockGetProfiles.call).thenAnswer(
        (_) async => const DataFailed<List<ProfileEntity>>(CacheException()),
      );
      await pumpPage(tester);
      stubProfiles(<ProfileEntity>[buildProfile()]);
      // Act
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Awa'), findsOneWidget);
    });
    testWidgets('fits large system text without overflowing', (
      WidgetTester tester,
    ) async {
      // Arrange
      stubProfiles(<ProfileEntity>[buildProfile(), buildProfile(id: 'p-2')]);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      // Act
      await pumpPage(tester);
      // Assert
      expect(tester.takeException(), isNull);
    });
  });
}
