import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/daily_goal.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

void main() {
  late MockUpdateSettingsUseCase mockUpdate;
  late MockResetProgressUseCase mockReset;

  setUp(() {
    registerFallbackValue(const ProfileSettingsEntity.defaults(profileId: ''));
    mockUpdate = MockUpdateSettingsUseCase();
    mockReset = MockResetProgressUseCase();
    when(
      () => mockUpdate.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
    when(
      () => mockReset.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    final ProfilePages pages = buildProfilePages(
      settingsUseCases: buildSettingsUseCases(
        updateSettings: mockUpdate,
        resetProgress: mockReset,
      ),
    );
    await pumpLocalized(
      tester,
      pages.buildSettingsPage(profileId: 'profile-1', onBack: () {}),
    );
    await tester.pumpAndSettle();
  }

  ProfileSettingsEntity lastSaved() {
    return verify(
          () => mockUpdate.call(params: captureAny(named: 'params')),
        ).captured.last
        as ProfileSettingsEntity;
  }

  group('SettingsPage', () {
    testWidgets('shows the sounds, the game and the player sections', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpSettings(tester);
      // Assert
      for (final String text in <String>[
        'Réglages',
        'Vibrations',
        'Détendu',
        '50 XP',
        'Tout débloquer',
        'Animations réduites',
        'Réinitialiser ma progression',
        'Supprimer ce joueur',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });
    testWidgets('saves the timer and the daily goal chosen', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSettings(tester);
      // Act
      await tester.tap(find.text('Sans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('100 XP'));
      await tester.pumpAndSettle();
      // Assert
      final ProfileSettingsEntity actualSettings = lastSaved();
      expect(actualSettings.timerMode, TimerMode.off);
      expect(actualSettings.dailyGoal, DailyGoal.intense);
    });
    testWidgets('turns the sounds off', (WidgetTester tester) async {
      // Arrange
      await pumpSettings(tester);
      // Act
      await tester.tap(find.text('Sons').last);
      await tester.pumpAndSettle();
      // Assert
      expect(lastSaved().isSoundEnabled, isFalse);
    });
    testWidgets('resets the progress once the nickname is typed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSettings(tester);
      // Act
      await tester.tap(find.text('Réinitialiser ma progression'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'awa');
      await tester.pump();
      await tester.tap(find.text('Réinitialiser'));
      await tester.pumpAndSettle();
      // Assert
      verify(() => mockReset.call(params: 'profile-1')).called(1);
      expect(find.text('Ta progression est remise à zéro.'), findsOneWidget);
    });
  });
}
