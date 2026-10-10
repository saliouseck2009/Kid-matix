import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/features/setting/domain/services/game_feedback_service_impl.dart';
import 'package:kid_matix/features/setting/domain/services/sound_player.dart';
import 'package:kid_matix/features/setting/domain/services/vibrator.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_profile_session_service.dart';

final class _MockSettings extends Mock implements PlayerSettingsService {}

final class _RecordingSounds implements SoundPlayer {
  final List<GameFeedback> played = <GameFeedback>[];

  @override
  Future<void> play(GameFeedback feedback) async => played.add(feedback);
}

final class _RecordingVibrator implements Vibrator {
  final List<VibrationStrength> vibrations = <VibrationStrength>[];

  @override
  Future<void> vibrate(VibrationStrength strength) async =>
      vibrations.add(strength);
}

void main() {
  late _MockSettings mockSettings;
  late _RecordingSounds sounds;
  late _RecordingVibrator vibrator;

  setUp(() {
    mockSettings = _MockSettings();
    sounds = _RecordingSounds();
    vibrator = _RecordingVibrator();
  });

  GameFeedbackServiceImpl serviceFor({
    String? activeProfileId = 'p1',
    bool isSoundOn = true,
    bool isVibrationOn = true,
  }) {
    when(
      () => mockSettings.readFeedback(profileId: any(named: 'profileId')),
    ).thenAnswer(
      (_) async => DataSuccess<({bool isSoundOn, bool isVibrationOn})>((
        isSoundOn: isSoundOn,
        isVibrationOn: isVibrationOn,
      )),
    );
    return GameFeedbackServiceImpl(
      session: FakeProfileSessionService(activeProfileId: activeProfileId),
      settings: mockSettings,
      sounds: sounds,
      vibrator: vibrator,
    );
  }

  group('GameFeedbackServiceImpl', () {
    test('plays a sound after a right answer, without vibration', () async {
      // Act
      await serviceFor().play(GameFeedback.rightAnswer);
      // Assert
      expect(sounds.played, <GameFeedback>[GameFeedback.rightAnswer]);
      expect(vibrator.vibrations, isEmpty);
    });
    test('vibrates lightly after a mistake and firmly to celebrate', () async {
      // Arrange
      final GameFeedbackServiceImpl service = serviceFor();
      // Act
      await service.play(GameFeedback.wrongAnswer);
      await service.play(GameFeedback.celebration);
      // Assert
      expect(vibrator.vibrations, <VibrationStrength>[
        VibrationStrength.light,
        VibrationStrength.medium,
      ]);
      expect(sounds.played, hasLength(2));
    });
    test('turns the sounds and the vibrations off separately', () async {
      // Act
      await serviceFor(isSoundOn: false).play(GameFeedback.wrongAnswer);
      await serviceFor(isVibrationOn: false).play(GameFeedback.celebration);
      // Assert
      expect(sounds.played, <GameFeedback>[GameFeedback.celebration]);
      expect(vibrator.vibrations, <VibrationStrength>[VibrationStrength.light]);
    });
    test('stays silent without an active player or settings', () async {
      // Arrange
      when(
        () => mockSettings.readFeedback(profileId: any(named: 'profileId')),
      ).thenAnswer(
        (_) async => const DataFailed<({bool isSoundOn, bool isVibrationOn})>(
          CacheException(),
        ),
      );
      // Act
      await GameFeedbackServiceImpl(
        session: FakeProfileSessionService(activeProfileId: 'p1'),
        settings: mockSettings,
        sounds: sounds,
        vibrator: vibrator,
      ).play(GameFeedback.rightAnswer);
      await serviceFor(activeProfileId: null).play(GameFeedback.rightAnswer);
      // Assert
      expect(sounds.played, isEmpty);
      expect(vibrator.vibrations, isEmpty);
    });
  });
}
