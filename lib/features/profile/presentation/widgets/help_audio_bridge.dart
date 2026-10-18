import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/player_settings_cubit.dart';

/// Tells the screens below it the "Aide audio" of the player of the
/// enclosing Cubit, so the math words can offer their recorded help
/// without reading the profile feature.
///
/// Like the reduced motion, the choice applies only while the player is
/// still the one playing; until the settings are read, no help plays.
class HelpAudioBridge extends StatelessWidget {
  /// Creates the bridge around [child].
  const HelpAudioBridge({
    required this.child,
    this.isPlayerActive = true,
    super.key,
  });

  /// The app.
  final Widget child;

  /// Whether the player of the enclosing Cubit is still the one playing.
  final bool isPlayerActive;

  @override
  Widget build(BuildContext context) {
    final ProfileSettingsEntity? settings = context
        .watch<PlayerSettingsCubit>()
        .state;
    return HelpAudioLanguageScope(
      language: isPlayerActive
          ? settings?.helpAudioLanguage ?? HelpAudio.none
          : HelpAudio.none,
      child: child,
    );
  }
}
