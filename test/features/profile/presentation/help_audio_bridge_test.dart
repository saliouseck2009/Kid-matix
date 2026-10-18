import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

/// The settings scope tells the screens the "Aide audio" of the player.
void main() {
  Future<String> pumpScope(
    WidgetTester tester, {
    required String language,
    bool isPlayerActive = true,
  }) async {
    final MockGetSettingsUseCase mockGetSettings = MockGetSettingsUseCase();
    when(() => mockGetSettings.call(params: any(named: 'params'))).thenAnswer(
      (_) async => DataSuccess<ProfileSettingsEntity>(
        const ProfileSettingsEntity.defaults(
          profileId: 'p1',
        ).copyWith(helpAudioLanguage: language),
      ),
    );
    String actual = 'unset';
    await pumpLocalized(
      tester,
      buildProfilePages(
        settingsUseCases: buildSettingsUseCases(getSettings: mockGetSettings),
      ).buildSettingsScope(
        profileId: 'p1',
        isPlayerActive: isPlayerActive,
        child: Builder(
          builder: (BuildContext context) {
            actual = HelpAudioLanguageScope.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return actual;
  }

  testWidgets('gives the language the player chose', (
    WidgetTester tester,
  ) async {
    // Act & Assert
    expect(await pumpScope(tester, language: 'wo'), 'wo');
  });
  testWidgets('gives none to a player who turned the help off', (
    WidgetTester tester,
  ) async {
    // Act & Assert
    expect(await pumpScope(tester, language: HelpAudio.none), HelpAudio.none);
  });
  testWidgets('gives none once the player left', (WidgetTester tester) async {
    // Act & Assert
    expect(
      await pumpScope(tester, language: 'wo', isPlayerActive: false),
      HelpAudio.none,
    );
  });
  testWidgets('gives none until the settings are read', (
    WidgetTester tester,
  ) async {
    // Arrange
    String actual = 'unset';
    // Act
    await pumpLocalized(
      tester,
      HelpAudioLanguageScope(
        language: HelpAudio.none,
        child: Builder(
          builder: (BuildContext context) {
            actual = HelpAudioLanguageScope.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    // Assert
    expect(actual, HelpAudio.none);
  });
}
