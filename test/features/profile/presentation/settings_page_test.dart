import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/daily_goal.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

const String _provisionalNotice =
    'Voix wolof provisoire (synthèse automatique) : '
    'à remplacer par de vrais enregistrements.';

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

  Future<void> pumpSettings(
    WidgetTester tester, {
    List<String> helpAudioLanguages = const <String>[],
    Set<String> provisionalHelpAudioLanguages = const <String>{},
    GetProfileUseCase? getProfile,
  }) async {
    tester.view.physicalSize = const Size(1080, 3000);
    addTearDown(tester.view.resetPhysicalSize);
    final ProfilePages pages = buildProfilePages(
      helpAudioLanguages: helpAudioLanguages,
      provisionalHelpAudioLanguages: provisionalHelpAudioLanguages,
      settingsUseCases: buildSettingsUseCases(
        getProfile: getProfile,
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
        'Lire les questions à voix haute',
        'Réinitialiser ma progression',
        'Supprimer ce joueur',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });
    testWidgets('hides the reset and the deletion from a pupil', (
      WidgetTester tester,
    ) async {
      // Arrange
      final MockGetProfileUseCase mockGetProfile = MockGetProfileUseCase();
      when(() => mockGetProfile.call(params: any(named: 'params'))).thenAnswer(
        (_) async => DataSuccess<ProfileEntity>(
          buildProfile().copyWith(classroomId: 'class-1'),
        ),
      );
      // Act
      await pumpSettings(tester, getProfile: mockGetProfile);
      // Assert
      expect(find.text('Réglages'), findsOneWidget);
      expect(find.text('Réinitialiser ma progression'), findsNothing);
      expect(find.text('Supprimer ce joueur'), findsNothing);
    });
    testWidgets('hides the audio help while no pack exists', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpSettings(tester);
      // Assert
      expect(find.text('Aide audio'), findsNothing);
    });
    testWidgets('offers the audio help in Wolof or none, on Wolof first', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSettings(tester, helpAudioLanguages: <String>['wo']);
      // Act
      await tester.tap(find.text('Aucune'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Aide audio'), findsOneWidget);
      expect(find.text('Wolof'), findsOneWidget);
      expect(lastSaved().helpAudioLanguage, HelpAudio.none);
    });
    testWidgets('says the Wolof voice is provisional when the pack is', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpSettings(
        tester,
        helpAudioLanguages: <String>['wo'],
        provisionalHelpAudioLanguages: <String>{'wo'},
      );
      // Assert
      expect(find.text(_provisionalNotice), findsOneWidget);
    });
    testWidgets('shows no notice for a real pack', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpSettings(tester, helpAudioLanguages: <String>['wo']);
      // Assert
      expect(find.text(_provisionalNotice), findsNothing);
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
    testWidgets('has the reading aloud off, then turns it on', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSettings(tester);
      expect(
        tester
            .widget<Switch>(
              find.descendant(
                of: find.widgetWithText(
                  SwitchListTile,
                  'Lire les questions à voix haute',
                ),
                matching: find.byType(Switch),
              ),
            )
            .value,
        isFalse,
      );
      // Act
      await tester.tap(find.text('Lire les questions à voix haute'));
      await tester.pumpAndSettle();
      // Assert
      expect(lastSaved().isReadAloudEnabled, isTrue);
    });
    testWidgets('resets the progress once the nickname is typed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpSettings(tester);
      // Act
      await tester.ensureVisible(find.text('Réinitialiser ma progression'));
      await tester.pumpAndSettle();
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
