import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/player_settings_cubit.dart';

/// Turns the animations off below it when the player chose "Animations
/// réduites", as when the phone asks for it: every widget reading
/// `MediaQuery.disableAnimationsOf` follows.
class ReducedMotionScope extends StatelessWidget {
  /// Creates the scope around [child]; the settings come from the
  /// enclosing Cubit.
  const ReducedMotionScope({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ProfileSettingsEntity? settings = context
        .watch<PlayerSettingsCubit>()
        .state;
    if (settings == null || !settings.isReducedMotionEnabled) return child;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: child,
    );
  }
}
