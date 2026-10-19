import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_word_audio_service.dart';
import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

/// The settings scope tells the screens the "Aide audio" of the player; a
/// player who never chose gets the first pack.
void main() {
  final FakeWordAudioService audio = FakeWordAudioService(language: 'xx');

  Future<String> pumpScope(
    WidgetTester tester, {
    required String? language,
    bool isPlayerActive = true,
  }) async {
    final MockGetSettingsUseCase mockGetSettings = MockGetSettingsUseCase();
    when(() => mockGetSettings.call(params: any(named: 'params'))).thenAnswer(
      (_) async => DataSuccess<ProfileSettingsEntity>(
        ProfileSettingsEntity(
          profileId: 'p1',
          timerMode: const ProfileSettingsEntity.defaults(
            profileId: 'p1',
          ).timerMode,
          dailyGoal: const ProfileSettingsEntity.defaults(
            profileId: 'p1',
          ).dailyGoal,
          isSoundEnabled: true,
          isVibrationEnabled: true,
          isReducedMotionEnabled: false,
          isEverythingUnlocked: false,
          helpAudioLanguage: language,
        ),
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
            actual = HelpAudioLanguageScope.resolve(context, audio);
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
    expect(await pumpScope(tester, language: 'yy'), 'yy');
  });
  testWidgets('gives the first pack to a player who never chose', (
    WidgetTester tester,
  ) async {
    // Act & Assert
    expect(await pumpScope(tester, language: null), 'xx');
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
      await pumpScope(tester, language: 'xx', isPlayerActive: false),
      HelpAudio.none,
    );
  });
  testWidgets('gives none without a scope or without any pack', (
    WidgetTester tester,
  ) async {
    // Arrange
    String withoutScope = 'unset';
    String withoutPack = 'unset';
    // Act
    await pumpLocalized(
      tester,
      Column(
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              withoutScope = HelpAudioLanguageScope.resolve(context, audio);
              return const SizedBox.shrink();
            },
          ),
          HelpAudioLanguageScope(
            language: null,
            child: Builder(
              builder: (BuildContext context) {
                withoutPack = HelpAudioLanguageScope.resolve(context, null);
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
    // Assert
    expect(withoutScope, HelpAudio.none);
    expect(withoutPack, HelpAudio.none);
  });
}
