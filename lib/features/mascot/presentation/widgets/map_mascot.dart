import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_cubit.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_state.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_growth_celebration.dart';

/// The mascot on the map, next to the current table, with a speech
/// [bubble]; it celebrates its growth to a new stage once.
class MapMascot extends StatelessWidget {
  /// Creates the mascot with its [bubble].
  const MapMascot({required this.bubble, super.key});

  static const double _size = 96;

  /// What the mascot says, such as the daily goal reminder.
  final Widget bubble;

  @override
  Widget build(BuildContext context) {
    return BlocListener<MascotCubit, MascotState>(
      listenWhen: (MascotState previous, MascotState current) =>
          current is MascotLoaded && current.mascot.isNewStage,
      listener: (BuildContext context, MascotState state) async {
        final MascotCubit cubit = context.read<MascotCubit>();
        final MascotLoaded loaded = state as MascotLoaded;
        await cubit.markCelebrated(loaded.mascot.stage);
        if (context.mounted) await showMascotGrowth(context, loaded.mascot);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: AppSizes.space8,
        children: <Widget>[
          const MascotIllustration(size: _size),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}
