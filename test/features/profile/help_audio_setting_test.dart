import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/data/models/profile_settings_local_model.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/services/player_settings_service_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/data_state_test_extension.dart';
import 'helpers/profile_fixtures.dart';

/// The "Aide audio" setting (lot F28): the entity, its stored row and the
/// service that lets the other features read it.
void main() {
  final DateTime updatedAt = DateTime(2026, 10, 18);
  const ProfileSettingsEntity defaults = ProfileSettingsEntity.defaults(
    profileId: 'p-1',
  );

  group('Help audio setting', () {
    test('starts on the shipped language', () {
      // Assert
      expect(defaults.helpAudioLanguage, HelpAudio.defaultLanguage);
    });

    test('turns off without touching the rest', () {
      // Act
      final ProfileSettingsEntity actualSettings = defaults.copyWith(
        helpAudioLanguage: HelpAudio.none,
      );
      // Assert
      expect(actualSettings.helpAudioLanguage, HelpAudio.none);
      expect(actualSettings, isNot(defaults));
      expect(
        actualSettings.copyWith(helpAudioLanguage: 'wo'),
        defaults,
      );
    });

    test('is stored and read back', () {
      // Arrange
      final ProfileSettingsLocalModel inputModel =
          ProfileSettingsLocalModel.fromEntity(
            settings: defaults.copyWith(helpAudioLanguage: HelpAudio.none),
            updatedAt: updatedAt,
          );
      // Act
      final Map<String, Object?> actualRow = inputModel.toJson();
      // Assert
      expect(actualRow['help_audio_language'], 'none');
      expect(
        ProfileSettingsLocalModel.fromJson(actualRow)
            .toEntity()
            .helpAudioLanguage,
        HelpAudio.none,
      );
    });

    test('reads a backup made before the audio help as the default', () {
      // Arrange
      final Map<String, Object?> inputRow =
          ProfileSettingsLocalModel.fromEntity(
            settings: defaults,
            updatedAt: updatedAt,
          ).toJson()..remove('help_audio_language');
      // Act
      final ProfileSettingsEntity actualSettings =
          ProfileSettingsLocalModel.fromJson(inputRow).toEntity();
      // Assert
      expect(actualSettings.helpAudioLanguage, HelpAudio.defaultLanguage);
    });

    test('is read by the other features through the service', () async {
      // Arrange
      final MockProfileRepository repository = MockProfileRepository();
      when(
        () => repository.getProfileSettings(profileId: any(named: 'profileId')),
      ).thenAnswer(
        (_) async => DataSuccess<ProfileSettingsEntity>(
          defaults.copyWith(helpAudioLanguage: HelpAudio.none),
        ),
      );
      final PlayerSettingsServiceImpl service = PlayerSettingsServiceImpl(
        repository: repository,
      );
      // Act
      final String actualLanguage = (await service.readHelpAudioLanguage(
        profileId: 'p-1',
      )).requireData;
      // Assert
      expect(actualLanguage, HelpAudio.none);
    });
  });
}
