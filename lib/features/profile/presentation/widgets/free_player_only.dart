import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_state.dart';

/// Shows [child] only when the player of the enclosing Cubit is a free
/// player, such as the « Classement » card: the pupils of a class have no
/// leaderboard.
class FreePlayerOnly extends StatelessWidget {
  /// Creates the wrapper around [child].
  const FreePlayerOnly({required this.child, super.key});

  /// Shown for a free player.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileTabCubit, ProfileTabState>(
      builder: (BuildContext context, ProfileTabState state) {
        return switch (state) {
          ProfileTabLoaded(:final profile) when !profile.isPupil => child,
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
