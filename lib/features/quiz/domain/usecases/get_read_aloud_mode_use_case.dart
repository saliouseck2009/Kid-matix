import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/services/speech_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/quiz/domain/entities/read_aloud_mode.dart';
import 'package:kid_matix/features/quiz/domain/usecases/read_aloud_mode_params.dart';

/// How the questions of a quiz are read aloud for its player.
///
/// Without an installed voice for the language nothing is read
/// ([ReadAloudMode.unavailable]). With one, the questions read themselves
/// when the player turned "Lire les questions à voix haute" on, and
/// otherwise only on request. A setting that cannot be read counts as off.
class GetReadAloudModeUseCase
    implements UseCase<ReadAloudMode, ReadAloudModeParams> {
  /// Creates the use case.
  const GetReadAloudModeUseCase({
    required this._speech,
    required this._settings,
  });

  final SpeechService _speech;
  final PlayerSettingsService _settings;

  @override
  Future<ReadAloudMode> call({required ReadAloudModeParams params}) async {
    final bool hasVoice = await _speech.isAvailable(
      languageCode: params.languageCode,
    );
    if (!hasVoice) return ReadAloudMode.unavailable;
    final DataState<bool> readsByItself = await _settings.readReadAloudEnabled(
      profileId: params.profileId,
    );
    return switch (readsByItself) {
      DataSuccess<bool>(data: true) => ReadAloudMode.automatic,
      _ => ReadAloudMode.onRequest,
    };
  }
}
