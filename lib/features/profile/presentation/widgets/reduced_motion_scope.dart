import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/player_settings_cubit.dart';

/// Turns the animations off below it when the player chose "Animations
/// réduites", as when the phone asks for it: every widget reading
/// `MediaQuery.disableAnimationsOf` follows.
///
/// It always wraps [child] in the same [MediaQuery], so turning the setting
/// on or off never rebuilds the screens below from scratch.
class ReducedMotionScope extends StatelessWidget {
  /// Creates the scope around [child]; the settings come from the
  /// enclosing Cubit, and apply only while [isPlayerActive].
  const ReducedMotionScope({
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
    final bool isReduced =
        isPlayerActive && (settings?.isReducedMotionEnabled ?? false);
    final MediaQueryData media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        disableAnimations: media.disableAnimations || isReduced,
      ),
      child: child,
    );
  }
}
