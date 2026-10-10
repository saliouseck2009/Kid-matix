import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/mascot_look.dart';
import 'package:kid_matix/core/widgets/mascot_look_scope.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_cubit.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_state.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_use_cases.dart';
import 'package:kid_matix/features/mascot/presentation/pages/mascot_page.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/map_mascot.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_look_of.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_profile_card.dart';

/// Builds the mascot widgets for the app and the router.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class MascotPages {
  /// Creates the factory.
  const MascotPages({required this._useCases});

  final MascotUseCases _useCases;

  /// Provides the mascot of [profileId] to [child]: its look to every
  /// mascot drawing, and the mascot to the widgets below.
  Widget buildScope({required String profileId, required Widget child}) {
    return BlocProvider<MascotCubit>(
      key: ValueKey<String>('mascot-$profileId'),
      create: (_) =>
          MascotCubit(profileId: profileId, useCases: _useCases)..load(),
      child: BlocBuilder<MascotCubit, MascotState>(
        builder: (BuildContext context, MascotState state) => MascotLookScope(
          look: switch (state) {
            MascotLoaded(:final mascot) => lookOf(mascot),
            _ => const MascotLook.initial(),
          },
          child: child,
        ),
      ),
    );
  }

  /// The mascot on the map saying [bubble], inside [buildScope].
  Widget buildMapMascot({required Widget bubble}) {
    return MapMascot(bubble: bubble);
  }

  /// The mascot card of the Profile tab, inside [buildScope].
  Widget buildProfileCard({required VoidCallback onOpen}) {
    return MascotProfileCard(onOpen: onOpen);
  }

  /// The mascot screen, inside [buildScope].
  Widget buildMascotPage({required VoidCallback onBack}) {
    return MascotPage(onBack: onBack);
  }
}
