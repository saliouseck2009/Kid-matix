import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/services/speech_reading.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/features/quiz/domain/entities/read_aloud_mode.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_read_aloud_mode_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_mode_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_params.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_use_case.dart';
import 'package:kid_matix/features/quiz/domain/usecases/stop_read_aloud_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_speech_service.dart';

final class _MockSettings extends Mock implements PlayerSettingsService {}

void main() {
  const ReadAloudModeParams inputParams = ReadAloudModeParams(
    profileId: 'p-1',
    languageCode: 'fr',
  );
  late _MockSettings mockSettings;
  late FakeSpeechService speech;

  setUp(() {
    mockSettings = _MockSettings();
    speech = FakeSpeechService();
    when(
      () => mockSettings.readReadAloudEnabled(profileId: 'p-1'),
    ).thenAnswer((_) async => const DataSuccess<bool>(false));
  });

  GetReadAloudModeUseCase buildUseCase() =>
      GetReadAloudModeUseCase(speech: speech, settings: mockSettings);

  group('GetReadAloudModeUseCase', () {
    test(
      'reads on request when a voice exists and the setting is off',
      () async {
        // Act
        final ReadAloudMode actualMode = await buildUseCase()(
          params: inputParams,
        );
        // Assert
        expect(actualMode, ReadAloudMode.onRequest);
      },
    );
    test('reads by itself when the player turned the setting on', () async {
      // Arrange
      when(
        () => mockSettings.readReadAloudEnabled(profileId: 'p-1'),
      ).thenAnswer((_) async => const DataSuccess<bool>(true));
      // Act
      final ReadAloudMode actualMode = await buildUseCase()(
        params: inputParams,
      );
      // Assert
      expect(actualMode, ReadAloudMode.automatic);
    });
    test('reads nothing without a voice, whatever the setting', () async {
      // Arrange
      speech.hasVoice = false;
      when(
        () => mockSettings.readReadAloudEnabled(profileId: 'p-1'),
      ).thenAnswer((_) async => const DataSuccess<bool>(true));
      // Act
      final ReadAloudMode actualMode = await buildUseCase()(
        params: inputParams,
      );
      // Assert
      expect(actualMode, ReadAloudMode.unavailable);
    });
    test('counts a setting that cannot be read as off', () async {
      // Arrange
      when(
        () => mockSettings.readReadAloudEnabled(profileId: 'p-1'),
      ).thenAnswer((_) async => const DataFailed<bool>(CacheException()));
      // Act
      final ReadAloudMode actualMode = await buildUseCase()(
        params: inputParams,
      );
      // Assert
      expect(actualMode, ReadAloudMode.onRequest);
    });
  });

  group('ReadAloudUseCase and StopReadAloudUseCase', () {
    test('read the text in the language, then stop on request', () async {
      // Arrange
      final ReadAloudUseCase inputRead = ReadAloudUseCase(speech: speech);
      final StopReadAloudUseCase inputStop = StopReadAloudUseCase(
        speech: speech,
      );
      bool isDone = false;
      // Act
      final SpeechReading voice = inputRead(
        params: const ReadAloudParams(
          text: '5 fois 7 égale combien',
          languageCode: 'fr',
        ),
      );
      final Future<void> actualReading = voice.done.then((_) => isDone = true);
      await pumpEventQueue();
      // Assert
      expect(speech.spoken, <String>['5 fois 7 égale combien']);
      expect(speech.languages, <String>['fr']);
      expect(isDone, isFalse);
      await inputStop(params: voice);
      await actualReading;
      expect(isDone, isTrue);
    });
    test('leave alone a reading that a newer one replaced', () async {
      // Arrange
      final ReadAloudUseCase inputRead = ReadAloudUseCase(speech: speech);
      final StopReadAloudUseCase inputStop = StopReadAloudUseCase(
        speech: speech,
      );
      const ReadAloudParams inputFirst = ReadAloudParams(
        text: 'première',
        languageCode: 'fr',
      );
      const ReadAloudParams inputSecond = ReadAloudParams(
        text: 'seconde',
        languageCode: 'fr',
      );
      final SpeechReading older = inputRead(params: inputFirst);
      final SpeechReading newer = inputRead(params: inputSecond);
      await pumpEventQueue();
      // Act
      await inputStop(params: older);
      // Assert
      expect(speech.isSpeaking, isTrue);
      await inputStop(params: newer);
      expect(speech.isSpeaking, isFalse);
    });
  });
}
